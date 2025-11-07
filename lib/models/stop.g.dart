// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stop _$StopFromJson(Map<String, dynamic> json) => Stop(
      id: json['PrimaryKey'] as String?,
      tripId: json['tripId'] as String,
      clientId: json['clientId'] as String,
      kind: json['kind'] as String,
      plannedLatLng: json['plannedLatLng'] as String?,
      actualLatLng: json['actualLatLng'] as String?,
      actualAddress: json['actualAddress'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String?,
      photoPath: json['photoPath'] as String?,
      signaturePath: json['signaturePath'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StopToJson(Stop instance) => <String, dynamic>{
      'PrimaryKey': instance.id,
      'tripId': instance.tripId,
      'clientId': instance.clientId,
      'kind': instance.kind,
      'plannedLatLng': instance.plannedLatLng,
      'actualLatLng': instance.actualLatLng,
      'actualAddress': instance.actualAddress,
      'timestamp': instance.timestamp?.toIso8601String(),
      'status': instance.status,
      'note': instance.note,
      'photoPath': instance.photoPath,
      'signaturePath': instance.signaturePath,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
    };
