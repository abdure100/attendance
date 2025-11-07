import 'package:json_annotation/json_annotation.dart';

part 'outbox.g.dart';

@JsonSerializable()
class Outbox {
  @JsonKey(name: 'PrimaryKey')
  final String? id;
  
  @JsonKey(name: 'entity')
  final String entity; // "trip" | "stop" | "attendance"
  
  @JsonKey(name: 'payloadJson')
  final String payloadJson; // JSON string of the entity
  
  @JsonKey(name: 'op')
  final String op; // "create" | "update"
  
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  
  @JsonKey(name: 'retries')
  final int retries;
  
  @JsonKey(name: 'synced')
  final bool synced;
  
  @JsonKey(name: 'syncedAt')
  final DateTime? syncedAt;

  const Outbox({
    this.id,
    required this.entity,
    required this.payloadJson,
    required this.op,
    required this.createdAt,
    this.retries = 0,
    this.synced = false,
    this.syncedAt,
  });

  factory Outbox.fromJson(Map<String, dynamic> json) => _$OutboxFromJson(json);
  Map<String, dynamic> toJson() => _$OutboxToJson(this);

  Outbox copyWith({
    String? id,
    String? entity,
    String? payloadJson,
    String? op,
    DateTime? createdAt,
    int? retries,
    bool? synced,
    DateTime? syncedAt,
  }) {
    return Outbox(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      payloadJson: payloadJson ?? this.payloadJson,
      op: op ?? this.op,
      createdAt: createdAt ?? this.createdAt,
      retries: retries ?? this.retries,
      synced: synced ?? this.synced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}

