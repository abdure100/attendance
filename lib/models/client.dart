import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  @JsonKey(name: 'PrimaryKey')
  final String id;
  @JsonKey(name: 'namefull')
  final String name;
  @JsonKey(name: 'address')
  final String? address;
  @JsonKey(name: 'phone')
  final String? phone;
  @JsonKey(name: 'Email')
  final String? email;
  @JsonKey(name: 'Company')
  final String? agencyId;
  @JsonKey(name: 'dob')
  final String? dateOfBirth;
  @JsonKey(name: 'caregiverPhone')
  final String? caregiverPhone;
  @JsonKey(name: 'homeLatLng')
  final String? homeLatLng; // "lat,lng" format
  @JsonKey(name: 'homeAddress')
  final String? homeAddress;

  const Client({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.agencyId,
    this.dateOfBirth,
    this.caregiverPhone,
    this.homeLatLng,
    this.homeAddress,
  });

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);
  Map<String, dynamic> toJson() => _$ClientToJson(this);

  Client copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? agencyId,
    String? dateOfBirth,
    String? caregiverPhone,
    String? homeLatLng,
    String? homeAddress,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      agencyId: agencyId ?? this.agencyId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      homeLatLng: homeLatLng ?? this.homeLatLng,
      homeAddress: homeAddress ?? this.homeAddress,
    );
  }

  @override
  String toString() => name;
}
