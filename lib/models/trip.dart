import 'package:json_annotation/json_annotation.dart';

part 'trip.g.dart';

@JsonSerializable()
class Trip {
  @JsonKey(name: 'PrimaryKey')
  final String? id;
  
  @JsonKey(name: 'date')
  final DateTime date;
  
  @JsonKey(name: 'routeName')
  final String? routeName;
  
  @JsonKey(name: 'driverId')
  final String driverId;
  
  @JsonKey(name: 'vehicleId')
  final String? vehicleId;
  
  @JsonKey(name: 'direction')
  final String direction; // "AM" | "PM"
  
  @JsonKey(name: 'status')
  final String? status; // "pending" | "in_progress" | "completed"
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  const Trip({
    this.id,
    required this.date,
    this.routeName,
    required this.driverId,
    this.vehicleId,
    required this.direction,
    this.status,
    this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  Trip copyWith({
    String? id,
    DateTime? date,
    String? routeName,
    String? driverId,
    String? vehicleId,
    String? direction,
    String? status,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      date: date ?? this.date,
      routeName: routeName ?? this.routeName,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

