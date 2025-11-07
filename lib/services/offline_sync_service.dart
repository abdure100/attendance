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
    final query = _database.select(_database.outboxes)
      ..where((o) => o.synced.equals(false))
      ..orderBy([(o) => OrderingTerm(expression: o.createdAt, mode: OrderingMode.asc)]);
    
    final items = await query.get();
    DebugLogger.info('📦 Found ${items.length} pending items to sync');
    
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
      
            // Format date for FileMaker - try date only first (MM/DD/YYYY)
            // If FileMaker requires timestamp, we'll add it
            if (fieldData['date'] != null) {
              final date = trip.date;
              // Format as MM/DD/YYYY (date only, no time)
              // FileMaker date fields typically don't include time unless it's a timestamp field
              fieldData['date'] = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
            }
      
      // Remove only FileMaker-managed timestamp fields (these are auto-managed by FileMaker)
      // All other fields (including createdAt) can be written from frontend
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Trip fieldData: $fieldData');
      
      if (op == 'create') {
        DebugLogger.info('Creating trip: ${trip.id}');
        final recordId = await fileMakerService.createRecord('api_trips', fieldData);
        if (recordId != null) {
          DebugLogger.success('Trip created with recordId: $recordId');
        } else {
          DebugLogger.error('Trip creation returned null recordId', null);
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
      // All other fields (including createdAt) can be written from frontend
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Stop fieldData: $fieldData');
      
      if (op == 'create') {
        DebugLogger.info('Creating stop: ${stop.id}');
        final recordId = await fileMakerService.createRecord('api_stops', fieldData);
        if (recordId != null) {
          DebugLogger.success('Stop created with recordId: $recordId');
        } else {
          DebugLogger.error('Stop creation returned null recordId', null);
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
      
      // Remove PrimaryKey from payload for create operations
      final fieldData = Map<String, dynamic>.from(syncPayload);
      if (op == 'create') {
        fieldData.remove('PrimaryKey');
      }
      
      // Format date for FileMaker - date only (MM/DD/YYYY)
      // FileMaker date fields typically don't include time unless it's a timestamp field
      if (fieldData['date'] != null) {
        final date = attendance.date;
        // Format as MM/DD/YYYY (date only, no time)
        fieldData['date'] = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      }
      if (fieldData['timeIn'] != null && attendance.timeIn != null) {
        fieldData['timeIn'] = attendance.timeIn!.toIso8601String().split('.')[0];
      }
      if (fieldData['timeOut'] != null && attendance.timeOut != null) {
        fieldData['timeOut'] = attendance.timeOut!.toIso8601String().split('.')[0];
      }
      
      // Remove only FileMaker-managed timestamp fields (these are auto-managed by FileMaker)
      // All other fields (including createdAt) can be written from frontend
      fieldData.remove('CreationTimestamp');
      fieldData.remove('ModificationTimestamp');
      
      // Remove null values - FileMaker doesn't accept null
      fieldData.removeWhere((key, value) => value == null);
      
      DebugLogger.log('Attendance fieldData: $fieldData');
      
      if (op == 'create') {
        DebugLogger.info('Creating attendance: ${attendance.id}');
        final recordId = await fileMakerService.createRecord('api_attendances', fieldData);
        if (recordId != null) {
          DebugLogger.success('Attendance created with recordId: $recordId');
        } else {
          DebugLogger.error('Attendance creation returned null recordId', null);
        }
        return recordId != null;
      } else if (op == 'update' && attendance.id != null) {
        DebugLogger.info('Updating attendance: ${attendance.id}');
        // For updates, we need to find the FileMaker recordId by PrimaryKey first
        // because attendance.id is a string PrimaryKey, not a numeric recordId
        try {
          final recordId = await fileMakerService.findRecordIdByPrimaryKey('api_attendances', attendance.id!);
          if (recordId != null) {
            DebugLogger.log('Found FileMaker recordId: $recordId for PrimaryKey: ${attendance.id}');
            final success = await fileMakerService.updateRecord('api_attendances', recordId, fieldData);
            if (success) {
              DebugLogger.success('Attendance updated successfully');
            } else {
              DebugLogger.error('Attendance update failed', null);
            }
            return success;
          } else {
            DebugLogger.error('Could not find attendance record with PrimaryKey: ${attendance.id}', null);
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

