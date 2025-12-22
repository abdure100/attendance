import 'package:drift/drift.dart';
import 'database_connection.dart';

part 'app_database.g.dart';

// Tables
class Trips extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get routeName => text().nullable()();
  TextColumn get driverId => text()();
  TextColumn get vehicleId => text().nullable()();
  TextColumn get direction => text()(); // "AM" | "PM"
  TextColumn get status => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Stops extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get clientId => text()();
  TextColumn get kind => text()(); // "pickup" | "dropoff"
  TextColumn get direction => text().nullable()(); // "AM" | "PM" - from parent trip (nullable for migration)
  TextColumn get plannedLatLng => text().nullable()();
  TextColumn get actualLatLng => text().nullable()();
  TextColumn get actualAddress => text().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  TextColumn get status => text()(); // "pending" | "done"
  TextColumn get note => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get signatureBase64 => text().nullable()(); // Base64 encoded PNG signature
  RealColumn get accuracy => real().nullable()();
  RealColumn get speed => real().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))(); // 0 = not deleted, 1 = deleted
  DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete timestamp
  
  @override
  Set<Column> get primaryKey => {id};
}

class Attendances extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get timeIn => dateTime().nullable()();
  DateTimeColumn get timeOut => dateTime().nullable()();
  TextColumn get capturedBy => text()();
  TextColumn get note => text().nullable()();
  TextColumn get signatureInBase64 => text().nullable()(); // Base64 signature for time-in
  TextColumn get signatureOutBase64 => text().nullable()(); // Base64 signature for time-out
  
  @override
  Set<Column> get primaryKey => {id};
}

class Outboxes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()(); // "trip" | "stop" | "attendance"
  TextColumn get payloadJson => text()();
  TextColumn get op => text()(); // "create" | "update"
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retries => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Trips, Stops, Attendances, Outboxes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(getDatabaseConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add direction column to stops table (nullable for migration)
          await m.addColumn(stops, stops.direction);
        }
        if (from < 3) {
          // Add signatureBase64 column for Base64 encoded signatures
          // This replaces the old signaturePath column
          await m.addColumn(stops, stops.signatureBase64);
        }
        if (from < 4) {
          // Add deletedAt column for soft delete timestamp
          await m.addColumn(stops, stops.deletedAt);
        }
        if (from < 5) {
          // Add deleted flag column (0 = not deleted, 1 = deleted)
          await m.addColumn(stops, stops.deleted);
        }
        if (from < 6) {
          // Add signature fields for attendance time-in/time-out
          await m.addColumn(attendances, attendances.signatureInBase64);
          await m.addColumn(attendances, attendances.signatureOutBase64);
        }
        if (from < 7) {
          // Fix any NULL deleted values to be 0
          await customStatement('UPDATE stops SET deleted = 0 WHERE deleted IS NULL');
        }
      },
    );
  }
}