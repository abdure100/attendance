import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/trip.dart' as models;
import '../models/stop.dart' as models;
import '../models/attendance.dart' as models;
import '../utils/debug_logger.dart';
import 'filemaker_service.dart';
import 'sync_helpers.dart';

/// Service for syncing offline data to FileMaker
class OfflineSyncService extends ChangeNotifier {
  final AppDatabase _database;
  final FileMakerService? _fileMakerService;
  BuildContext? _context;

  OfflineSyncService(this._database, [this._fileMakerService]);

  /// Set context for accessing FileMakerService from Provider
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Get FileMakerService from Provider if available
  FileMakerService? _getFileMakerService() {
    if (_fileMakerService != null) {
      DebugLogger.log('Using FileMakerService from constructor');
      return _fileMakerService;
    }
    if (_context != null) {
      try {
        final service = Provider.of<FileMakerService>(_context!, listen: false);
        DebugLogger.log('Retrieved FileMakerService from Provider');
        return service;
      } catch (e) {
        DebugLogger.error('Could not get FileMakerService from Provider', e);
        return null;
      }
    }
    DebugLogger.warn('No FileMakerService available - _fileMakerService is null and _context is null');
    return null;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      // connectivity_plus 5.x returns a single ConnectivityResult
      return connectivityResult == ConnectivityResult.mobile ||
             connectivityResult == ConnectivityResult.wifi ||
             connectivityResult == ConnectivityResult.ethernet;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get count of pending sync items
  Future<int> getPendingCount() async {
    final query = _database.select(_database.outboxes)
      ..where((o) => o.synced.equals(false));
    final results = await query.get();
    return results.length;
  }

  /// Remove pending sync items for a specific entity (trip or stop)
  /// This is called when an entity is deleted locally
  Future<void> removePendingSyncItems(String entity, String entityId) async {
    try {
      DebugLogger.log('🗑️ Removing pending sync items for $entity: $entityId');
      
      // Get all pending sync items (we need to check all items when deleting trips to find related stops)
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
        notifyListeners(); // Notify listeners that pending count changed
      } else {
        DebugLogger.log('ℹ️ No pending sync items found for $entity: $entityId');
      }
    } catch (e, stackTrace) {
      DebugLogger.error('Error removing pending sync items', e, stackTrace);
    }
  }

  /// Sync all pending items
  Future<SyncResult> syncAll() async {
    DebugLogger.info('═══════════════════════════════════════════════════════');
    DebugLogger.info('🔄 SYNC PROCESS STARTING');
    DebugLogger.info('═══════════════════════════════════════════════════════');
    
    DebugLogger.log('📍 SYNC STEP 1: Checking FileMaker service...');
    final fileMakerService = _getFileMakerService();
    if (fileMakerService == null) {
      DebugLogger.error('❌ FileMaker service not available', null);
      return SyncResult(success: false, error: 'FileMaker service not available');
    }
    DebugLogger.success('✅ FileMaker service available');

    DebugLogger.log('📍 SYNC STEP 2: Checking internet connection...');
    final isConnected = await isOnline();
    if (!isConnected) {
      DebugLogger.warn('❌ No internet connection');
      return SyncResult(success: false, error: 'No internet connection');
    }
    DebugLogger.success('✅ Online');

    DebugLogger.log('📍 SYNC STEP 3: Checking for pending items...');

    // Get all unsynced items
    // Order by entity type first (trips before stops, stops before attendance)
    // Then by createdAt to maintain chronological order within each type
    final query = _database.select(_database.outboxes)
      ..where((o) => o.synced.equals(false));
    
    final allItems = await query.get();
    
    // Sort manually to ensure trips sync before stops, stops before attendance
    final items = allItems.toList()..sort((a, b) {
      // Define priority: trip = 1, stop = 2, attendance = 3
      final priorityA = a.entity == 'trip' ? 1 : (a.entity == 'stop' ? 2 : 3);
      final priorityB = b.entity == 'trip' ? 1 : (b.entity == 'stop' ? 2 : 3);
      
      // First sort by entity priority
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      
      // Then sort by createdAt within same entity type
      return a.createdAt.compareTo(b.createdAt);
    });
    
    DebugLogger.info('📦 Found ${items.length} pending items to sync');
    DebugLogger.log('   Sync order: ${items.map((i) => '${i.entity}(${i.op})').join(', ')}');
    
    if (items.isEmpty) {
      DebugLogger.info('✅ No items to sync');
      return SyncResult(success: true, successCount: 0, failureCount: 0);
    }
    
    int successCount = 0;
    int failureCount = 0;
    String? lastError;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      try {
        DebugLogger.info('═══════════════════════════════════════════════════════');
        DebugLogger.info('📤 SYNC STEP ${i + 1}/${items.length}: ${item.entity.toUpperCase()} (${item.op})');
        DebugLogger.info('═══════════════════════════════════════════════════════');
        final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        DebugLogger.log('   Payload keys: ${payload.keys.toList()}');
        if (item.entity == 'stop') {
          DebugLogger.log('   Stop ID: ${payload['id'] ?? payload['PrimaryKey']}');
          final stopTripId = payload['tripId'];
          DebugLogger.log('   Trip ID in payload: $stopTripId');
          if (stopTripId != null) {
            if (stopTripId.startsWith('trip_')) {
              DebugLogger.warn('   ⚠️ WARNING: Stop has temporary tripId: $stopTripId');
              DebugLogger.warn('   ⚠️ This stop was queued before the trip got its FileMaker PrimaryKey');
            } else {
              DebugLogger.log('   ✅ Stop has tripId that looks like a PrimaryKey: $stopTripId');
            }
          }
          DebugLogger.log('   Client ID: ${payload['clientId']}');
          DebugLogger.log('   Kind: ${payload['kind']}');
        }
        
        bool success = false;
        DebugLogger.log('   Calling sync method for ${item.entity}...');
        switch (item.entity) {
          case 'trip':
            DebugLogger.log('   Syncing trip to FileMaker...');
            final primaryKey = await _syncTrip(payload, item.op);
            success = primaryKey != null;
            break;
          case 'stop':
            DebugLogger.log('   Syncing stop to FileMaker...');
            success = await _syncStop(payload, item.op);
            break;
          case 'attendance':
            DebugLogger.log('   Syncing attendance to FileMaker...');
            success = await _syncAttendance(payload, item.op);
            break;
          default:
            DebugLogger.warn('Unknown entity type: ${item.entity}');
        }
        
        DebugLogger.log('   Sync result: ${success ? "✅ SUCCESS" : "❌ FAILED"}');

        if (success) {
          DebugLogger.log('   Marking item as synced in database...');
          // Mark as synced
          await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
              .write(OutboxesCompanion(
            synced: const Value(true),
            syncedAt: Value(DateTime.now()),
          ));
          successCount++;
          DebugLogger.success('✅ Item ${i + 1} synced successfully');
        } else {
          // Increment retry count
          final newRetries = item.retries + 1;
          DebugLogger.warn('   Retry count: $newRetries/5');
          await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
              .write(OutboxesCompanion(
            retries: Value(newRetries),
          ));
          failureCount++;
          
          // Stop syncing if too many retries
          if (newRetries >= 5) {
            DebugLogger.error('❌ Max retries reached for item ${item.id}', null);
            lastError = 'Max retries reached for item ${item.id}';
            break;
          }
        }
      } catch (e, stackTrace) {
        DebugLogger.error('Error syncing item ${item.id}', e, stackTrace);
        failureCount++;
        lastError = e.toString();
        
        // Increment retry count
        final newRetries = item.retries + 1;
        await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
            .write(OutboxesCompanion(
          retries: Value(newRetries),
        ));
      }
    }

    notifyListeners();
    
    final result = SyncResult(
      success: failureCount == 0,
      successCount: successCount,
      failureCount: failureCount,
      error: lastError,
    );
    
    DebugLogger.info('═══════════════════════════════════════════════════════');
    DebugLogger.info('🔄 SYNC PROCESS COMPLETE');
    DebugLogger.info('   ✅ Succeeded: ${result.successCount}');
    DebugLogger.info('   ❌ Failed: ${result.failureCount}');
    if (result.error != null) {
      DebugLogger.error('   Last error: ${result.error}', null);
    }
    DebugLogger.info('═══════════════════════════════════════════════════════');
    
    return result;
  }

  /// Sync a trip immediately to FileMaker and return the PrimaryKey
  /// This is used when we need the PrimaryKey right away (e.g., for creating stops)
  Future<String?> syncTripImmediately(models.Trip trip) async {
    final syncPayload = SyncHelpers.prepareTripForSync(trip);
    return await _syncTrip(syncPayload, 'create');
  }

  /// Sync a trip to FileMaker
  /// Returns the PrimaryKey if successful, null otherwise
  Future<String?> _syncTrip(Map<String, dynamic> payload, String op) async {
    try {
      final fileMakerService = _getFileMakerService();
      if (fileMakerService == null) {
        DebugLogger.error('FileMakerService not available for trip sync', null);
        return null;
      }

      final trip = models.Trip.fromJson(payload);
      final syncPayload = SyncHelpers.prepareTripForSync(trip);
      
      // Remove PrimaryKey from payload for create operations (FileMaker generates it)
      final fieldData = Map<String, dynamic>.from(syncPayload);
      if (op == 'create') {
        fieldData.remove('PrimaryKey');
      }
      
            // Format date for FileMaker
            // FileMaker date fields may require MM/DD/YYYY format based on field settings
            // Try MM/DD/YYYY first (common FileMaker format), fallback to ISO if needed
            if (fieldData['date'] != null) {
              final date = trip.date;
              // Format as MM/DD/YYYY (FileMaker's common date format)
              fieldData['date'] = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
              DebugLogger.log('Formatted date for FileMaker: ${fieldData['date']} (MM/DD/YYYY from $date)');
              
              // Check if date is in the future (FileMaker validation might reject future dates)
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final tripDate = DateTime(date.year, date.month, date.day);
              if (tripDate.isAfter(today)) {
                DebugLogger.warn('⚠️ Trip date is in the future: ${fieldData['date']}');
                DebugLogger.warn('FileMaker validation may reject future dates. Check FileMaker field validation rules.');
              }
            }
      
      // Remove only FileMaker-managed timestamp fields (these are auto-managed by FileMaker)
      // FileMaker auto-generates CreationTimestamp, so we don't use createdAt
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      if (op == 'create') {
        fieldData.remove('createdAt'); // Remove createdAt - FileMaker uses CreationTimestamp instead (auto-generated)
      }
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Trip fieldData: $fieldData');
      DebugLogger.log('Trip fieldData keys: ${fieldData.keys.toList()}');
      DebugLogger.log('Trip fieldData values: ${fieldData.values.map((v) => v?.toString()).toList()}');
      DebugLogger.log('Date field value: ${fieldData['date']} (type: ${fieldData['date']?.runtimeType})');
      
      if (op == 'create') {
        DebugLogger.info('Creating trip: ${trip.id}');
        DebugLogger.log('Trip details: date=${trip.date}, driverId=${trip.driverId}, direction=${trip.direction}, status=${trip.status}');
        DebugLogger.log('Sending to FileMaker layout: dapi-api_trips');
        DebugLogger.log('Field names being sent: ${fieldData.keys.join(", ")}');
        var recordId = await fileMakerService.createRecord('dapi-api_trips', fieldData);
        
        // If regular creation fails, try manual method as fallback
        if (recordId == null) {
          DebugLogger.warn('⚠️ Regular trip creation failed, trying manual method as fallback...');
          try {
            final manualResult = await fileMakerService.manualCreateTrip(
              driverId: trip.driverId,
              direction: trip.direction,
              date: fieldData['date'] as String?,
              status: trip.status ?? 'pending',
            );
            if (manualResult['success'] == true) {
              recordId = manualResult['recordId']?.toString();
              DebugLogger.success('✅ Manual trip creation succeeded! RecordId: $recordId');
            } else {
              DebugLogger.error('❌ Manual trip creation also failed: ${manualResult['error']}', null);
            }
          } catch (e, stackTrace) {
            DebugLogger.error('Error in manual trip creation fallback', e, stackTrace);
          }
        }
        
        if (recordId != null) {
          DebugLogger.success('✅ Trip created successfully in FileMaker with recordId: $recordId');
          DebugLogger.log('Trip PrimaryKey: ${trip.id}, FileMaker recordId: $recordId');
          
          // Get the PrimaryKey from FileMaker
          DebugLogger.log('🔍 Fetching PrimaryKey from FileMaker for recordId: $recordId');
          final primaryKey = await fileMakerService.getPrimaryKeyFromRecordId('dapi-api_trips', recordId);
          
          if (primaryKey != null) {
            DebugLogger.success('✅ Got PrimaryKey from FileMaker: $primaryKey');
            return primaryKey;
          } else {
            DebugLogger.warn('⚠️ Could not get PrimaryKey from FileMaker, using recordId as fallback');
            return recordId; // Fallback to recordId if PrimaryKey not found
          }
        } else {
          DebugLogger.error('❌ Trip creation returned null recordId', null);
          DebugLogger.log('This usually means FileMaker rejected the record. Check:');
          DebugLogger.log('1. Does the dapi-api_trips layout exist?');
          DebugLogger.log('2. Is the "date" field on the dapi-api_trips layout? (case-sensitive: lowercase "date")');
          DebugLogger.log('3. Is the "date" field type set to Text (not Date)?');
          DebugLogger.log('4. Are there any script triggers (OnRecordCommit, OnRecordCreate) that might be validating?');
          DebugLogger.log('5. Do all field names match exactly? (case-sensitive)');
          DebugLogger.log('6. Check FileMaker Data API error logs for specific validation errors');
          DebugLogger.log('7. Try creating a record manually in FileMaker with the same data to see if it works');
          DebugLogger.log('8. Verify the field name is exactly "date" (lowercase) in FileMaker');
          return null;
        }
      } else if (op == 'update' && trip.id != null) {
        DebugLogger.info('Updating trip: ${trip.id}');
        // For updates, we need to find the FileMaker recordId by PrimaryKey first
        // because trip.id is a string PrimaryKey, not a numeric recordId
        try {
          final recordId = await fileMakerService.findRecordIdByPrimaryKey('dapi-api_trips', trip.id!);
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for PrimaryKey: ${trip.id}');
            final success = await fileMakerService.updateRecord('dapi-api_trips', recordId, fieldData);
            if (success) {
              DebugLogger.success('Trip updated successfully');
              // Return the PrimaryKey for successful updates
              return trip.id;
            } else {
              DebugLogger.error('Trip update failed', null);
              return null;
            }
          } else {
            DebugLogger.error('Could not find trip record with PrimaryKey: ${trip.id}', null);
            return null;
          }
        } catch (e, stackTrace) {
          DebugLogger.error('Error finding trip record for update', e, stackTrace);
          return null;
        }
      }
      return null;
    } catch (e, stackTrace) {
      DebugLogger.error('Error syncing trip', e, stackTrace);
      return null;
    }
  }

  /// Sync a stop immediately to FileMaker (for debugging)
  /// Returns true if successful, false otherwise
  Future<bool> syncStopImmediately(models.Stop stop) async {
    DebugLogger.info('🔄 Syncing stop immediately to FileMaker (DEBUG MODE)...');
    final payload = stop.toJson();
    return await _syncStop(payload, 'create');
  }

  Future<bool> _syncStop(Map<String, dynamic> payload, String op) async {
    DebugLogger.log('   ┌─ SYNC STOP: Starting stop sync process');
    try {
      DebugLogger.log('   │ STEP 1: Getting FileMaker service...');
      final fileMakerService = _getFileMakerService();
      if (fileMakerService == null) {
        DebugLogger.error('   │ ❌ FileMakerService not available for stop sync', null);
        return false;
      }
      DebugLogger.success('   │ ✅ FileMaker service available');

      DebugLogger.log('   │ STEP 2: Parsing stop from payload...');
      var stop = models.Stop.fromJson(payload);
      DebugLogger.log('   │   Stop ID: ${stop.id}');
      DebugLogger.log('   │   Trip ID: ${stop.tripId}');
      DebugLogger.log('   │   Client ID: ${stop.clientId}');
      DebugLogger.log('   │   Kind: ${stop.kind}');
      final syncPayload = SyncHelpers.prepareStopForSync(stop);
      
      DebugLogger.log('   │ STEP 3: Preparing field data for FileMaker...');
      final fieldData = Map<String, dynamic>.from(syncPayload);
      
      // Remove PrimaryKey - FileMaker generates it on create, and it cannot be modified on update
      fieldData.remove('PrimaryKey');
      DebugLogger.log('   │   Removed PrimaryKey (cannot be modified)');
      
      // Remove direction field - FileMaker backend will auto-generate it
      fieldData.remove('direction');
      DebugLogger.log('   │   Removed direction (FileMaker will auto-generate)');
      
      // For update operations, remove fields that cannot be modified after creation
      if (op == 'update') {
        fieldData.remove('clientId'); // Client cannot be changed after creation
        fieldData.remove('tripId');   // Trip cannot be changed after creation
        DebugLogger.log('   │   Removed clientId/tripId (locked after creation)');
      }
      
      // Keep tripId with PrimaryKey value for debugging
      // Relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId
      if (fieldData['tripId'] != null) {
        final tripIdValue = fieldData['tripId'] as String;
        DebugLogger.log('   │   tripId (PrimaryKey): $tripIdValue');
        DebugLogger.log('   │   Relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId');
        if (tripIdValue.startsWith('trip_')) {
          DebugLogger.warn('   │   ⚠️ WARNING: tripId is temporary, not a FileMaker PrimaryKey!');
        } else {
          DebugLogger.success('   │   ✅ Using valid FileMaker PrimaryKey: $tripIdValue');
          DebugLogger.log('   │   ✅ This PrimaryKey will link the stop to the trip in FileMaker');
        }
      } else {
        DebugLogger.warn('   │   ⚠️ tripId is null in payload');
      }
      
      // Format timestamp for FileMaker (ISO 8601 without milliseconds)
      if (fieldData['timestamp'] != null && stop.timestamp != null) {
        fieldData['timestamp'] = stop.timestamp!.toIso8601String().split('.')[0];
      }
      
      // Remove only FileMaker-managed timestamp fields (these are auto-managed by FileMaker)
      // FileMaker auto-generates CreationTimestamp, so we don't use createdAt
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      if (op == 'create') {
        fieldData.remove('createdAt'); // Remove createdAt - FileMaker uses CreationTimestamp instead (auto-generated)
      }
      
      // Remove deleted flag (local-only), but keep deleted_at for FileMaker
      fieldData.remove('deleted');
      fieldData.remove('deletedAt'); // camelCase variant (shouldn't exist but just in case)
      DebugLogger.log('   │   Removed deleted flag (local-only, kept deleted_at)');
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('   │   Final field data keys: ${fieldData.keys.toList()}');
      DebugLogger.log('   │   Field count: ${fieldData.length}');
      
      if (op == 'create') {
        DebugLogger.log('   │ STEP 4: Creating stop in FileMaker...');
        DebugLogger.log('   │   Stop ID: ${stop.id}');
        DebugLogger.log('   │   Client ID: ${stop.clientId}');
        DebugLogger.log('   │   Kind: ${stop.kind}');
        
        // Ensure the trip exists in FileMaker before creating the stop
        // IMPORTANT: stop.tripId must be the PrimaryKey from dapi-api_trips
        // Relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId
        DebugLogger.log('   │ STEP 5: Verifying trip exists in FileMaker...');
        DebugLogger.log('   │   Trip ID from stop: ${stop.tripId}');
        DebugLogger.log('   │   Relationship: dapi-api_trips.PrimaryKey = dapi-api_stops.tripId');
        
        // Check if tripId is a temporary ID (starts with "trip_")
        // If so, skip PrimaryKey search and go straight to driverId/date/direction search
        bool isTemporaryId = stop.tripId.startsWith('trip_');
        String? tripRecordId;
        
        if (!isTemporaryId) {
          // Try to find by PrimaryKey first (only if not a temporary ID)
          DebugLogger.log('   │   Searching FileMaker by PrimaryKey: ${stop.tripId}');
          tripRecordId = await fileMakerService.findRecordIdByPrimaryKey('dapi-api_trips', stop.tripId);
          
          if (tripRecordId != null) {
            DebugLogger.success('   │   ✅ Trip found in FileMaker by PrimaryKey (recordId: $tripRecordId)');
          } else {
            DebugLogger.warn('   │   ⚠️ Trip not found in FileMaker by PrimaryKey: ${stop.tripId}');
            DebugLogger.warn('   │   ⚠️ This PrimaryKey may be invalid or the trip was deleted from FileMaker');
          }
        } else {
          DebugLogger.log('   │   Trip ID is temporary (starts with "trip_"), skipping PrimaryKey search');
          DebugLogger.log('   │   Will search by driverId/date/direction instead');
        }
        
        if (tripRecordId == null) {
          DebugLogger.warn('   │   ⚠️ Trip not found in FileMaker by PrimaryKey: ${stop.tripId}');
          DebugLogger.warn('   │   ⚠️ This tripId may be:');
          DebugLogger.warn('   │     1. A temporary ID (starts with "trip_")');
          DebugLogger.warn('   │     2. An old/invalid PrimaryKey from a previous sync');
          DebugLogger.warn('   │     3. A PrimaryKey that was deleted from FileMaker');
          DebugLogger.log('   │   Searching for trip by driverId/date/direction...');
          
          // Try to find the trip in local database to get driverId/date/direction
          try {
            DebugLogger.log('   │   Looking up trip in local database with ID: ${stop.tripId}');
            final tripQuery = _database.select(_database.trips)
              ..where((t) => t.id.equals(stop.tripId));
              final tripData = await tripQuery.getSingleOrNull();
              
              if (tripData != null) {
                DebugLogger.log('   │   ✅ Found trip in local database');
                DebugLogger.log('   │   Local trip details:');
                DebugLogger.log('   │     - ID: ${tripData.id}');
                DebugLogger.log('   │     - driverId: ${tripData.driverId}');
                DebugLogger.log('   │     - date: ${tripData.date}');
                DebugLogger.log('   │     - direction: ${tripData.direction}');
                DebugLogger.log('   │   Searching FileMaker for existing trip by driverId/date/direction...');
                
                // First, try to find existing trip in FileMaker by driverId, date, direction
                final dateStr = '${tripData.date.month.toString().padLeft(2, '0')}/${tripData.date.day.toString().padLeft(2, '0')}/${tripData.date.year}';
                DebugLogger.log('   │   FileMaker search query:');
                DebugLogger.log('   │     - driverId: ${tripData.driverId}');
                DebugLogger.log('   │     - date: $dateStr');
                DebugLogger.log('   │     - direction: ${tripData.direction}');
                
                final existingTripPrimaryKey = await fileMakerService.findTripPrimaryKey(
                  tripData.driverId,
                  dateStr,
                  tripData.direction,
                );
                
                if (existingTripPrimaryKey != null) {
                  DebugLogger.success('   │   ✅ Found existing trip in FileMaker with PrimaryKey: $existingTripPrimaryKey');
                  DebugLogger.log('   │   Updating local trip ID from ${stop.tripId} to $existingTripPrimaryKey');
                  
                  // Update the local trip ID and all stops that reference it
                  final oldTripId = stop.tripId;
                  await (_database.update(_database.trips)..where((t) => t.id.equals(oldTripId)))
                      .write(TripsCompanion(id: Value(existingTripPrimaryKey)));
                  await (_database.update(_database.stops)..where((s) => s.tripId.equals(oldTripId)))
                      .write(StopsCompanion(tripId: Value(existingTripPrimaryKey)));
                  
                  // Update the stop object's tripId for this sync
                  stop = stop.copyWith(tripId: existingTripPrimaryKey);
                  // IMPORTANT: Also update fieldData with the new tripId!
                  fieldData['tripId'] = existingTripPrimaryKey;
                  DebugLogger.success('   │   ✅ Local trip and stops updated with FileMaker PrimaryKey');
                  DebugLogger.log('   │   ✅ fieldData.tripId updated to: $existingTripPrimaryKey');
                } else {
                  DebugLogger.log('   │   No existing trip found, creating new trip in FileMaker...');
                  final trip = models.Trip(
                    id: tripData.id,
                    date: tripData.date,
                    routeName: tripData.routeName,
                    driverId: tripData.driverId,
                    vehicleId: tripData.vehicleId,
                    direction: tripData.direction,
                    status: tripData.status,
                    createdAt: tripData.createdAt,
                  );
                  
                  // Sync the trip first
                  final tripSyncPayload = SyncHelpers.prepareTripForSync(trip);
                  final tripPrimaryKey = await _syncTrip(tripSyncPayload, 'create');
                  
                  if (tripPrimaryKey != null && tripPrimaryKey != stop.tripId) {
                    DebugLogger.success('   │   ✅ Trip synced with PrimaryKey: $tripPrimaryKey');
                    DebugLogger.log('   │   Updating local trip ID from ${stop.tripId} to $tripPrimaryKey');
                    
                    // Update the local trip ID and all stops that reference it
                    final oldTripId = stop.tripId;
                    await (_database.update(_database.trips)..where((t) => t.id.equals(oldTripId)))
                        .write(TripsCompanion(id: Value(tripPrimaryKey)));
                    await (_database.update(_database.stops)..where((s) => s.tripId.equals(oldTripId)))
                        .write(StopsCompanion(tripId: Value(tripPrimaryKey)));
                    
                    // Update the stop object's tripId for this sync
                    stop = stop.copyWith(tripId: tripPrimaryKey);
                    // IMPORTANT: Also update fieldData with the new tripId!
                    fieldData['tripId'] = tripPrimaryKey;
                    DebugLogger.success('   │   ✅ Local trip and stops updated with FileMaker PrimaryKey');
                    DebugLogger.log('   │   ✅ fieldData.tripId updated to: $tripPrimaryKey');
                  } else if (tripPrimaryKey == null) {
                    DebugLogger.error('   │   ❌ Failed to sync trip', null);
                  }
                }
              } else {
                DebugLogger.error('   │   ❌ Trip not found in local database', null);
              }
            } catch (e, stackTrace) {
              DebugLogger.error('   │   Error syncing trip before stop', e, stackTrace);
            }
        } else {
          DebugLogger.success('   │   ✅ Trip exists in FileMaker (recordId: $tripRecordId)');
        }
        
        DebugLogger.log('   │ STEP 6: Sending stop to FileMaker API...');
        DebugLogger.log('   │   Layout: dapi-api_stops');
        DebugLogger.log('   │   Field count: ${fieldData.length}');
        final recordId = await fileMakerService.createRecord('dapi-api_stops', fieldData);
        if (recordId != null) {
          DebugLogger.success('   │   ✅ Stop created in FileMaker');
          DebugLogger.log('   │   FileMaker recordId: $recordId');
          DebugLogger.log('   │   Stop PrimaryKey: ${stop.id}');
          DebugLogger.success('   └─ SYNC STOP: SUCCESS');
          return true;
        } else {
          DebugLogger.error('   │   ❌ Stop creation failed - null recordId', null);
          DebugLogger.log('   │   Possible reasons:');
          DebugLogger.log('   │   1. Layout dapi-api_stops doesn\'t exist');
          DebugLogger.log('   │   2. Field names don\'t match');
          DebugLogger.log('   │   3. Required fields missing');
          DebugLogger.log('   │   4. FileMaker validation error');
          DebugLogger.error('   └─ SYNC STOP: FAILED', null);
          return false;
        }
      } else if (op == 'update' && stop.id != null) {
        DebugLogger.info('Updating stop: ${stop.id}');
        // For updates, we need to find the FileMaker recordId by PrimaryKey first
        // because stop.id is a string PrimaryKey, not a numeric recordId
        try {
          final recordId = await fileMakerService.findRecordIdByPrimaryKey('dapi-api_stops', stop.id!);
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for PrimaryKey: ${stop.id}');
            final success = await fileMakerService.updateRecord('dapi-api_stops', recordId, fieldData);
            if (success) {
              DebugLogger.success('Stop updated successfully');
            } else {
              DebugLogger.error('Stop update failed', null);
            }
            return success;
          } else {
            DebugLogger.error('Could not find stop record with PrimaryKey: ${stop.id}', null);
            return false;
          }
        } catch (e, stackTrace) {
          DebugLogger.error('Error finding stop record for update', e, stackTrace);
          return false;
        }
      }
      return false;
    } catch (e, stackTrace) {
      DebugLogger.error('Error syncing stop', e, stackTrace);
      return false;
    }
  }

  Future<bool> _syncAttendance(Map<String, dynamic> payload, String op) async {
    try {
      final fileMakerService = _getFileMakerService();
      if (fileMakerService == null) {
        DebugLogger.error('FileMakerService not available for attendance sync', null);
        return false;
      }

      final attendance = models.Attendance.fromJson(payload);
      final syncPayload = SyncHelpers.prepareAttendanceForSync(attendance);
      
      // Remove PrimaryKey from payload for create operations (FileMaker auto-generates it)
      final fieldData = Map<String, dynamic>.from(syncPayload);
      if (op == 'create') {
        fieldData.remove('PrimaryKey'); // FileMaker auto-generates PrimaryKey, cannot be modified
      }
      
      // Remove date field - FileMaker will auto-generate it from CreationTimestamp
      // FileMaker can auto-enter the date based on when the record is created
      if (op == 'create') {
        fieldData.remove('date'); // Let FileMaker auto-generate date from CreationTimestamp
        DebugLogger.log('Removed date field for attendance creation - FileMaker will auto-generate it');
      }
      // For updates, we might still need the date, but if FileMaker auto-manages it, remove it too
      // Uncomment the line below if FileMaker auto-manages date for updates as well
      // fieldData.remove('date');
      if (fieldData['timeIn'] != null && attendance.timeIn != null) {
        fieldData['timeIn'] = attendance.timeIn!.toIso8601String().split('.')[0];
      }
      if (fieldData['timeOut'] != null && attendance.timeOut != null) {
        fieldData['timeOut'] = attendance.timeOut!.toIso8601String().split('.')[0];
      }
      
      // Remove only FileMaker-managed timestamp fields (these are auto-managed by FileMaker)
      // FileMaker auto-generates CreationTimestamp, so we don't use createdAt
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      if (op == 'create') {
        fieldData.remove('createdAt'); // Remove createdAt - FileMaker uses CreationTimestamp instead (auto-generated)
      }
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Attendance fieldData: $fieldData');
      
      if (op == 'create') {
        DebugLogger.info('Creating attendance: ${attendance.id}');
        DebugLogger.log('Attendance details: clientId=${attendance.clientId}, timeIn=${attendance.timeIn}, timeOut=${attendance.timeOut}, capturedBy=${attendance.capturedBy}');
        DebugLogger.log('Sending to FileMaker layout: dapi-api_attendances');
        DebugLogger.log('Field names being sent: ${fieldData.keys.join(", ")}');
        var recordId = await fileMakerService.createRecord('dapi-api_attendances', fieldData);
        
        // If regular creation fails, try manual method as fallback
        if (recordId == null) {
          DebugLogger.warn('⚠️ Regular attendance creation failed, trying manual method as fallback...');
          try {
            final manualResult = await fileMakerService.manualCreateAttendance(
              clientId: attendance.clientId,
              capturedBy: attendance.capturedBy,
              timeIn: attendance.timeIn?.toIso8601String().split('.')[0],
              timeOut: attendance.timeOut?.toIso8601String().split('.')[0],
            );
            if (manualResult['success'] == true) {
              recordId = manualResult['recordId']?.toString();
              DebugLogger.success('✅ Manual attendance creation succeeded! RecordId: $recordId');
            } else {
              DebugLogger.error('❌ Manual attendance creation also failed: ${manualResult['error']}', null);
            }
          } catch (e, stackTrace) {
            DebugLogger.error('Error in manual attendance creation fallback', e, stackTrace);
          }
        }
        
        if (recordId != null) {
          DebugLogger.success('✅ Attendance created successfully in FileMaker with recordId: $recordId');
          DebugLogger.log('Attendance PrimaryKey: ${attendance.id}, FileMaker recordId: $recordId');
        } else {
          DebugLogger.error('❌ Attendance creation returned null recordId', null);
          DebugLogger.log('This usually means FileMaker rejected the record. Check:');
          DebugLogger.log('1. Does the dapi-api_attendances layout exist?');
          DebugLogger.log('2. Are all field names on the dapi-api_attendances layout? (case-sensitive)');
          DebugLogger.log('3. Is the date field set to auto-enter from CreationTimestamp?');
          DebugLogger.log('4. Are there any script triggers that might be validating?');
          DebugLogger.log('5. Do all field names match exactly? (case-sensitive)');
          DebugLogger.log('6. Check FileMaker Data API error logs for specific validation errors');
        }
        return recordId != null;
      } else if (op == 'update' && attendance.id != null) {
        DebugLogger.info('Updating attendance: ${attendance.id}');
        // For updates, find the record by clientId + timeIn since FileMaker auto-generates PrimaryKey
        // This is more reliable than using PrimaryKey which FileMaker may have auto-generated differently
        try {
          String? recordId;
          
          // First try to find by PrimaryKey (in case FileMaker accepted our PrimaryKey)
          recordId = await fileMakerService.findRecordIdByPrimaryKey('dapi-api_attendances', attendance.id!);
          
          // If not found by PrimaryKey, try finding by clientId + timeIn
          if (recordId == null && attendance.timeIn != null) {
            final timeInStr = attendance.timeIn!.toIso8601String().split('.')[0];
            recordId = await fileMakerService.findAttendanceRecordId(attendance.clientId, timeInStr);
          }
          
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for attendance: ${attendance.id}');
            // Remove fields that FileMaker auto-manages or cannot be modified
            fieldData.remove('PrimaryKey'); // FileMaker auto-generates PrimaryKey, cannot be modified
            fieldData.remove('date'); // FileMaker auto-generates date from CreationTimestamp
            final success = await fileMakerService.updateRecord('dapi-api_attendances', recordId, fieldData);
            if (success) {
              DebugLogger.success('Attendance updated successfully');
            } else {
              DebugLogger.error('Attendance update failed', null);
            }
            return success;
          } else {
            DebugLogger.error('Could not find attendance record with PrimaryKey: ${attendance.id} or clientId: ${attendance.clientId}, timeIn: ${attendance.timeIn}', null);
            return false;
          }
        } catch (e, stackTrace) {
          DebugLogger.error('Error finding attendance record for update', e, stackTrace);
          return false;
        }
      }
      return false;
    } catch (e, stackTrace) {
      DebugLogger.error('Error syncing attendance', e, stackTrace);
      return false;
    }
  }
}

class SyncResult {
  final bool success;
  final int successCount;
  final int failureCount;
  final String? error;

  SyncResult({
    required this.success,
    this.successCount = 0,
    this.failureCount = 0,
    this.error,
  });
}

