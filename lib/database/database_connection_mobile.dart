import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Initialize SQLite native library (required for Android)
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    final dbFolder = await getDatabasesPath();
    final file = File(p.join(dbFolder, 'attendance.db'));
    return NativeDatabase(file);
  });
}
