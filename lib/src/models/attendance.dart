import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Attendance {
  /// this [id] is created based off of the practice id, I can use these ids
  /// to find all of the fencers that have attended a specific practice
  String id;
  DateTime practiceStart;
  DateTime practiceEnd;
  DateTime? checkIn;
  DateTime? checkOut;
  UserData userData;
  List<Comment> comments;
  bool excusedAbsense;
  bool unexcusedAbsense;
  bool participated;

  Attendance({
    required this.id,
    required this.practiceStart,
    required this.practiceEnd,
    this.checkIn,
    this.checkOut,
    required this.userData,
    required this.comments,
    required this.excusedAbsense,
    required this.unexcusedAbsense,
    this.participated = false,
  });

  static Attendance noUserCreate(Practice practice) {
    return Attendance(
      id: practice.id,
      practiceStart: practice.startTime,
      practiceEnd: practice.endTime,
      userData: UserData.noUserCreate(),
      comments: [],
      excusedAbsense: false,
      unexcusedAbsense: false,
    );
  }

  static Attendance create(Practice practice, UserData userData) {
    return Attendance(
      id: practice.id,
      practiceStart: practice.startTime,
      practiceEnd: practice.endTime,
      userData: userData,
      comments: [],
      excusedAbsense: false,
      unexcusedAbsense: false,
    );
  }

  String get practiceStartString {
    return DateFormat("EEEE, MMM d @ h:mm aa").format(practiceStart);
  }

  Attendance copyWith({
    String? id,
    DateTime? practiceStart,
    DateTime? practiceEnd,
    DateTime? checkIn,
    DateTime? checkOut,
    UserData? userData,
    List<Comment>? comments,
    bool? excusedAbsense,
    bool? unexcusedAbsense,
    bool? participated,
  }) {
    return Attendance(
      id: id ?? this.id,
      practiceStart: practiceStart ?? this.practiceStart,
      practiceEnd: practiceEnd ?? this.practiceEnd,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      userData: userData ?? this.userData,
      comments: comments ?? this.comments,
      excusedAbsense: excusedAbsense ?? this.excusedAbsense,
      unexcusedAbsense: unexcusedAbsense ?? this.unexcusedAbsense,
      participated: participated ?? this.participated,
    );
  }

  bool get attended {
    return checkIn != null;
  }

  bool get tooSoonForCheckIn =>
      DateTime.now().difference(practiceStart).inMinutes < -15;
  bool get isTooLate => DateTime.now().difference(practiceStart).inMinutes > 60;
  bool get canCheckIn =>
      DateTime.now().difference(practiceStart).inMinutes >= -15;
  bool get isLate => DateTime.now().difference(practiceStart).inMinutes > 15;
  bool get practiceOver => DateTime.now().isAfter(practiceEnd);

  String get attendanceStatus {
    String checkedIn =
        checkIn != null ? DateFormat('h:mm aa').format(checkIn!) : "";

    String checkedOut =
        checkOut != null ? " - ${DateFormat('h:mm aa').format(checkOut!)}" : "";
    String info =
        "${practiceOver ? "Attended |" : "Checked In"} $checkedIn$checkedOut";

    String text = "Status: ";
    if (attended) {
      text += info;
    } else if (practiceOver) {
      if (excusedAbsense) {
        text += "Absent - Excused";
      } else if (unexcusedAbsense) {
        text += "Absent - Unexcused";
      } else {
        text += "Uncategorized Attendance";
      }
    } else {
      if (tooSoonForCheckIn) {
        text += "Too Soon For Check In";
      } else if (isTooLate) {
        text += "Late Arrival - Check In With Coach";
      } else if (canCheckIn) {
        if (excusedAbsense) {
          text += "Absent - Excused";
        } else if (unexcusedAbsense) {
          text += "Absent - Unexcused";
        } else if (isLate) {
          text += "Late Arrival - Can Check In";
        } else {
          text += "On Time - Can Check In";
        }
      }
    }
    return text;
  }

  bool get wasLate {
    if (checkIn == null) {
      return false;
    } else {
      return practiceStart.difference(checkIn!).inMinutes < -15;
    }
  }

  bool get leftEarly {
    if (checkOut == null) {
      return false;
    } else {
      return practiceEnd.difference(checkOut!).inMinutes > 15;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practiceStart': practiceStart.millisecondsSinceEpoch,
      'practiceEnd': practiceEnd.millisecondsSinceEpoch,
      'checkIn': checkIn?.millisecondsSinceEpoch,
      'checkOut': checkOut?.millisecondsSinceEpoch,
      'userData': userData.toMap(),
      'comments': comments.map((x) => x.toMap()).toList(),
      'excusedAbsense': excusedAbsense,
      'unexcusedAbsense': unexcusedAbsense,
      'participated': participated,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      practiceStart: DateTime.fromMillisecondsSinceEpoch(map['practiceStart']),
      practiceEnd: DateTime.fromMillisecondsSinceEpoch(map['practiceEnd']),
      checkIn: map['checkIn'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checkIn'])
          : null,
      checkOut: map['checkOut'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checkOut'])
          : null,
      userData: UserData.fromMap(map['userData']),
      comments: List<Comment>.from(
          map['comments']?.map((x) => Comment.fromMap(x)) ?? []),
      excusedAbsense: map['excusedAbsense'] ?? false,
      unexcusedAbsense: map['unexcusedAbsense'] ?? false,
      participated: map['participated'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Attendance.fromJson(String source) =>
      Attendance.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Attendance(id: $id, practiceStart: $practiceStart, practiceEnd: $practiceEnd, checkIn: $checkIn, checkOut: $checkOut, userData: $userData, comments: $comments, excusedAbsense: $excusedAbsense, unexcusedAbsense: $unexcusedAbsense)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attendance &&
        other.id == id &&
        other.practiceStart == practiceStart &&
        other.practiceEnd == practiceEnd &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.userData == userData &&
        listEquals(other.comments, comments) &&
        other.excusedAbsense == excusedAbsense &&
        other.unexcusedAbsense == unexcusedAbsense;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        practiceStart.hashCode ^
        practiceEnd.hashCode ^
        checkIn.hashCode ^
        checkOut.hashCode ^
        userData.hashCode ^
        comments.hashCode ^
        excusedAbsense.hashCode ^
        unexcusedAbsense.hashCode;
  }
}
