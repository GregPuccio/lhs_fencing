import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lhs_fencing/src/models/attendance.dart';

class AttendanceMonth {
  String id;
  List<Attendance> attendances;
  DateTime month;

  AttendanceMonth({
    required this.id,
    required this.attendances,
    required this.month,
  });

  AttendanceMonth copyWith({
    String? id,
    List<Attendance>? attendances,
    DateTime? month,
  }) {
    return AttendanceMonth(
      id: id ?? this.id,
      attendances: attendances ?? this.attendances,
      month: month ?? this.month,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendances': attendances.map((x) => x.toMap()).toList(),
      'month': month.millisecondsSinceEpoch,
    };
  }

  factory AttendanceMonth.fromMap(Map<String, dynamic> map) {
    return AttendanceMonth(
      id: map['id'] ?? '',
      attendances: List<Attendance>.from(
          map['attendances']?.map((x) => Attendance.fromMap(x))),
      month: DateTime.fromMillisecondsSinceEpoch(map['month']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceMonth.fromJson(String source) =>
      AttendanceMonth.fromMap(json.decode(source));

  @override
  String toString() =>
      'AttendanceMonth(id: $id, attendances: $attendances, month: $month)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceMonth &&
        other.id == id &&
        listEquals(other.attendances, attendances) &&
        other.month == month;
  }

  @override
  int get hashCode => id.hashCode ^ attendances.hashCode ^ month.hashCode;
}
