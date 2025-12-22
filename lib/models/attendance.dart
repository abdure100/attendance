import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class Attendance {
  @JsonKey(name: 'PrimaryKey')
  final String? id;
  
  @JsonKey(name: 'clientId')
  final String clientId;
  
  @JsonKey(name: 'date')
  final DateTime date;
  
  @JsonKey(name: 'timeIn')
  final DateTime? timeIn;
  
  @JsonKey(name: 'timeOut')
  final DateTime? timeOut;
  
  @JsonKey(name: 'capturedBy')
  final String capturedBy; // staffId
  
  @JsonKey(name: 'note')
  final String? note;
  
  @JsonKey(name: 'signatureInBase64')
  final String? signatureInBase64; // Base64 signature for time-in
  
  @JsonKey(name: 'signatureOutBase64')
  final String? signatureOutBase64; // Base64 signature for time-out

  const Attendance({
    this.id,
    required this.clientId,
    required this.date,
    this.timeIn,
    this.timeOut,
    required this.capturedBy,
    this.note,
    this.signatureInBase64,
    this.signatureOutBase64,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  Attendance copyWith({
    String? id,
    String? clientId,
    DateTime? date,
    DateTime? timeIn,
    DateTime? timeOut,
    String? capturedBy,
    String? note,
    String? signatureInBase64,
    String? signatureOutBase64,
  }) {
    return Attendance(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      capturedBy: capturedBy ?? this.capturedBy,
      note: note ?? this.note,
      signatureInBase64: signatureInBase64 ?? this.signatureInBase64,
      signatureOutBase64: signatureOutBase64 ?? this.signatureOutBase64,
    );
  }
}

