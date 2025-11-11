import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../models/attendance.dart' as models;
import '../database/app_database.dart';
import 'filemaker_service.dart';

/// Service for managing attendance (time-in/out)
class AttendanceService extends ChangeNotifier {
  final AppDatabase _database;
  // ignore: unused_field
  final FileMakerService? _fileMakerService; // Reserved for future sync implementation

  AttendanceService(this._database, [this._fileMakerService]);

  /// Record time-in for a client
  Future<models.Attendance> recordTimeIn({
    required String clientId,
    required String staffId,
    String? note,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Check if attendance already exists for today
    final query = _database.select(_database.attendances)
      ..where((a) => 
        a.clientId.equals(clientId) &
        a.date.isBiggerOrEqualValue(startOfDay) &
        a.date.isSmallerThanValue(startOfDay.add(const Duration(days: 1)))
      );
    
    final existingAttendance = await query.getSingleOrNull();

    models.Attendance attendance;
    if (existingAttendance != null) {
      // Update existing
      if (existingAttendance.timeIn != null) {
        throw Exception('Time-in already recorded for today');
      }
      
      attendance = models.Attendance(
        id: existingAttendance.id,
        clientId: clientId,
        date: existingAttendance.date,
        timeIn: DateTime.now(),
        timeOut: existingAttendance.timeOut,
        capturedBy: staffId,
        note: note ?? existingAttendance.note,
      );

      await (_database.update(_database.attendances)..where((a) => a.id.equals(existingAttendance.id)))
          .write(AttendancesCompanion(
        timeIn: Value(DateTime.now()),
        note: Value(note ?? existingAttendance.note),
      ));
    } else {
      // Create new
      final attendanceId = 'attendance_${clientId}_${today.millisecondsSinceEpoch}';
      attendance = models.Attendance(
        id: attendanceId,
        clientId: clientId,
        date: startOfDay,
        timeIn: DateTime.now(),
        capturedBy: staffId,
        note: note,
      );

      await _database.into(_database.attendances).insert(
        AttendancesCompanion.insert(
          id: attendanceId,
          clientId: clientId,
          date: startOfDay,
          timeIn: Value(DateTime.now()),
          capturedBy: staffId,
          note: Value(note),
        ),
      );
    }

    // Queue for sync
    await _queueForSync('attendance', attendance.toJson(), existingAttendance != null ? 'update' : 'create');

    notifyListeners();
    return attendance;
  }

  /// Record time-out for a client
  Future<models.Attendance> recordTimeOut({
    required String clientId,
    required String staffId,
    String? note,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Find existing attendance for today
    final query = _database.select(_database.attendances)
      ..where((a) => 
        a.clientId.equals(clientId) &
        a.date.isBiggerOrEqualValue(startOfDay) &
        a.date.isSmallerThanValue(startOfDay.add(const Duration(days: 1)))
      );
    
    final existing = await query.getSingleOrNull();
    if (existing == null || existing.timeIn == null) {
      throw Exception('Time-in required before time-out');
    }

    if (existing.timeOut != null) {
      throw Exception('Time-out already recorded for today');
    }

    final attendance = models.Attendance(
      id: existing.id,
      clientId: clientId,
      date: existing.date,
      timeIn: existing.timeIn,
      timeOut: DateTime.now(),
      capturedBy: staffId,
      note: note ?? existing.note,
    );

    await (_database.update(_database.attendances)..where((a) => a.id.equals(existing.id)))
        .write(AttendancesCompanion(
      timeOut: Value(DateTime.now()),
      note: Value(note ?? existing.note),
    ));

    // Queue for sync
    await _queueForSync('attendance', attendance.toJson(), 'update');

    notifyListeners();
    return attendance;
  }

  /// Get today's attendance for all clients
  Future<List<models.Attendance>> getTodayAttendance() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _database.select(_database.attendances)
      ..where((a) => 
        a.date.isBiggerOrEqualValue(startOfDay) &
        a.date.isSmallerThanValue(endOfDay)
      )
      ..orderBy([(a) => OrderingTerm(expression: a.timeIn, mode: OrderingMode.asc)]);

    final results = await query.get();
    return results.map((r) => models.Attendance(
      id: r.id,
      clientId: r.clientId,
      date: r.date,
      timeIn: r.timeIn,
      timeOut: r.timeOut,
      capturedBy: r.capturedBy,
      note: r.note,
    )).toList();
  }

  /// Get attendance for a specific client today
  Future<models.Attendance?> getClientAttendanceToday(String clientId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _database.select(_database.attendances)
      ..where((a) => 
        a.clientId.equals(clientId) &
        a.date.isBiggerOrEqualValue(startOfDay) &
        a.date.isSmallerThanValue(endOfDay)
      );

    final result = await query.getSingleOrNull();
    if (result == null) return null;

    return models.Attendance(
      id: result.id,
      clientId: result.clientId,
      date: result.date,
      timeIn: result.timeIn,
      timeOut: result.timeOut,
      capturedBy: result.capturedBy,
      note: result.note,
    );
  }

  /// Update attendance record (e.g., edit time, note)
  Future<models.Attendance> updateAttendance({
    required String attendanceId,
    DateTime? timeIn,
    DateTime? timeOut,
    String? note,
  }) async {
    // Get existing attendance
    final query = _database.select(_database.attendances)
      ..where((a) => a.id.equals(attendanceId));
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      throw Exception('Attendance record not found');
    }

    // Update fields
    await (_database.update(_database.attendances)..where((a) => a.id.equals(attendanceId)))
        .write(AttendancesCompanion(
      timeIn: Value(timeIn ?? existing.timeIn),
      timeOut: Value(timeOut ?? existing.timeOut),
      note: Value(note ?? existing.note),
    ));

    // Get updated attendance
    final updated = await query.getSingle();
    final attendance = models.Attendance(
      id: updated.id,
      clientId: updated.clientId,
      date: updated.date,
      timeIn: updated.timeIn,
      timeOut: updated.timeOut,
      capturedBy: updated.capturedBy,
      note: updated.note,
    );

    // Queue for sync
    await _queueForSync('attendance', attendance.toJson(), 'update');

    notifyListeners();
    return attendance;
  }

  /// Delete attendance record
  /// Also deletes related stops for the client to reset their status
  Future<void> deleteAttendance(String attendanceId) async {
    // Get attendance before deleting (for sync if needed)
    final query = _database.select(_database.attendances)
      ..where((a) => a.id.equals(attendanceId));
    final existing = await query.getSingleOrNull();
    
    if (existing == null) {
      throw Exception('Attendance record not found');
    }

    final clientId = existing.clientId;

    // Delete from database
    await (_database.delete(_database.attendances)..where((a) => a.id.equals(attendanceId))).go();

    // Delete related stops for this client from today's trips to reset status
    // Find all stops for this client in today's trips (AM and PM)
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    // Find today's trips
    final tripsQuery = _database.select(_database.trips)
      ..where((t) => 
        t.date.isBiggerOrEqualValue(startOfDay) &
        t.date.isSmallerThanValue(endOfDay)
      );
    final todayTrips = await tripsQuery.get();
    
    // Delete all stops for this client from today's trips
    for (final trip in todayTrips) {
      final stopsQuery = _database.select(_database.stops)
        ..where((s) => 
          s.tripId.equals(trip.id) &
          s.clientId.equals(clientId)
        );
      final clientStops = await stopsQuery.get();
      
      for (final stop in clientStops) {
        await (_database.delete(_database.stops)..where((s) => s.id.equals(stop.id))).go();
      }
    }

    // Note: We don't queue delete operations for sync as FileMaker doesn't support soft deletes
    // If you need to track deletions, you could add a 'deleted' flag instead
    
    notifyListeners();
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

