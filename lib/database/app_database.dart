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
  TextColumn get plannedLatLng => text().nullable()();
  TextColumn get actualLatLng => text().nullable()();
  TextColumn get actualAddress => text().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  TextColumn get status => text()(); // "pending" | "done"
  TextColumn get note => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get signaturePath => text().nullable()();
  RealColumn get accuracy => real().nullable()();
  RealColumn get speed => real().nullable()();
  
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }
}