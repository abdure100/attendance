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
  
  @JsonKey(name: 'signaturePath')
  final String? signaturePath;
  
  @JsonKey(name: 'accuracy')
  final double? accuracy; // GPS accuracy in meters
  
  @JsonKey(name: 'speed')
  final double? speed; // Speed in m/s

  const Stop({
    this.id,
    required this.tripId,
    required this.clientId,
    required this.kind,
    this.plannedLatLng,
    this.actualLatLng,
    this.actualAddress,
    this.timestamp,
    this.status = 'pending',
    this.note,
    this.photoPath,
    this.signaturePath,
    this.accuracy,
    this.speed,
  });

  factory Stop.fromJson(Map<String, dynamic> json) => _$StopFromJson(json);
  Map<String, dynamic> toJson() => _$StopToJson(this);

  Stop copyWith({
    String? id,
    String? tripId,
    String? clientId,
    String? kind,
    String? plannedLatLng,
    String? actualLatLng,
    String? actualAddress,
    DateTime? timestamp,
    String? status,
    String? note,
    String? photoPath,
    String? signaturePath,
    double? accuracy,
    double? speed,
  }) {
    return Stop(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      clientId: clientId ?? this.clientId,
      kind: kind ?? this.kind,
      plannedLatLng: plannedLatLng ?? this.plannedLatLng,
      actualLatLng: actualLatLng ?? this.actualLatLng,
      actualAddress: actualAddress ?? this.actualAddress,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
    );
  }
}

