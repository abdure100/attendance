import 'package:drift/drift.dart';

// Conditional imports for platform-specific database
import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_mobile.dart'
    if (dart.library.html) 'database_connection_web.dart';

/// Get the database connection for the current platform
LazyDatabase getDatabaseConnection() => openConnection();
