import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service for controlling Android Kiosk Mode (Lock Task Mode)
/// 
/// This requires the app to be set as Device Owner on Android.
/// See KIOSK_MODE_SETUP.md for setup instructions.
class KioskService {
  static const MethodChannel _channel = MethodChannel('com.sphereemr.attendance/kiosk');
  
  static final KioskService _instance = KioskService._internal();
  factory KioskService() => _instance;
  KioskService._internal();

  /// Check if the app is set as Device Owner
  Future<bool> isDeviceOwner() async {
    if (!_isAndroid()) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('isDeviceOwner');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('KioskService: Failed to check device owner: ${e.message}');
      return false;
    }
  }

  /// Check if Kiosk Mode is currently active
  Future<bool> isKioskModeActive() async {
    if (!_isAndroid()) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('isKioskModeActive');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('KioskService: Failed to check kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Start Kiosk Mode (Lock Task Mode)
  /// Returns true if successful, false otherwise
  Future<bool> startKioskMode() async {
    if (!_isAndroid()) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('startKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('KioskService: Failed to start kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Stop Kiosk Mode (exit kiosk)
  /// Returns true if successful
  Future<bool> stopKioskMode() async {
    if (!_isAndroid()) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('stopKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('KioskService: Failed to stop kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Get comprehensive kiosk status
  Future<KioskStatus> getKioskStatus() async {
    if (!_isAndroid()) {
      return KioskStatus(
        isDeviceOwner: false,
        isKioskActive: false,
        deviceModel: 'N/A',
        androidVersion: 0,
        platform: 'Not Android',
      );
    }
    
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getKioskStatus');
      if (result != null) {
        return KioskStatus(
          isDeviceOwner: result['isDeviceOwner'] as bool? ?? false,
          isKioskActive: result['isKioskActive'] as bool? ?? false,
          deviceModel: result['deviceModel'] as String? ?? 'Unknown',
          androidVersion: result['androidVersion'] as int? ?? 0,
          platform: 'Android',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('KioskService: Failed to get kiosk status: ${e.message}');
    }
    
    return KioskStatus(
      isDeviceOwner: false,
      isKioskActive: false,
      deviceModel: 'Error',
      androidVersion: 0,
      platform: 'Android',
    );
  }

  bool _isAndroid() {
    return defaultTargetPlatform == TargetPlatform.android;
  }
}

/// Status information about Kiosk Mode
class KioskStatus {
  final bool isDeviceOwner;
  final bool isKioskActive;
  final String deviceModel;
  final int androidVersion;
  final String platform;

  KioskStatus({
    required this.isDeviceOwner,
    required this.isKioskActive,
    required this.deviceModel,
    required this.androidVersion,
    required this.platform,
  });

  @override
  String toString() {
    return 'KioskStatus(isDeviceOwner: $isDeviceOwner, isKioskActive: $isKioskActive, '
           'deviceModel: $deviceModel, androidVersion: $androidVersion, platform: $platform)';
  }
}

