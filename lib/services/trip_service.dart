import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../models/trip.dart' as models;
import '../models/stop.dart' as models;
import '../models/client.dart';
import '../database/app_database.dart';
import 'location_service.dart';
import 'filemaker_service.dart';
import '../utils/debug_logger.dart';

/// Service for managing trips and stops
class TripService extends ChangeNotifier {
  final AppDatabase _database;
  // ignore: unused_field
  final FileMakerService? _fileMakerService; // Reserved for future sync implementation

  TripService(this._database, [this._fileMakerService]);

  /// Create a new trip for today
  /// Auto-creates trip when driver starts route
  Future<models.Trip> createTodayTrip({
    required String driverId,
    String? routeName,
    String? vehicleId,
    required String direction, // "AM" | "PM"
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if trip already exists for today
    final existingTrip = await getTodayTrip(driverId: driverId, direction: direction);
    if (existingTrip != null) {
      return existingTrip;
    }

    final tripId = 'trip_${driverId}_${today.millisecondsSinceEpoch}_$direction';
    
    final trip = models.Trip(
      id: tripId,
      date: today,
      routeName: routeName,
      driverId: driverId,
      vehicleId: vehicleId,
      direction: direction,
      status: 'pending',
      createdAt: now,
    );

    // Save to local database
    await _database.into(_database.trips).insert(
      TripsCompanion.insert(
        id: tripId,
        date: today,
        routeName: Value(routeName),
        driverId: driverId,
        vehicleId: Value(vehicleId),
        direction: direction,
        status: const Value('pending'),
        createdAt: Value(now),
      ),
    );

    // Queue for sync
    await _queueForSync('trip', trip.toJson(), 'create');

    notifyListeners();
    return trip;
  }

  /// Get today's trip for a driver
  Future<models.Trip?> getTodayTrip({
    required String driverId,
    required String direction,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _database.select(_database.trips)
      ..where((t) => 
        t.driverId.equals(driverId) &
        t.direction.equals(direction) &
        t.date.isBiggerOrEqualValue(startOfDay) &
        t.date.isSmallerThanValue(endOfDay)
      );

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return models.Trip(
      id: result.id,
      date: result.date,
      routeName: result.routeName,
      driverId: result.driverId,
      vehicleId: result.vehicleId,
      direction: result.direction,
      status: result.status,
      createdAt: result.createdAt,
    );
  }

  /// Record a pickup or dropoff stop
  Future<models.Stop> recordStop({
    required String tripId,
    required String clientId,
    required String kind, // "pickup" | "dropoff"
    String? note,
    bool requirePhoto = false,
    bool requireSignature = false,
    String? photoPath,
    String? signaturePath,
  }) async {
    DebugLogger.info('📍 Recording $kind stop for client: $clientId, trip: $tripId');
    
    // Validate: Can't drop off without pickup
    if (kind == 'dropoff') {
      DebugLogger.log('🔍 Checking for existing pickup...');
      final pickupExists = _database.select(_database.stops)
        ..where((s) => 
          s.tripId.equals(tripId) &
          s.clientId.equals(clientId) &
          s.kind.equals('pickup') &
          s.status.equals('done')
        );
      final pickups = await pickupExists.get();
      if (pickups.isEmpty) {
        DebugLogger.error('Cannot drop off without pickup', null);
        throw Exception('Cannot drop off without pickup');
      }
      DebugLogger.success('✅ Found existing pickup, proceeding with dropoff');
    }

    // Get current location
    DebugLogger.log('📍 Getting GPS location...');
    final location = await LocationService.getCurrentLocation();
    if (location == null) {
      DebugLogger.error('Could not get GPS location', null);
      throw Exception('Could not get GPS location');
    }

    final lat = double.parse(location['latitude'] as String);
    final lng = double.parse(location['longitude'] as String);
    final accuracy = location['accuracy'] as double?;
    final speed = location['speed'] as double?;
    
    DebugLogger.success('📍 GPS Location: $lat, $lng (accuracy: ${accuracy}m)');

    // Reverse geocode
    String? address;
    try {
      DebugLogger.log('🌍 Reverse geocoding address...');
      address = await LocationService.reverseGeocode(lat, lng);
      DebugLogger.success('✅ Address: $address');
    } catch (e) {
      DebugLogger.warn('Could not reverse geocode: $e');
      // Continue anyway - address can be backfilled on sync
    }

    // Validate GPS accuracy (spoofing protection)
    if (accuracy != null && accuracy > 100) {
      DebugLogger.warn('⚠️ GPS accuracy is low: ${accuracy}m');
      // Still allow but flag it
    }

    final stopId = 'stop_${tripId}_${clientId}_${kind}_${DateTime.now().millisecondsSinceEpoch}';
    DebugLogger.log('🆔 Stop ID: $stopId');
    
    final stop = models.Stop(
      id: stopId,
      tripId: tripId,
      clientId: clientId,
      kind: kind,
      actualLatLng: LocationService.formatLatLng(lat, lng),
      actualAddress: address,
      timestamp: DateTime.now(),
      status: 'done',
      note: note,
      photoPath: photoPath,
      signaturePath: signaturePath,
      accuracy: accuracy,
      speed: speed,
    );

    // Save to local database
    DebugLogger.log('💾 Saving stop to local database...');
    try {
      await _database.into(_database.stops).insert(
        StopsCompanion.insert(
          id: stopId,
          tripId: tripId,
          clientId: clientId,
          kind: kind,
          actualLatLng: Value(address != null ? LocationService.formatLatLng(lat, lng) : null),
          actualAddress: Value(address),
          timestamp: Value(DateTime.now()),
          status: 'done',
          note: Value(note),
          photoPath: Value(photoPath),
          signaturePath: Value(signaturePath),
          accuracy: Value(accuracy),
          speed: Value(speed),
        ),
      );
      DebugLogger.success('✅ Stop saved to local database');
    } catch (e, stackTrace) {
      DebugLogger.error('Error saving stop to database', e, stackTrace);
      rethrow;
    }

    // Queue for sync
    DebugLogger.log('📤 Queuing stop for sync...');
    try {
      await _queueForSync('stop', stop.toJson(), 'create');
      DebugLogger.success('✅ Stop queued for sync');
    } catch (e, stackTrace) {
      DebugLogger.error('Error queueing stop for sync', e, stackTrace);
      // Don't rethrow - the stop is saved locally, sync can happen later
    }

    notifyListeners();
    DebugLogger.success('✅ ${kind.toUpperCase()} stop recorded successfully');
    return stop;
  }

  /// Get all stops for a trip
  Future<List<models.Stop>> getTripStops(String tripId) async {
    final query = _database.select(_database.stops)
      ..where((s) => s.tripId.equals(tripId))
      ..orderBy([(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.asc)]);

    final results = await query.get();
    return results.map((r) => models.Stop(
      id: r.id,
      tripId: r.tripId,
      clientId: r.clientId,
      kind: r.kind,
      plannedLatLng: r.plannedLatLng,
      actualLatLng: r.actualLatLng,
      actualAddress: r.actualAddress,
      timestamp: r.timestamp,
      status: r.status,
      note: r.note,
      photoPath: r.photoPath,
      signaturePath: r.signaturePath,
      accuracy: r.accuracy,
      speed: r.speed,
    )).toList();
  }

  /// Get client status for today's trip
  Future<Map<String, String>> getClientStatus({
    required String tripId,
    required List<Client> clients,
  }) async {
    final stops = await getTripStops(tripId);
    final statusMap = <String, String>{};

    for (final client in clients) {
      final clientStops = stops.where((s) => s.clientId == client.id).toList();
      final pickup = clientStops.firstWhere(
        (s) => s.kind == 'pickup' && s.status == 'done',
        orElse: () => clientStops.firstWhere((s) => s.kind == 'pickup', orElse: () => models.Stop(
          tripId: tripId,
          clientId: client.id,
          kind: 'pickup',
          status: 'pending',
        )),
      );
      final dropoff = clientStops.firstWhere(
        (s) => s.kind == 'dropoff' && s.status == 'done',
        orElse: () => clientStops.firstWhere((s) => s.kind == 'dropoff', orElse: () => models.Stop(
          tripId: tripId,
          clientId: client.id,
          kind: 'dropoff',
          status: 'pending',
        )),
      );

      if (pickup.status == 'done' && dropoff.status == 'done') {
        statusMap[client.id] = 'Dropped';
      } else if (pickup.status == 'done') {
        statusMap[client.id] = 'Picked';
      } else {
        statusMap[client.id] = 'Not picked';
      }
    }

    return statusMap;
  }

  /// Update a stop (e.g., edit note, timestamp)
  Future<models.Stop> updateStop({
    required String stopId,
    String? note,
    DateTime? timestamp,
    String? actualAddress,
  }) async {
    DebugLogger.info('✏️ Updating stop: $stopId');
    
    // Get existing stop
    final query = _database.select(_database.stops)
      ..where((s) => s.id.equals(stopId));
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      throw Exception('Stop not found');
    }

    // Update fields
    await (_database.update(_database.stops)..where((s) => s.id.equals(stopId)))
        .write(StopsCompanion(
      note: Value(note ?? existing.note),
      timestamp: Value(timestamp ?? existing.timestamp),
      actualAddress: Value(actualAddress ?? existing.actualAddress),
    ));

    // Get updated stop
    final updated = await query.getSingle();
    final stop = models.Stop(
      id: updated.id,
      tripId: updated.tripId,
      clientId: updated.clientId,
      kind: updated.kind,
      plannedLatLng: updated.plannedLatLng,
      actualLatLng: updated.actualLatLng,
      actualAddress: updated.actualAddress,
      timestamp: updated.timestamp,
      status: updated.status,
      note: updated.note,
      photoPath: updated.photoPath,
      signaturePath: updated.signaturePath,
      accuracy: updated.accuracy,
      speed: updated.speed,
    );

    // Queue for sync
    await _queueForSync('stop', stop.toJson(), 'update');

    notifyListeners();
    DebugLogger.success('✅ Stop updated successfully');
    return stop;
  }

  /// Delete a stop
  Future<void> deleteStop(String stopId) async {
    DebugLogger.info('🗑️ Deleting stop: $stopId');
    
    // Get stop before deleting (for sync)
    final query = _database.select(_database.stops)
      ..where((s) => s.id.equals(stopId));
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      throw Exception('Stop not found');
    }

    // Delete from database
    await (_database.delete(_database.stops)..where((s) => s.id.equals(stopId))).go();

    // Note: We don't queue delete operations for sync as FileMaker doesn't support soft deletes
    // If you need to track deletions, you could add a 'deleted' flag instead
    
    notifyListeners();
    DebugLogger.success('✅ Stop deleted successfully');
  }

  /// Queue item for offline sync
  Future<void> _queueForSync(String entity, Map<String, dynamic> payload, String op) async {
    await _database.into(_database.outboxes).insert(
      OutboxesCompanion.insert(
        entity: entity,
        payloadJson: jsonEncode(payload),
        op: op,
        createdAt: DateTime.now(),
        retries: const Value(0),
        synced: const Value(false),
      ),
    );
  }
}

