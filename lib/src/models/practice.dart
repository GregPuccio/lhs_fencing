import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Practice {
  String id;
  String location;
  DateTime? atGymTime;
  DateTime? busTime;
  DateTime startTime;
  DateTime endTime;
  TypePractice type;
  Team team;
  Map<String, DateTime>? activities;
  List<UserData> busCoaches;
  Practice({
    required this.id,
    required this.location,
    this.atGymTime,
    this.busTime,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.team,
    this.activities,
    required this.busCoaches,
  });

  String get startString {
    return DateFormat("EEEE, MMM d @ h:mm aa").format(startTime);
  }

  String get emailString {
    return DateFormat("MM/dd").format(startTime);
  }

  String emailMessage(List<UserData> fencerList, String tod, UserData coach) {
    return """bcc=${List.generate(fencerList.length, (index) => fencerList[index].email).join(",")}&subject=Livingston Fencing Attendance $emailString
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
      return "${atGymTime != null ? "At Gym: ${DateFormat("hh:mm aa").format(atGymTime!)} " : ""}${busTime != null ? "Bus: ${DateFormat("hh:mm aa").format(busTime!)}\n" : ""}Scheduled: ${DateFormat("hh:mm").format(startTime)}-${DateFormat("hh:mm aa").format(endTime)}";
    } else {
      return "${atGymTime != null ? "At Gym: ${DateFormat("hh:mm aa").format(atGymTime!)} " : ""}${busTime != null ? "Bus: ${DateFormat("hh:mm aa").format(busTime!)}\n" : ""}Scheduled: ${DateFormat("hh:mm aa").format(startTime)} - ${DateFormat("hh:mm aa").format(endTime)}";
    }
  }

  bool get tooSoonForCheckIn {
    switch (type) {
      case TypePractice.practice:
      case TypePractice.quad:
        return DateTime.now().difference(startTime).inMinutes < -15;

      case TypePractice.meet:
      case TypePractice.fundraiser:
      case TypePractice.spectatingHome:
        return DateTime.now().difference(startTime).inMinutes < -45;

      case TypePractice.awayMeet:
      case TypePractice.tournament:
      case TypePractice.spectatingAway:
        return DateTime.now().difference(busTime!).inMinutes < -30;
    }
  }

  bool get canCheckIn {
    switch (type) {
      case TypePractice.practice:
      case TypePractice.quad:
        return DateTime.now().difference(startTime).inMinutes >= -15;

      case TypePractice.meet:
      case TypePractice.fundraiser:
      case TypePractice.spectatingHome:
        return DateTime.now().difference(startTime).inMinutes >= -45;

      case TypePractice.awayMeet:
      case TypePractice.tournament:
      case TypePractice.spectatingAway:
        return DateTime.now().difference(busTime!).inMinutes >= -30;
    }
  }

  bool get isLate => DateTime.now().difference(startTime).inMinutes > 15;
  bool get isTooLate => DateTime.now().difference(startTime).inMinutes > 60;
  bool get isOver => DateTime.now().isAfter(endTime);
  bool get isLeavingEarly => DateTime.now().difference(endTime).inMinutes < -15;

  Practice copyWith({
    String? id,
    String? location,
    DateTime? atGymTime,
    DateTime? busTime,
    DateTime? startTime,
    DateTime? endTime,
    TypePractice? type,
    Team? team,
    Map<String, DateTime>? activities,
    List<UserData>? busCoaches,
  }) {
    return Practice(
      id: id ?? this.id,
      location: location ?? this.location,
      atGymTime: atGymTime ?? this.atGymTime,
      busTime: busTime ?? this.busTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      team: team ?? this.team,
      activities: activities ?? this.activities,
      busCoaches: busCoaches ?? this.busCoaches,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'atGymTime': atGymTime?.millisecondsSinceEpoch,
      'busTime': busTime?.millisecondsSinceEpoch,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'type': type.toMap(),
      'team': team.toMap(),
      'activities': activities,
      'busCoaches': busCoaches.map((x) => x.toMap()).toList(),
    };
  }

  factory Practice.fromMap(Map<String, dynamic> map) {
    return Practice(
      id: map['id'] ?? '',
      location: map['location'] ?? '',
      atGymTime: map['atGymTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['atGymTime'])
          : null,
      busTime: map['busTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['busTime'])
          : null,
      startTime: map['startTime'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['startTime'])
          : map['startTime']?.toDate(),
      endTime: map['endTime'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : map['endTime']?.toDate(),
      type: TypePractice.fromMap(map['type'] ?? "practice"),
      team: Team.fromMap(map['team'] ?? "both"),
      activities: map['activities'] != null
          ? (map['activities'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                value.toDate(),
              ),
            )
          : {},
      busCoaches: map['busCoaches'] != null
          ? List<UserData>.from(
              map['busCoaches'].map((x) => UserData.fromMap(x)))
          : [],
    );
  }

  Practice.clone(Practice practice)
      : this(
          id: practice.id,
          location: practice.location,
          atGymTime: practice.atGymTime,
          busTime: practice.busTime,
          startTime: practice.startTime,
          endTime: practice.endTime,
          type: practice.type,
          team: practice.team,
          activities: practice.activities,
          busCoaches: practice.busCoaches,
        );

  String toJson() => json.encode(toMap());

  factory Practice.fromJson(String source) =>
      Practice.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Practice(id: $id, location: $location, startTime: $startTime, endTime: $endTime, type: $type, team: $team, activities: $activities, busCoaches: $busCoaches)';
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
        mapEquals(other.activities, activities) &&
        listEquals(other.busCoaches, busCoaches);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        location.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        type.hashCode ^
        team.hashCode ^
        activities.hashCode ^
        busCoaches.hashCode;
  }
}
