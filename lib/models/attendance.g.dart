// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendance _$AttendanceFromJson(Map<String, dynamic> json) => Attendance(
      id: json['PrimaryKey'] as String?,
      clientId: json['clientId'] as String,
      date: DateTime.parse(json['date'] as String),
      timeIn: json['timeIn'] == null
          ? null
          : DateTime.parse(json['timeIn'] as String),
      timeOut: json['timeOut'] == null
          ? null
          : DateTime.parse(json['timeOut'] as String),
      capturedBy: json['capturedBy'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AttendanceToJson(Attendance instance) =>
    <String, dynamic>{
      'PrimaryKey': instance.id,
      'clientId': instance.clientId,
      'date': instance.date.toIso8601String(),
      'timeIn': instance.timeIn?.toIso8601String(),
      'timeOut': instance.timeOut?.toIso8601String(),
      'capturedBy': instance.capturedBy,
      'note': instance.note,
    };
