import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'staff.g.dart';

@JsonSerializable()
class Staff {
  @JsonKey(name: 'PrimaryKey')
  final String id;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'Password_raw')
  final String passwordRaw;
  @JsonKey(name: 'FullName')
  final String name;
  @JsonKey(name: 'Role')
  final String? role;
  @JsonKey(name: 'active', fromJson: _boolFromJson)
  final bool? active;
  @JsonKey(name: 'Allow_manual_entry', fromJson: _intFromJson)
  final int? allowManualEntry;
  @JsonKey(name: 'signatureRequired', fromJson: _signatureRequiredFromJson)
  final SignatureRequired? signatureRequired;

  const Staff({
    required this.id,
    required this.email,
    required this.passwordRaw,
    required this.name,
    this.role,
    this.active,
    this.allowManualEntry,
    this.signatureRequired,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);

  bool get canManualEntry => allowManualEntry == 1;
  
  // Convenience methods for signature requirements
  bool get requiresPickupSignature => signatureRequired?.pickup == 1;
  bool get requiresDropoffSignature => signatureRequired?.dropoff == 1;
  bool get requiresTimeInSignature => signatureRequired?.timeIn == 1;
  bool get requiresTimeOutSignature => signatureRequired?.timeOut == 1;

  @override
  String toString() => name;
}

// Helper functions for JSON parsing
bool? _boolFromJson(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  if (value is int) return value == 1;
  return null;
}

int? _intFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

/// Parse signatureRequired field from FileMaker
/// Supports both formats:
/// 1. Flat: {"pickup": 1, "dropoff": 1, "timeIn": 1, "timeOut": 1}
/// 2. Nested: {"signatureRequired": {"pickup": 1, "dropoff": 1, "timeIn": 1, "timeOut": 1}}
SignatureRequired? _signatureRequiredFromJson(dynamic value) {
  if (value == null || value == '') return null;
  
  try {
    Map<String, dynamic> data;
    if (value is String) {
      // Clean up any carriage returns from FileMaker
      final cleanedValue = value.replaceAll('\r', '').replaceAll('\n', '');
      data = jsonDecode(cleanedValue) as Map<String, dynamic>;
    } else if (value is Map<String, dynamic>) {
      data = value;
    } else {
      return null;
    }
    
    // Handle nested format: {"signatureRequired": {...}}
    if (data.containsKey('signatureRequired') && data['signatureRequired'] is Map) {
      data = data['signatureRequired'] as Map<String, dynamic>;
    }
    
    return SignatureRequired.fromJson(data);
  } catch (e) {
    return null;
  }
}

/// Signature requirements configuration
/// Each field is 1 (required) or 0 (not required)
class SignatureRequired {
  final int pickup;
  final int dropoff;
  final int timeIn;
  final int timeOut;

  const SignatureRequired({
    this.pickup = 0,
    this.dropoff = 0,
    this.timeIn = 0,
    this.timeOut = 0,
  });

  factory SignatureRequired.fromJson(Map<String, dynamic> json) {
    return SignatureRequired(
      pickup: _parseIntValue(json['pickup']),
      dropoff: _parseIntValue(json['dropoff']),
      timeIn: _parseIntValue(json['timeIn']),
      timeOut: _parseIntValue(json['timeOut']),
    );
  }

  Map<String, dynamic> toJson() => {
    'pickup': pickup,
    'dropoff': dropoff,
    'timeIn': timeIn,
    'timeOut': timeOut,
  };

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is bool) return value ? 1 : 0;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
