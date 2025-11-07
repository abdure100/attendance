// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: json['PrimaryKey'] as String?,
      date: DateTime.parse(json['date'] as String),
      routeName: json['routeName'] as String?,
      driverId: json['driverId'] as String,
      vehicleId: json['vehicleId'] as String?,
      direction: json['direction'] as String,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'PrimaryKey': instance.id,
      'date': instance.date.toIso8601String(),
      'routeName': instance.routeName,
      'driverId': instance.driverId,
      'vehicleId': instance.vehicleId,
      'direction': instance.direction,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
