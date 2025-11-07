import 'package:flutter/foundation.dart';

/// Utility class for conditional debug logging
/// Only logs in debug mode to reduce noise in production
class DebugLogger {
  /// Log a debug message (only in debug mode)
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// Log an info message (always logged)
  static void info(String message) {
    print(message);
  }

  /// Log a warning message (always logged)
  static void warn(String message) {
    print('⚠️ $message');
  }

  /// Log an error message (always logged)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('❌ $message');
    if (error != null) {
      print('   Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      print('   Stack trace: $stackTrace');
    }
  }

  /// Log a success message (always logged)
  static void success(String message) {
    print('✅ $message');
  }
}

