import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current location with GPS accuracy and speed
  /// Returns map with latitude, longitude, accuracy (meters), speed (m/s)
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check location permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'accuracy': position.accuracy,
        'speed': position.speed,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to get address
  static Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        // Format address
        final addressParts = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((part) => part != null && part.isNotEmpty).toList();
        return addressParts.join(', ');
      }
      return null;
    } catch (e) {
      print('❌ Error reverse geocoding: $e');
      return null;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request all necessary permissions
  static Future<bool> requestAllPermissions() async {
    final location = await requestLocationPermission();
    final camera = await requestCameraPermission();
    return location && camera;
  }

  /// Format lat/lng as string "lat,lng"
  static String formatLatLng(double latitude, double longitude) {
    return '$latitude,$longitude';
  }

  /// Parse "lat,lng" string to coordinates
  static Map<String, double>? parseLatLng(String latLng) {
    try {
      final parts = latLng.split(',');
      if (parts.length == 2) {
        return {
          'latitude': double.parse(parts[0].trim()),
          'longitude': double.parse(parts[1].trim()),
        };
      }
      return null;
    } catch (e) {
      print('❌ Error parsing lat/lng: $e');
      return null;
    }
  }
}
