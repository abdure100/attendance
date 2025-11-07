// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Outbox _$OutboxFromJson(Map<String, dynamic> json) => Outbox(
      id: json['PrimaryKey'] as String?,
      entity: json['entity'] as String,
      payloadJson: json['payloadJson'] as String,
      op: json['op'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retries: (json['retries'] as num?)?.toInt() ?? 0,
      synced: json['synced'] as bool? ?? false,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$OutboxToJson(Outbox instance) => <String, dynamic>{
      'PrimaryKey': instance.id,
      'entity': instance.entity,
      'payloadJson': instance.payloadJson,
      'op': instance.op,
      'createdAt': instance.createdAt.toIso8601String(),
      'retries': instance.retries,
      'synced': instance.synced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
    };
