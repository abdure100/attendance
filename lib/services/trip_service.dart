import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../models/trip.dart' as models;
import '../models/stop.dart' as models;
import '../models/client.dart';
import '../database/app_database.dart';
import 'location_service.dart';
import 'filemaker_service.dart';
import 'offline_sync_service.dart';
import '../utils/debug_logger.dart';

/// Service for managing trips and stops
class TripService extends ChangeNotifier {
  final AppDatabase _database;
  // ignore: unused_field
  final FileMakerService? _fileMakerService; // Reserved for future sync implementation

  TripService(this._database, [this._fileMakerService]);

  /// Create a new trip for today
  /// Auto-creates trip when driver starts route
  /// If offlineSyncService is provided, syncs immediately and uses FileMaker PrimaryKey as tripId
  Future<models.Trip> createTodayTrip({
    required String driverId,
    String? routeName,
    String? vehicleId,
    required String direction, // "AM" | "PM"
    OfflineSyncService? offlineSyncService,
    FileMakerService? fileMakerService,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check local database for existing trip
    final existingTrip = await getTodayTrip(driverId: driverId, direction: direction);
    if (existingTrip != null) {
      DebugLogger.log('💾 Found existing trip in local database: ${existingTrip.id}');
      return existingTrip;
    }
    DebugLogger.log('💾 No existing trip found in local database...');

    // IMPORTANT: Check FileMaker for existing trip BEFORE creating a new one
    // This prevents duplicate trips when user logs in again
    if (fileMakerService != null) {
      DebugLogger.log('🔍 Checking FileMaker for existing trip...');
      final dateStr = '${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}/${today.year}';
      final existingPrimaryKey = await fileMakerService.findTripPrimaryKey(driverId, dateStr, direction);
      
      if (existingPrimaryKey != null && existingPrimaryKey.isNotEmpty) {
        DebugLogger.success('✅ Found existing trip in FileMaker with PrimaryKey: $existingPrimaryKey');
        
        // Create trip object with the existing PrimaryKey
        final trip = models.Trip(
          id: existingPrimaryKey,
          date: today,
          routeName: routeName,
          driverId: driverId,
          vehicleId: vehicleId,
          direction: direction,
          status: 'pending',
          createdAt: now,
        );
        
        // Save to local database (use insertOnConflictUpdate in case it already exists)
        DebugLogger.log('💾 Saving existing trip to local database with PrimaryKey: $existingPrimaryKey');
        await _database.into(_database.trips).insertOnConflictUpdate(
          TripsCompanion.insert(
            id: existingPrimaryKey,
            date: today,
            routeName: Value(routeName),
            driverId: driverId,
            vehicleId: Value(vehicleId),
            direction: direction,
            status: const Value('pending'),
            createdAt: Value(now),
          ),
        );
        DebugLogger.success('✅ Existing trip saved to local database');
        
        notifyListeners();
        return trip;
      }
      DebugLogger.log('📝 No existing trip found in FileMaker, creating new one...');
    }

    // Create trip with temporary ID (will be replaced with PrimaryKey if syncing immediately)
    final tempTripId = 'trip_${driverId}_${today.millisecondsSinceEpoch}_$direction';
    
    var trip = models.Trip(
      id: tempTripId,
      date: today,
      routeName: routeName,
      driverId: driverId,
      vehicleId: vehicleId,
      direction: direction,
      status: 'pending',
      createdAt: now,
    );

    String finalTripId = tempTripId;

    // If offlineSyncService is provided, sync immediately and get PrimaryKey
    if (offlineSyncService != null) {
      DebugLogger.info('🔄 Syncing trip immediately to get PrimaryKey...');
      final primaryKey = await offlineSyncService.syncTripImmediately(trip);
      
      if (primaryKey != null && primaryKey.isNotEmpty && !primaryKey.startsWith('trip_')) {
        DebugLogger.success('✅ Got PrimaryKey from FileMaker: $primaryKey');
        DebugLogger.log('✅ Trip will be saved with PrimaryKey as ID (not temporary ID)');
        DebugLogger.log('📝 PrimaryKey to save: $primaryKey');
        finalTripId = primaryKey;
        // Update trip object with PrimaryKey
        trip = trip.copyWith(id: primaryKey);
        DebugLogger.log('✅ Trip object updated with PrimaryKey: ${trip.id}');
      } else {
        DebugLogger.error('❌ Could not get PrimaryKey from FileMaker', null);
        DebugLogger.warn('⚠️ Using temporary id: $tempTripId (will sync later)');
        DebugLogger.warn('⚠️ Stops created with this tripId will need to be updated when trip syncs');
        // Queue for sync later
        await _queueForSync('trip', trip.toJson(), 'create');
        DebugLogger.log('💾 Trip queued for sync');
      }
    } else {
      DebugLogger.warn('⚠️ No offlineSyncService provided - trip will use temporary ID and sync later');
      // Queue for sync later
      await _queueForSync('trip', trip.toJson(), 'create');
      DebugLogger.log('💾 Trip queued for sync');
    }

    // Save to local database
    DebugLogger.log('💾 Saving trip to local database with ID: $finalTripId');
    DebugLogger.log('   This is the FileMaker PrimaryKey that will be used for stops');
    await _database.into(_database.trips).insert(
      TripsCompanion.insert(
        id: finalTripId,
        date: today,
        routeName: Value(routeName),
        driverId: driverId,
        vehicleId: Value(vehicleId),
        direction: direction,
        status: const Value('pending'),
        createdAt: Value(now),
      ),
    );
    DebugLogger.success('✅ Trip saved to local database with PrimaryKey: $finalTripId');
    DebugLogger.log('   All stops created for this trip will use tripId: $finalTripId');

    notifyListeners();
    
    // Return trip with final id (PrimaryKey if synced, temp id otherwise)
    DebugLogger.log('✅ Returning trip with PrimaryKey: ${trip.id}');
    return trip;
  }

  /// Update trip id in database (used when replacing temp id with PrimaryKey)
  /// Also updates pending sync items that reference the old tripId
  Future<void> updateTripId(String oldId, String newId, {OfflineSyncService? offlineSyncService}) async {
    DebugLogger.log('🔄 Updating trip id from $oldId to $newId');
    // Update local database
    await (_database.update(_database.trips)..where((t) => t.id.equals(oldId)))
      .write(TripsCompanion(id: Value(newId)));
    
    // Also update any stops that reference the old tripId
    await (_database.update(_database.stops)..where((s) => s.tripId.equals(oldId)))
      .write(StopsCompanion(tripId: Value(newId)));
    
    DebugLogger.success('✅ Trip and stops updated with new id: $newId');
    
    // Update pending sync items that reference the old tripId
    if (offlineSyncService != null) {
      DebugLogger.log('🔄 Updating pending sync items with old tripId: $oldId');
      try {
        final query = _database.select(_database.outboxes)
          ..where((o) => o.synced.equals(false));
        final items = await query.get();
        
        int updatedCount = 0;
        for (final item in items) {
          try {
            final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
            
            // Update stops that reference the old tripId
            if (item.entity == 'stop' && payload['tripId'] == oldId) {
              payload['tripId'] = newId;
              await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
                .write(OutboxesCompanion(payloadJson: Value(jsonEncode(payload))));
              updatedCount++;
              DebugLogger.log('✅ Updated pending sync item: stop with new tripId: $newId');
            }
          } catch (e) {
            DebugLogger.warn('Error updating pending sync item ${item.id}: $e');
          }
        }
        
        if (updatedCount > 0) {
          DebugLogger.success('✅ Updated $updatedCount pending sync item(s) with new tripId: $newId');
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Error updating pending sync items', e, stackTrace);
      }
    }
    
    notifyListeners();
  }

  /// Get today's trip for a driver
  /// Get a trip by its ID
  Future<models.Trip?> getTripById(String tripId) async {
    // Read from local database
    final query = _database.select(_database.trips)
      ..where((t) => t.id.equals(tripId));
    
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

  /// Sync stops from FileMaker to local database for a given tripId
  /// This ensures local DB has the latest stops from server
  Future<void> syncStopsFromFileMaker({
    required String tripId,
    required FileMakerService fileMakerService,
  }) async {
    DebugLogger.log('🔄 Syncing stops from FileMaker for tripId: $tripId');
    
    try {
      // Fetch stops from FileMaker
      final fileMakerStops = await fileMakerService.getStopsByTripId(tripId);
      
      if (fileMakerStops.isEmpty) {
        DebugLogger.log('   No stops found in FileMaker for this trip');
        return;
      }
      
      DebugLogger.log('   Found ${fileMakerStops.length} stops in FileMaker');
      
      // Get existing local stops for this trip
      final localStopsQuery = _database.select(_database.stops)
        ..where((s) => s.tripId.equals(tripId));
      final localStops = await localStopsQuery.get();
      final localStopIds = localStops.map((s) => s.id).toSet();
      
      int addedCount = 0;
      int skippedCount = 0;
      
      for (final stopData in fileMakerStops) {
        final stopId = stopData['PrimaryKey']?.toString();
        if (stopId == null || stopId.isEmpty) {
          DebugLogger.warn('   ⚠️ Stop missing PrimaryKey, skipping');
          continue;
        }
        
        // Skip if already exists locally
        if (localStopIds.contains(stopId)) {
          skippedCount++;
          continue;
        }
        
        // Parse stop data
        final clientId = stopData['clientId']?.toString() ?? '';
        final kind = stopData['kind']?.toString() ?? '';
        final direction = stopData['direction']?.toString();
        final actualLatLng = stopData['actualLatLng']?.toString();
        final actualAddress = stopData['actualAddress']?.toString();
        final status = stopData['status']?.toString() ?? 'done';
        final note = stopData['note']?.toString();
        
        // Parse timestamp - FileMaker may return as JSON object {"date":"M/D/YYYY","time":"H:MM:SS"}
        DateTime? timestamp;
        if (stopData['timestamp'] != null) {
          try {
            final tsValue = stopData['timestamp'];
            if (tsValue is Map) {
              // FileMaker format: {"date":"12/6/2025","time":"3:54:11"}
              final dateStr = tsValue['date']?.toString();
              final timeStr = tsValue['time']?.toString();
              if (dateStr != null && timeStr != null) {
                // Parse MM/DD/YYYY and H:MM:SS
                final dateParts = dateStr.split('/');
                final timeParts = timeStr.split(':');
                if (dateParts.length == 3 && timeParts.length >= 2) {
                  final month = int.tryParse(dateParts[0]) ?? 1;
                  final day = int.tryParse(dateParts[1]) ?? 1;
                  final year = int.tryParse(dateParts[2]) ?? 2025;
                  final hour = int.tryParse(timeParts[0]) ?? 0;
                  final minute = int.tryParse(timeParts[1]) ?? 0;
                  final second = timeParts.length > 2 ? (int.tryParse(timeParts[2]) ?? 0) : 0;
                  timestamp = DateTime(year, month, day, hour, minute, second);
                }
              }
            } else {
              // Try standard ISO format
              timestamp = DateTime.tryParse(tsValue.toString());
            }
          } catch (e) {
            DebugLogger.warn('Failed to parse timestamp: ${stopData['timestamp']}');
          }
        }
        
        // Parse accuracy and speed
        double? accuracy;
        double? speed;
        if (stopData['accuracy'] != null) {
          accuracy = double.tryParse(stopData['accuracy'].toString());
        }
        if (stopData['speed'] != null) {
          speed = double.tryParse(stopData['speed'].toString());
        }
        
        // Check if stop is deleted in FileMaker (has deleted_at timestamp)
        // If deleted_at is set, mark as deleted; if cleared, reset to active
        int deleted = 0;
        DateTime? deletedAt;
        if (stopData['deleted_at'] != null && stopData['deleted_at'].toString().isNotEmpty) {
          deleted = 1;
          deletedAt = DateTime.tryParse(stopData['deleted_at'].toString());
          DebugLogger.log('   ⚠️ Stop $stopId has deleted_at, marking as deleted');
        } else {
          // No deleted_at means stop is active (or was reset)
          deleted = 0;
          deletedAt = null;
        }
        
        // Insert into local database (use insertOnConflictUpdate in case it already exists)
        try {
          await _database.into(_database.stops).insertOnConflictUpdate(
            StopsCompanion.insert(
              id: stopId,
              tripId: tripId,
              clientId: clientId,
              kind: kind,
              direction: Value(direction),
              actualLatLng: Value(actualLatLng),
              actualAddress: Value(actualAddress),
              timestamp: Value(timestamp),
              status: status,
              note: Value(note),
              accuracy: Value(accuracy),
              speed: Value(speed),
              deleted: Value(deleted),
              deletedAt: Value(deletedAt),
            ),
          );
          addedCount++;
          if (deleted == 1) {
            DebugLogger.log('   🗑️ Added deleted stop: $kind for client $clientId');
          } else {
            DebugLogger.log('   ✅ Added stop: $kind for client $clientId');
          }
        } catch (e) {
          DebugLogger.warn('   ⚠️ Error adding stop $stopId: $e');
        }
      }
      
      DebugLogger.success('✅ Synced stops from FileMaker: $addedCount added, $skippedCount already existed');
    } catch (e, stackTrace) {
      DebugLogger.error('Error syncing stops from FileMaker', e, stackTrace);
    }
  }

  /// Record a pickup or dropoff stop
  /// 
  /// IMPORTANT: tripId must be the PrimaryKey from dapi-api_trips
  /// Relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId
  Future<models.Stop> recordStop({
    required String tripId, // Must be the PrimaryKey from dapi-api_trips
    required String clientId,
    required String kind, // "pickup" | "dropoff"
    String? note,
    bool requirePhoto = false,
    bool requireSignature = false,
    String? photoPath,
    String? signatureBase64, // Base64 encoded PNG signature image
    OfflineSyncService? offlineSyncService, // Optional: for direct sync to FileMaker (debugging)
    bool syncDirectly = false, // If true, sync directly to FileMaker instead of queuing
  }) async {
    // Validate that we're using PrimaryKey, not temporary ID
    if (tripId.startsWith('trip_')) {
      DebugLogger.warn('⚠️ WARNING: Creating stop with temporary tripId: $tripId');
      DebugLogger.warn('⚠️ This should be a FileMaker PrimaryKey. The trip may not have been synced yet.');
    } else {
      DebugLogger.success('✅ Using FileMaker PrimaryKey as tripId: $tripId');
    }
    
    DebugLogger.info('═══════════════════════════════════════════════════════');
    DebugLogger.info('📍 STEP 1: Starting to record $kind stop');
    DebugLogger.info('   Client ID: $clientId');
    DebugLogger.info('   Trip ID: $tripId');
    DebugLogger.info('   Kind: $kind');
    DebugLogger.info('═══════════════════════════════════════════════════════');
    
    // Get trip direction from local database
    DebugLogger.log('📍 STEP 2: Getting trip direction from database...');
    String? tripDirection;
    try {
      final tripQuery = _database.select(_database.trips)
        ..where((t) => t.id.equals(tripId));
      final tripData = await tripQuery.getSingleOrNull();
      if (tripData != null) {
        tripDirection = tripData.direction;
        DebugLogger.log('✅ Got trip direction: $tripDirection');
      } else {
        DebugLogger.warn('⚠️ Trip not found in database, direction will be null');
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Error getting trip direction', e, stackTrace);
    }
    
    // Validate dropoff from local database (exclude deleted stops)
    if (kind == 'dropoff') {
      DebugLogger.log('📍 STEP 3: Validating dropoff - checking for existing pickup...');
      final pickupExists = _database.select(_database.stops)
        ..where((s) => 
          s.tripId.equals(tripId) &
          s.clientId.equals(clientId) &
          s.kind.equals('pickup') &
          s.status.equals('done') &
          s.deleted.equals(0)
        );
      final pickups = await pickupExists.get();
      if (pickups.isEmpty) {
        DebugLogger.error('Cannot drop off without pickup', null);
        throw Exception('Cannot drop off without pickup');
      }
      DebugLogger.success('✅ Found existing pickup, proceeding with dropoff');
    }

    // Get current location
    DebugLogger.log('📍 STEP 4: Getting GPS location...');
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
    DebugLogger.log('📍 STEP 5: Reverse geocoding address...');
    String? address;
    try {
      DebugLogger.log('   Coordinates: lat=$lat, lng=$lng');
      address = await LocationService.reverseGeocode(lat, lng);
      if (address != null && address.isNotEmpty) {
        DebugLogger.success('✅ Address: $address');
      } else {
        DebugLogger.warn('⚠️ Reverse geocoding returned null or empty address');
        DebugLogger.log('This is okay - address is optional and can be backfilled later');
      }
    } catch (e, stackTrace) {
      DebugLogger.warn('Could not reverse geocode: $e');
      DebugLogger.log('Stack trace: $stackTrace');
      DebugLogger.log('Continuing anyway - address is optional and can be backfilled on sync');
      // Continue anyway - address can be backfilled on sync
    }

    // Validate GPS accuracy (spoofing protection)
    if (accuracy != null && accuracy > 100) {
      DebugLogger.warn('⚠️ GPS accuracy is low: ${accuracy}m');
      // Still allow but flag it
    }

    DebugLogger.log('📍 STEP 6: Creating stop object...');
    final stopId = 'stop_${tripId}_${clientId}_${kind}_${DateTime.now().millisecondsSinceEpoch}';
    DebugLogger.log('   Stop ID: $stopId');
    DebugLogger.log('   Trip ID (PrimaryKey): $tripId');
    if (tripId.startsWith('trip_')) {
      DebugLogger.warn('   ⚠️ WARNING: Using temporary tripId. This should be a FileMaker PrimaryKey!');
    } else {
      DebugLogger.success('   ✅ Using FileMaker PrimaryKey as tripId: $tripId');
      DebugLogger.log('   ✅ This PrimaryKey will be used in FileMaker relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId');
    }
    DebugLogger.log('   Client ID: $clientId');
    DebugLogger.log('   Kind: $kind');
    DebugLogger.log('   Direction: $tripDirection');
    DebugLogger.log('   Location: ${LocationService.formatLatLng(lat, lng)}');
    DebugLogger.log('   Address: ${address ?? "N/A"}');
    
    final stop = models.Stop(
      id: stopId,
      tripId: tripId, // This should be the FileMaker PrimaryKey
      clientId: clientId,
      kind: kind,
      direction: tripDirection,
      actualLatLng: LocationService.formatLatLng(lat, lng),
      actualAddress: address,
      timestamp: DateTime.now(),
      status: 'done',
      note: note,
      photoPath: photoPath,
      signatureBase64: signatureBase64, // Base64 encoded signature for FileMaker
      accuracy: accuracy,
      speed: speed,
    );

    // Save to local database
    DebugLogger.log('📍 STEP 7: Saving stop to local database...');
    try {
      await _database.into(_database.stops).insert(
        StopsCompanion.insert(
          id: stopId,
          tripId: tripId,
          clientId: clientId,
          kind: kind,
          direction: Value(tripDirection), // Can be null for existing records
          actualLatLng: Value(LocationService.formatLatLng(lat, lng)),
          actualAddress: Value(address),
          timestamp: Value(DateTime.now()),
          status: 'done',
          note: Value(note),
          photoPath: Value(photoPath),
          signatureBase64: Value(signatureBase64), // Base64 encoded signature
          accuracy: Value(accuracy),
          speed: Value(speed),
        ),
      );
      DebugLogger.success('✅ Stop saved to local database');
    } catch (e, stackTrace) {
      DebugLogger.error('Error saving stop to database', e, stackTrace);
      rethrow;
    }

    // Sync to FileMaker (directly for debugging, or queue for later)
    bool syncedSuccessfully = false;
    if (syncDirectly && offlineSyncService != null) {
      DebugLogger.log('📍 STEP 8: Syncing directly to FileMaker (DEBUG MODE)...');
      try {
        final success = await offlineSyncService.syncStopImmediately(stop);
        if (success) {
          DebugLogger.success('✅ Stop synced directly to FileMaker');
          syncedSuccessfully = true;
        } else {
          DebugLogger.warn('⚠️ Direct sync failed, will queue for later sync');
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Error syncing stop directly to FileMaker', e, stackTrace);
        DebugLogger.warn('⚠️ Will queue for later sync');
        // Don't rethrow - the stop is saved locally
      }
    }
    
    // Queue for sync if not synced directly (or if direct sync failed)
    if (!syncedSuccessfully) {
      DebugLogger.log('📍 STEP 8b: Queuing stop for sync...');
      DebugLogger.log('   Stop will be synced to FileMaker when sync is triggered');
      try {
        await _queueForSync('stop', stop.toJson(), 'create');
        DebugLogger.success('✅ Stop queued for sync');
      } catch (e, stackTrace) {
        DebugLogger.error('Error queueing stop for sync', e, stackTrace);
        // Don't rethrow - the stop is saved locally, sync can happen later
      }
    }

    notifyListeners();
    DebugLogger.info('═══════════════════════════════════════════════════════');
    DebugLogger.success('✅ ${kind.toUpperCase()} STOP RECORDED SUCCESSFULLY');
    DebugLogger.info('   Stop ID: $stopId');
    DebugLogger.info('   Ready for sync to FileMaker');
    DebugLogger.info('═══════════════════════════════════════════════════════');
    return stop;
  }

  /// Get all stops for a trip (excludes soft-deleted stops where deleted=1)
  Future<List<models.Stop>> getTripStops(String tripId) async {
    // First, let's see ALL stops for this trip (for debugging)
    final allStopsQuery = _database.select(_database.stops)
      ..where((s) => s.tripId.equals(tripId));
    final allStops = await allStopsQuery.get();
    DebugLogger.log('📊 DEBUG: Total stops for trip $tripId: ${allStops.length}');
    for (final s in allStops) {
      DebugLogger.log('   - Stop ${s.id}: deleted=${s.deleted}, kind=${s.kind}');
    }
    
    final query = _database.select(_database.stops)
      ..where((s) => s.tripId.equals(tripId) & s.deleted.equals(0))
      ..orderBy([(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.asc)]);

    final results = await query.get();
    DebugLogger.log('📊 DEBUG: Filtered stops (deleted=0): ${results.length}');
    return results.map((r) => models.Stop(
      id: r.id,
      tripId: r.tripId,
      clientId: r.clientId,
      kind: r.kind,
      direction: r.direction,
      plannedLatLng: r.plannedLatLng,
      actualLatLng: r.actualLatLng,
      actualAddress: r.actualAddress,
      timestamp: r.timestamp,
      status: r.status,
      note: r.note,
      photoPath: r.photoPath,
      signatureBase64: r.signatureBase64,
      accuracy: r.accuracy,
      speed: r.speed,
      deleted: r.deleted,
      deletedAt: r.deletedAt,
    )).toList();
  }

  /// Get client status for today's trip
  Future<Map<String, String>> getClientStatus({
    required String tripId,
    required List<Client> clients,
  }) async {
    final stops = await getTripStops(tripId);
    final statusMap = <String, String>{};
    
    // Get trip direction for default stops
    String? tripDirection;
    try {
      final tripQuery = _database.select(_database.trips)
        ..where((t) => t.id.equals(tripId));
      final tripData = await tripQuery.getSingleOrNull();
      tripDirection = tripData?.direction;
    } catch (e) {
      // Ignore error, direction will be null
    }

    for (final client in clients) {
      final clientStops = stops.where((s) => s.clientId == client.id).toList();
      final pickup = clientStops.firstWhere(
        (s) => s.kind == 'pickup' && s.status == 'done',
        orElse: () => clientStops.firstWhere((s) => s.kind == 'pickup', orElse: () => models.Stop(
          tripId: tripId,
          clientId: client.id,
          kind: 'pickup',
          direction: tripDirection,
          status: 'pending',
        )),
      );
      final dropoff = clientStops.firstWhere(
        (s) => s.kind == 'dropoff' && s.status == 'done',
        orElse: () => clientStops.firstWhere((s) => s.kind == 'dropoff', orElse: () => models.Stop(
          tripId: tripId,
          clientId: client.id,
          kind: 'dropoff',
          direction: tripDirection,
          status: 'pending',
        )),
      );

      if (pickup.status == 'done' && dropoff.status == 'done') {
        // Format times for display
        final pickupTime = _formatTimeOnly(pickup.timestamp);
        final dropoffTime = _formatTimeOnly(dropoff.timestamp);
        statusMap[client.id] = 'Dropped ($pickupTime / $dropoffTime)';
      } else if (pickup.status == 'done') {
        final pickupTime = _formatTimeOnly(pickup.timestamp);
        statusMap[client.id] = 'Picked ($pickupTime)';
      } else {
        statusMap[client.id] = 'Not picked';
      }
    }

    return statusMap;
  }
  
  /// Format DateTime to time only string (e.g., "3:54 PM")
  String _formatTimeOnly(DateTime? dateTime) {
    if (dateTime == null) return '--';
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
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
      direction: updated.direction,
      plannedLatLng: updated.plannedLatLng,
      actualLatLng: updated.actualLatLng,
      actualAddress: updated.actualAddress,
      timestamp: updated.timestamp,
      status: updated.status,
      note: updated.note,
      photoPath: updated.photoPath,
      signatureBase64: updated.signatureBase64,
      accuracy: updated.accuracy,
      speed: updated.speed,
      deleted: updated.deleted,
      deletedAt: updated.deletedAt,
    );

    // Queue for sync
    await _queueForSync('stop', stop.toJson(), 'update');
    DebugLogger.log('💾 Stop update queued for sync');

    notifyListeners();
    DebugLogger.success('✅ Stop updated successfully');
    return stop;
  }

  /// Soft delete a stop (sets deleted=1 and deletedAt timestamp)
  Future<void> deleteStop(String stopId, {OfflineSyncService? offlineSyncService}) async {
    DebugLogger.info('🗑️ Soft deleting stop: $stopId');
    
    // Get stop before updating
    final query = _database.select(_database.stops)
      ..where((s) => s.id.equals(stopId));
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      throw Exception('Stop not found');
    }

    // Remove pending sync items for this stop
    await _removePendingSyncItems('stop', stopId);

    // Soft delete: set deleted=1 and deletedAt timestamp
    final now = DateTime.now();
    await (_database.update(_database.stops)..where((s) => s.id.equals(stopId)))
        .write(StopsCompanion(
          deleted: const Value(1),
          deletedAt: Value(now),
        ));

    // Only queue for sync if stop exists in FileMaker (has UUID-style PrimaryKey, not temp ID)
    final isFileMakerStop = !existing.id.startsWith('stop_');
    
    if (isFileMakerStop) {
      // Queue for sync to update FileMaker with deleted_at timestamp
      final stop = models.Stop(
        id: existing.id,
        tripId: existing.tripId,
        clientId: existing.clientId,
        kind: existing.kind,
        direction: existing.direction,
        actualLatLng: existing.actualLatLng,
        actualAddress: existing.actualAddress,
        timestamp: existing.timestamp,
        status: existing.status,
        note: existing.note,
        photoPath: existing.photoPath,
        signatureBase64: existing.signatureBase64,
        accuracy: existing.accuracy,
        speed: existing.speed,
        deleted: 1,
        deletedAt: now,
      );
      await _queueForSync('stop', stop.toJson(), 'update');
      DebugLogger.log('💾 Stop soft delete queued for sync (deleted_at will be sent to FileMaker)');
    } else {
      DebugLogger.log('💾 Stop was local-only (never synced to FileMaker), skipping sync');
    }
    
    notifyListeners();
    DebugLogger.success('✅ Stop soft deleted successfully');
  }

  /// Delete a trip and all its stops
  Future<void> deleteTrip(String tripId, {OfflineSyncService? offlineSyncService}) async {
    DebugLogger.info('🗑️ Deleting trip: $tripId');
    
    // Get trip before deleting
    final tripQuery = _database.select(_database.trips)
      ..where((t) => t.id.equals(tripId));
    final trip = await tripQuery.getSingleOrNull();
    
    if (trip == null) {
      throw Exception('Trip not found');
    }

    // Remove pending sync items for this trip (and its stops)
    await _removePendingSyncItems('trip', tripId);

    // Delete all stops for this trip first
    await (_database.delete(_database.stops)..where((s) => s.tripId.equals(tripId))).go();
    DebugLogger.log('✅ Deleted all stops for trip: $tripId');

    // Delete the trip
    await (_database.delete(_database.trips)..where((t) => t.id.equals(tripId))).go();
    
    notifyListeners();
    DebugLogger.success('✅ Trip and all stops deleted successfully');
  }

  /// Remove pending sync items for a specific entity (trip or stop)
  /// This is called when an entity is deleted locally
  Future<void> _removePendingSyncItems(String entity, String entityId) async {
    try {
      DebugLogger.log('🗑️ Removing pending sync items for $entity: $entityId');
      
      // Get all pending sync items
      final query = _database.select(_database.outboxes)
        ..where((o) => o.synced.equals(false));
      final items = await query.get();
      
      int removedCount = 0;
      for (final item in items) {
        try {
          final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
          
          // Check if this item matches the deleted entity
          bool shouldRemove = false;
          
          if (entity == 'trip') {
            // Remove trip items
            if (item.entity == 'trip' && 
                (payload['id'] == entityId || payload['PrimaryKey'] == entityId)) {
              shouldRemove = true;
            }
            // Also remove any stops that reference this trip
            if (item.entity == 'stop' && payload['tripId'] == entityId) {
              shouldRemove = true;
            }
          } else if (entity == 'stop') {
            // Remove stop items
            if (item.entity == 'stop' && 
                (payload['id'] == entityId || payload['PrimaryKey'] == entityId)) {
              shouldRemove = true;
            }
          }
          
          if (shouldRemove) {
            await (_database.delete(_database.outboxes)..where((o) => o.id.equals(item.id))).go();
            removedCount++;
            DebugLogger.log('✅ Removed pending sync item: ${item.entity} (${item.op})');
          }
        } catch (e) {
          DebugLogger.warn('Error parsing payload for item ${item.id}: $e');
        }
      }
      
      if (removedCount > 0) {
        DebugLogger.success('✅ Removed $removedCount pending sync item(s) for $entity: $entityId');
      } else {
        DebugLogger.log('ℹ️ No pending sync items found for $entity: $entityId');
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Error removing pending sync items', e, stackTrace);
    }
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

