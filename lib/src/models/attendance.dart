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
  DateTime checkIn;
  String lateReason;
  DateTime? checkOut;
  String earlyLeaveReason;
  UserData userData;
  List<Comment> comments;
  Attendance({
    required this.id,
    required this.practiceStart,
    required this.practiceEnd,
    required this.checkIn,
    required this.lateReason,
    this.checkOut,
    required this.earlyLeaveReason,
    required this.userData,
    required this.comments,
  });

  static Attendance noUserCreate(Practice practice) {
    return Attendance(
      id: practice.id,
      practiceStart: practice.startTime,
      practiceEnd: practice.endTime,
      checkIn: DateTime.now(),
      lateReason: "",
      earlyLeaveReason: "",
      userData: UserData(
        id: "",
        email: "",
        firstName: "",
        lastName: "",
        admin: false,
      ),
      comments: [],
    );
  }

  static Attendance create(Practice practice, UserData userData) {
    return Attendance(
      id: practice.id,
      practiceStart: practice.startTime,
      practiceEnd: practice.endTime,
      checkIn: DateTime.now(),
      lateReason: "",
      earlyLeaveReason: "",
      userData: userData,
      comments: [],
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
    UserData? userData,
    List<Comment>? comments,
  }) {
    return Attendance(
      id: id ?? this.id,
      practiceStart: practiceStart ?? this.practiceStart,
      practiceEnd: practiceEnd ?? this.practiceEnd,
      checkIn: checkIn ?? this.checkIn,
      lateReason: lateReason ?? this.lateReason,
      checkOut: checkOut ?? this.checkOut,
      earlyLeaveReason: earlyLeaveReason ?? this.earlyLeaveReason,
      userData: userData ?? this.userData,
      comments: comments ?? this.comments,
    );
  }

  String get info {
    String checkedIn = DateFormat('h:mm aa').format(checkIn);
    String? checkedOut =
        checkOut != null ? DateFormat('h:mm aa').format(checkOut!) : null;
    return "Checked in: $checkedIn${lateReason.isNotEmpty ? " - $lateReason" : ""}${checkedOut != null ? "\nChecked out: $checkedOut" : ""}${earlyLeaveReason.isNotEmpty ? " - $earlyLeaveReason" : ""}";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practiceStart': practiceStart.millisecondsSinceEpoch,
      'practiceEnd': practiceEnd.millisecondsSinceEpoch,
      'checkIn': checkIn.millisecondsSinceEpoch,
      'lateReason': lateReason,
      'checkOut': checkOut?.millisecondsSinceEpoch,
      'earlyLeaveReason': earlyLeaveReason,
      'userData': userData.toMap(),
      'comments': comments.map((x) => x.toMap()).toList(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] ?? '',
      practiceStart: DateTime.fromMillisecondsSinceEpoch(map['practiceStart']),
      practiceEnd: DateTime.fromMillisecondsSinceEpoch(map['practiceEnd']),
      checkIn: DateTime.fromMillisecondsSinceEpoch(map['checkIn']),
      lateReason: map['lateReason'] ?? '',
      checkOut: map['checkOut'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checkOut'])
          : null,
      earlyLeaveReason: map['earlyLeaveReason'] ?? '',
      userData: UserData.fromMap(map['userData']),
      comments:
          List<Comment>.from(map['comments']?.map((x) => Comment.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Attendance.fromJson(String source) =>
      Attendance.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Attendance(id: $id, practiceStart: $practiceStart, practiceEnd: $practiceEnd, checkIn: $checkIn, lateReason: $lateReason, checkOut: $checkOut, earlyLeaveReason: $earlyLeaveReason, userData: $userData, comments: $comments)';
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
        other.earlyLeaveReason == earlyLeaveReason &&
        other.userData == userData &&
        listEquals(other.comments, comments);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        practiceStart.hashCode ^
        practiceEnd.hashCode ^
        checkIn.hashCode ^
        lateReason.hashCode ^
        checkOut.hashCode ^
        earlyLeaveReason.hashCode ^
        userData.hashCode ^
        comments.hashCode;
  }
}
