import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'dart:io';
import 'package:path/path.dart' as p;

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getDatabasesPath();
    final file = File(p.join(dbFolder, 'attendance.db'));
    return NativeDatabase(file);
  });
}
