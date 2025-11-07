import '../models/trip.dart';
import '../models/stop.dart';
import '../models/attendance.dart';

/// Helper functions to prepare models for FileMaker sync
/// Only removes fields that FileMaker manages automatically (PrimaryKey, CreationTimestamp, ModificationTimestamp)
/// All other fields can be written from the frontend
class SyncHelpers {
  /// Prepare Trip for sync - only removes FileMaker-managed fields
  /// All other fields (including createdAt) can be written from frontend
  static Map<String, dynamic> prepareTripForSync(Trip trip) {
    final json = trip.toJson();
    // Keep createdAt - can be written from frontend
    // Only FileMaker-managed timestamps are removed in sync methods
    return json;
  }

  /// Prepare Stop for sync - only removes FileMaker-managed fields
  /// All other fields can be written from frontend
  static Map<String, dynamic> prepareStopForSync(Stop stop) {
    final json = stop.toJson();
    // All fields can be written from frontend
    // Only FileMaker-managed timestamps are removed in sync methods
    return json;
  }

  /// Prepare Attendance for sync - only removes FileMaker-managed fields
  /// All other fields can be written from frontend
  static Map<String, dynamic> prepareAttendanceForSync(Attendance attendance) {
    final json = attendance.toJson();
    // All fields can be written from frontend
    // Only FileMaker-managed timestamps are removed in sync methods
    return json;
  }
}

