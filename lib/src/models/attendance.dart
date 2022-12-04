import 'dart:convert';

import 'package:lhs_fencing/src/models/practice.dart';

class Attendance {
  String id;
  DateTime practiceStart;
  DateTime practiceEnd;
  DateTime checkIn;
  String lateReason;
  DateTime checkOut;
  String earlyLeaveReason;
  Attendance({
    required this.id,
    required this.practiceStart,
    required this.practiceEnd,
    required this.checkIn,
    required this.lateReason,
    required this.checkOut,
    required this.earlyLeaveReason,
  });

  static Attendance create(Practice practice) {
    return Attendance(
      id: "",
      practiceStart: practice.startTime,
      practiceEnd: practice.endTime,
      checkIn: DateTime.now(),
      lateReason: "",
      checkOut: DateTime.now(),
      earlyLeaveReason: "",
    );
  }

  Attendance copyWith({
    String? id,
    DateTime? practiceStart,
    DateTime? practiceEnd,
    DateTime? checkIn,
    String? lateReason,
    DateTime? checkOut,
    String? earlyLeaveReason,
  }) {
    return Attendance(
      id: id ?? this.id,
      practiceStart: practiceStart ?? this.practiceStart,
      practiceEnd: practiceEnd ?? this.practiceEnd,
      checkIn: checkIn ?? this.checkIn,
      lateReason: lateReason ?? this.lateReason,
      checkOut: checkOut ?? this.checkOut,
      earlyLeaveReason: earlyLeaveReason ?? this.earlyLeaveReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practiceStart': practiceStart.millisecondsSinceEpoch,
      'practiceEnd': practiceEnd.millisecondsSinceEpoch,
      'checkIn': checkIn.millisecondsSinceEpoch,
      'lateReason': lateReason,
      'checkOut': checkOut.millisecondsSinceEpoch,
      'earlyLeaveReason': earlyLeaveReason,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      practiceStart: DateTime.fromMillisecondsSinceEpoch(map['practiceStart']),
      practiceEnd: DateTime.fromMillisecondsSinceEpoch(map['practiceEnd']),
      checkIn: DateTime.fromMillisecondsSinceEpoch(map['checkIn']),
      lateReason: map['lateReason'] ?? '',
      checkOut: DateTime.fromMillisecondsSinceEpoch(map['checkOut']),
      earlyLeaveReason: map['earlyLeaveReason'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Attendance.fromJson(String source) =>
      Attendance.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Attendance(id: $id, practiceStart: $practiceStart, practiceEnd: $practiceEnd, checkIn: $checkIn, lateReason: $lateReason, checkOut: $checkOut, earlyLeaveReason: $earlyLeaveReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attendance &&
        other.id == id &&
        other.practiceStart == practiceStart &&
        other.practiceEnd == practiceEnd &&
        other.checkIn == checkIn &&
        other.lateReason == lateReason &&
        other.checkOut == checkOut &&
        other.earlyLeaveReason == earlyLeaveReason;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        practiceStart.hashCode ^
        practiceEnd.hashCode ^
        checkIn.hashCode ^
        lateReason.hashCode ^
        checkOut.hashCode ^
        earlyLeaveReason.hashCode;
  }
}
