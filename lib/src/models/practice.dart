import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Practice {
  String id;
  String location;
  DateTime startTime;
  DateTime endTime;
  TypePractice type;
  Team team;
  Map activities;
  Practice({
    required this.id,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.team,
    required this.activities,
  });

  String get startString {
    return DateFormat("EEEE, MMM d @ h:mm aa").format(startTime);
  }

  String get emailString {
    return DateFormat("MM/dd").format(startTime);
  }

  String emailMessage(
      List<List<UserData>> fencerLists, String tod, UserData coach) {
    return """bcc=${List.generate(fencerLists.last.length, (index) => fencerLists.last[index].email).join(",")}&subject=$emailString LHS Fencing Attendance
&body=Good $tod students,

Our records are showing that you did not attend the ${type.type} on $emailString.
Please provide a reason on the attendance site ASAP. Make sure you do this ahead of time for future absenses.

lhsfencing.web.app

Thank you,
Coach ${coach.firstName}
    """;
  }

  String get timeframe {
    String retVal = "";
    if (startTime.isToday) {
      retVal += "Today";
    } else if (startTime.isTomorrow) {
      retVal += "Tomorrow";
    } else if (startTime.isThisWeek) {
      retVal += DateFormat("EEEE ").format(startTime);
    } else {
      retVal += DateFormat("EEE, M/d").format(startTime);
    }
    return retVal;
  }

  String get runTime {
    if (DateFormat("a").format(startTime) == DateFormat("a").format(endTime)) {
      return "Scheduled: ${DateFormat("hh:mm").format(startTime)}-${DateFormat("hh:mm aa").format(endTime)}";
    } else {
      return "Scheduled: ${DateFormat("hh:mm aa").format(startTime)} - ${DateFormat("hh:mm aa").format(endTime)}";
    }
  }

  bool get tooSoonForCheckIn =>
      DateTime.now().difference(startTime).inMinutes < -15;
  bool get isTooLate => DateTime.now().difference(startTime).inMinutes > 60;
  bool get canCheckIn => DateTime.now().difference(startTime).inMinutes >= -15;
  bool get isLate => DateTime.now().difference(startTime).inMinutes > 15;
  bool get practiceOver => DateTime.now().isAfter(endTime);

  Practice copyWith({
    String? id,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    TypePractice? type,
    Team? team,
    Map? activities,
  }) {
    return Practice(
      id: id ?? this.id,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      team: team ?? this.team,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'type': type.toMap(),
      'team': team.toMap(),
      // 'activities': activities,
    };
  }

  factory Practice.fromMap(Map<String, dynamic> map) {
    return Practice(
      id: map['id'] ?? '',
      location: map['location'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      type: TypePractice.fromMap(map['type'] ?? ""),
      team: Team.fromMap(map['team'] ?? ""),
      activities: Map.from(map['activities'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Practice.fromJson(String source) =>
      Practice.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Practice(id: $id, location: $location, startTime: $startTime, endTime: $endTime, type: $type, team: $team, activities: $activities)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Practice &&
        other.id == id &&
        other.location == location &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.type == type &&
        other.team == team &&
        mapEquals(other.activities, activities);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        location.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        type.hashCode ^
        team.hashCode ^
        activities.hashCode;
  }
}
