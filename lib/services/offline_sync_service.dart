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

  /// Sync all pending items
  Future<SyncResult> syncAll() async {
    DebugLogger.info('🔄 Starting sync process...');
    
    final fileMakerService = _getFileMakerService();
    if (fileMakerService == null) {
      DebugLogger.error('FileMaker service not available', null);
      return SyncResult(success: false, error: 'FileMaker service not available');
    }

    final isConnected = await isOnline();
    if (!isConnected) {
      DebugLogger.warn('No internet connection');
      return SyncResult(success: false, error: 'No internet connection');
    }

    DebugLogger.info('✅ Online, checking for pending items...');

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
    DebugLogger.log('Sync order: ${items.map((i) => '${i.entity}(${i.op})').join(', ')}');
    
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
        DebugLogger.info('📤 Syncing item ${i + 1}/${items.length}: ${item.entity} (${item.op})');
        final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
        DebugLogger.log('Payload keys: ${payload.keys.toList()}');
        
        bool success = false;
        switch (item.entity) {
          case 'trip':
            success = await _syncTrip(payload, item.op);
            break;
          case 'stop':
            success = await _syncStop(payload, item.op);
            break;
          case 'attendance':
            success = await _syncAttendance(payload, item.op);
            break;
          default:
            DebugLogger.warn('Unknown entity type: ${item.entity}');
        }
        
        DebugLogger.log('Sync result for item ${i + 1}: ${success ? "✅ SUCCESS" : "❌ FAILED"}');

        if (success) {
          // Mark as synced
          await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
              .write(OutboxesCompanion(
            synced: const Value(true),
            syncedAt: Value(DateTime.now()),
          ));
          successCount++;
        } else {
          // Increment retry count
          final newRetries = item.retries + 1;
          await (_database.update(_database.outboxes)..where((o) => o.id.equals(item.id)))
              .write(OutboxesCompanion(
            retries: Value(newRetries),
          ));
          failureCount++;
          
          // Stop syncing if too many retries
          if (newRetries >= 5) {
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
    
    DebugLogger.info('🔄 Sync complete: ${result.successCount} succeeded, ${result.failureCount} failed');
    if (result.error != null) {
      DebugLogger.error('Last error: ${result.error}', null);
    }
    
    return result;
  }

  Future<bool> _syncTrip(Map<String, dynamic> payload, String op) async {
    try {
      final fileMakerService = _getFileMakerService();
      if (fileMakerService == null) {
        DebugLogger.error('FileMakerService not available for trip sync', null);
        return false;
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
        DebugLogger.log('Sending to FileMaker layout: api_trips');
        DebugLogger.log('Field names being sent: ${fieldData.keys.join(", ")}');
        var recordId = await fileMakerService.createRecord('api_trips', fieldData);
        
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
        } else {
          DebugLogger.error('❌ Trip creation returned null recordId', null);
          DebugLogger.log('This usually means FileMaker rejected the record. Check:');
          DebugLogger.log('1. Does the api_trips layout exist?');
          DebugLogger.log('2. Is the "date" field on the api_trips layout? (case-sensitive: lowercase "date")');
          DebugLogger.log('3. Is the "date" field type set to Text (not Date)?');
          DebugLogger.log('4. Are there any script triggers (OnRecordCommit, OnRecordCreate) that might be validating?');
          DebugLogger.log('5. Do all field names match exactly? (case-sensitive)');
          DebugLogger.log('6. Check FileMaker Data API error logs for specific validation errors');
          DebugLogger.log('7. Try creating a record manually in FileMaker with the same data to see if it works');
          DebugLogger.log('8. Verify the field name is exactly "date" (lowercase) in FileMaker');
        }
        return recordId != null;
      } else if (op == 'update' && trip.id != null) {
        DebugLogger.info('Updating trip: ${trip.id}');
        // For updates, we need to find the FileMaker recordId by PrimaryKey first
        // because trip.id is a string PrimaryKey, not a numeric recordId
        try {
          final recordId = await fileMakerService.findRecordIdByPrimaryKey('api_trips', trip.id!);
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for PrimaryKey: ${trip.id}');
            final success = await fileMakerService.updateRecord('api_trips', recordId, fieldData);
            if (success) {
              DebugLogger.success('Trip updated successfully');
            } else {
              DebugLogger.error('Trip update failed', null);
            }
            return success;
          } else {
            DebugLogger.error('Could not find trip record with PrimaryKey: ${trip.id}', null);
            return false;
          }
        } catch (e, stackTrace) {
          DebugLogger.error('Error finding trip record for update', e, stackTrace);
          return false;
        }
      }
      return false;
    } catch (e, stackTrace) {
      DebugLogger.error('Error syncing trip', e, stackTrace);
      return false;
    }
  }

  Future<bool> _syncStop(Map<String, dynamic> payload, String op) async {
    try {
      final fileMakerService = _getFileMakerService();
      if (fileMakerService == null) {
        DebugLogger.error('FileMakerService not available for stop sync', null);
        return false;
      }

      final stop = models.Stop.fromJson(payload);
      final syncPayload = SyncHelpers.prepareStopForSync(stop);
      
      // Remove PrimaryKey from payload for create operations
      final fieldData = Map<String, dynamic>.from(syncPayload);
      if (op == 'create') {
        fieldData.remove('PrimaryKey');
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
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Stop fieldData: $fieldData');
      DebugLogger.log('Stop fieldData keys: ${fieldData.keys.toList()}');
      DebugLogger.log('Stop fieldData values: ${fieldData.values.map((v) => v?.toString().substring(0, v.toString().length > 50 ? 50 : v.toString().length)).toList()}');
      
      if (op == 'create') {
        DebugLogger.info('Creating stop: ${stop.id}');
        DebugLogger.log('Stop details: tripId=${stop.tripId}, clientId=${stop.clientId}, kind=${stop.kind}, status=${stop.status}');
        
        // Ensure the trip exists in FileMaker before creating the stop
        DebugLogger.log('🔍 Checking if trip exists in FileMaker: ${stop.tripId}');
        final tripRecordId = await fileMakerService.findRecordIdByPrimaryKey('api_trips', stop.tripId);
        
        if (tripRecordId == null) {
          DebugLogger.warn('⚠️ Trip ${stop.tripId} not found in FileMaker. Attempting to sync trip first...');
          
          // Try to find the trip in local database and sync it
          try {
            final tripQuery = _database.select(_database.trips)
              ..where((t) => t.id.equals(stop.tripId));
              final tripData = await tripQuery.getSingleOrNull();
              
              if (tripData != null) {
                DebugLogger.log('📦 Found trip in local database, syncing it now...');
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
                final tripSynced = await _syncTrip(tripSyncPayload, 'create');
                
                if (tripSynced) {
                  DebugLogger.success('✅ Trip synced successfully, proceeding with stop creation');
                } else {
                  DebugLogger.error('❌ Failed to sync trip. Stop creation may fail if FileMaker enforces trip relationship.', null);
                }
              } else {
                DebugLogger.error('❌ Trip ${stop.tripId} not found in local database either. Stop may fail to sync.', null);
              }
            } catch (e, stackTrace) {
              DebugLogger.error('Error syncing trip before stop', e, stackTrace);
            }
        } else {
          DebugLogger.log('✅ Trip exists in FileMaker (recordId: $tripRecordId)');
        }
        
        final recordId = await fileMakerService.createRecord('api_stops', fieldData);
        if (recordId != null) {
          DebugLogger.success('✅ Stop created successfully in FileMaker with recordId: $recordId');
          DebugLogger.log('Stop PrimaryKey: ${stop.id}, FileMaker recordId: $recordId');
        } else {
          DebugLogger.error('❌ Stop creation returned null recordId', null);
          DebugLogger.log('This usually means FileMaker rejected the record. Check:');
          DebugLogger.log('1. Does the api_stops layout exist?');
          DebugLogger.log('2. Do all field names match exactly?');
          DebugLogger.log('3. Are required fields present?');
          DebugLogger.log('4. Check FileMaker Data API error logs');
        }
        return recordId != null;
      } else if (op == 'update' && stop.id != null) {
        DebugLogger.info('Updating stop: ${stop.id}');
        // For updates, we need to find the FileMaker recordId by PrimaryKey first
        // because stop.id is a string PrimaryKey, not a numeric recordId
        try {
          final recordId = await fileMakerService.findRecordIdByPrimaryKey('api_stops', stop.id!);
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for PrimaryKey: ${stop.id}');
            final success = await fileMakerService.updateRecord('api_stops', recordId, fieldData);
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
        DebugLogger.log('Sending to FileMaker layout: api_attendances');
        DebugLogger.log('Field names being sent: ${fieldData.keys.join(", ")}');
        var recordId = await fileMakerService.createRecord('api_attendances', fieldData);
        
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
          DebugLogger.log('1. Does the api_attendances layout exist?');
          DebugLogger.log('2. Are all field names on the api_attendances layout? (case-sensitive)');
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
          recordId = await fileMakerService.findRecordIdByPrimaryKey('api_attendances', attendance.id!);
          
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
            final success = await fileMakerService.updateRecord('api_attendances', recordId, fieldData);
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

