import '../models/trip.dart';
import '../models/stop.dart';
import '../models/attendance.dart';

/// Helper functions to prepare models for FileMaker sync
/// Note: createdAt is removed in sync methods - FileMaker uses CreationTimestamp instead (auto-generated)
class SyncHelpers {
  /// Prepare Trip for sync
  /// Note: createdAt will be removed in sync methods - FileMaker uses CreationTimestamp instead (auto-generated)
  static Map<String, dynamic> prepareTripForSync(Trip trip) {
    final json = trip.toJson();
    return json;
  }

  /// Prepare Stop for sync
  /// Note: createdAt will be removed in sync methods - FileMaker uses CreationTimestamp instead (auto-generated)
  static Map<String, dynamic> prepareStopForSync(Stop stop) {
    final json = stop.toJson();
    return json;
  }

  /// Prepare Attendance for sync
  /// Note: createdAt will be removed in sync methods - FileMaker uses CreationTimestamp instead (auto-generated)
  static Map<String, dynamic> prepareAttendanceForSync(Attendance attendance) {
    final json = attendance.toJson();
    return json;
  }
}

