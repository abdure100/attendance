import 'package:json_annotation/json_annotation.dart';

part 'stop.g.dart';

@JsonSerializable()
class Stop {
  @JsonKey(name: 'PrimaryKey')
  final String? id;
  
  @JsonKey(name: 'tripId')
  final String tripId;
  
  @JsonKey(name: 'clientId')
  final String clientId;
  
  @JsonKey(name: 'kind')
  final String kind; // "pickup" | "dropoff"
  
  @JsonKey(name: 'direction')
  final String? direction; // "AM" | "PM" - from parent trip
  
  @JsonKey(name: 'plannedLatLng')
  final String? plannedLatLng; // "lat,lng" format
  
  @JsonKey(name: 'actualLatLng')
  final String? actualLatLng; // "lat,lng" format
  
  @JsonKey(name: 'actualAddress')
  final String? actualAddress;
  
  @JsonKey(name: 'timestamp')
  final DateTime? timestamp;
  
  @JsonKey(name: 'status')
  final String status; // "pending" | "done"
  
  @JsonKey(name: 'note')
  final String? note;
  
  @JsonKey(name: 'photoPath')
  final String? photoPath;
  
  @JsonKey(name: 'signatureBase64')
  final String? signatureBase64; // Base64 encoded PNG signature
  
  @JsonKey(name: 'accuracy')
  final double? accuracy; // GPS accuracy in meters
  
  @JsonKey(name: 'speed')
  final double? speed; // Speed in m/s
  
  @JsonKey(name: 'deleted')
  final int deleted; // 0 = not deleted, 1 = deleted
  
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt; // Soft delete timestamp

  const Stop({
    this.id,
    required this.tripId,
    required this.clientId,
    required this.kind,
    this.direction,
    this.plannedLatLng,
    this.actualLatLng,
    this.actualAddress,
    this.timestamp,
    this.status = 'pending',
    this.note,
    this.photoPath,
    this.signatureBase64,
    this.accuracy,
    this.speed,
    this.deleted = 0,
    this.deletedAt,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
  Map<String, dynamic> toJson() => _$StopToJson(this);

  Stop copyWith({
    String? id,
    String? tripId,
    String? clientId,
    String? kind,
    String? direction,
    String? plannedLatLng,
    String? actualLatLng,
    String? actualAddress,
    DateTime? timestamp,
    String? status,
    String? note,
    String? photoPath,
    String? signatureBase64,
    double? accuracy,
    double? speed,
    int? deleted,
    DateTime? deletedAt,
  }) {
    return Stop(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      clientId: clientId ?? this.clientId,
      kind: kind ?? this.kind,
      direction: direction ?? this.direction,
      plannedLatLng: plannedLatLng ?? this.plannedLatLng,
      actualLatLng: actualLatLng ?? this.actualLatLng,
      actualAddress: actualAddress ?? this.actualAddress,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      deleted: deleted ?? this.deleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

