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
      direction: json['direction'] as String?,
      plannedLatLng: json['plannedLatLng'] as String?,
      actualLatLng: json['actualLatLng'] as String?,
      actualAddress: json['actualAddress'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String?,
      photoPath: json['photoPath'] as String?,
      signatureBase64: json['signatureBase64'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      deleted: (json['deleted'] as num?)?.toInt() ?? 0,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$StopToJson(Stop instance) => <String, dynamic>{
      'PrimaryKey': instance.id,
      'tripId': instance.tripId,
      'clientId': instance.clientId,
      'kind': instance.kind,
      'direction': instance.direction,
      'plannedLatLng': instance.plannedLatLng,
      'actualLatLng': instance.actualLatLng,
      'actualAddress': instance.actualAddress,
      'timestamp': instance.timestamp?.toIso8601String(),
      'status': instance.status,
      'note': instance.note,
      'photoPath': instance.photoPath,
      'signatureBase64': instance.signatureBase64,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'deleted': instance.deleted,
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
