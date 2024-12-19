import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:uuid/uuid.dart';

import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/equipment.dart';

mixin Compare<T> implements Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}

class UserData with Compare<UserData> {
  String id;
  String email;
  String firstName;
  String lastName;
  String usaFencingID;
  Team team;
  Weapon weapon;
  SchoolYear schoolYear;
  DateTime startDate;
  List<DayOfWeek> clubDays;
  String rating;
  String club;
  Equipment equipment;
  bool active;

  bool admin;

  UserData(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.usaFencingID,
      required this.team,
      required this.weapon,
      required this.schoolYear,
      required this.startDate,
      required this.clubDays,
      required this.rating,
      required this.club,
      required this.equipment,
      required this.admin,
      required this.active});

  /// [firstName] [lastInitial].
  String get fullShortenedName {
    return "$firstName ${lastName.substring(0, 1)}.";
  }

  static UserData noUserCreate() {
    return UserData(
      id: const Uuid().v4(),
      email: "",
      firstName: "",
      lastName: "",
      usaFencingID: "",
      admin: false,
      team: Team.boys,
      weapon: Weapon.unsure,
      schoolYear: SchoolYear.freshman,
      startDate: DateTime.now(),
      clubDays: [],
      rating: "",
      club: "",
      equipment: Equipment.create(),
      active: true,
    );
  }

  static UserData create(User user) {
    String firstName =
        user.displayName?.substring(0, user.displayName?.indexOf(" ")) ?? "";
    String lastName = (user.displayName == null ||
            !user.displayName!.contains(" "))
        ? ""
        : user.displayName?.substring(user.displayName!.indexOf(" ") + 1) ?? "";
    return UserData(
      id: user.uid,
      email: user.email ?? "",
      firstName: firstName,
      lastName: lastName,
      usaFencingID: "",
      admin: false,
      team: Team.boys,
      weapon: Weapon.unsure,
      schoolYear: SchoolYear.freshman,
      startDate: DateTime.now(),
      clubDays: [],
      rating: "",
      club: "",
      equipment: Equipment.create(),
      active: true,
    );
  }

  String get fullName {
    return "$firstName $lastName";
  }

  String get initials {
    return "${firstName.substring(0, 1).toUpperCase()}${lastName.substring(0, 1).toUpperCase()}";
  }

  String get info {
    return "${team.capitalizedName} ${weapon.type} ${rating.isNotEmpty ? rating : "U"}";
  }

  UserData copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? usaFencingID,
    Team? team,
    Weapon? weapon,
    SchoolYear? schoolYear,
    DateTime? startDate,
    List<DayOfWeek>? clubDays,
    String? rating,
    String? club,
    Equipment? equipment,
    bool? admin,
    bool? manager,
    bool? active,
  }) {
    return UserData(
        id: id ?? this.id,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        usaFencingID: usaFencingID ?? this.usaFencingID,
        team: team ?? this.team,
        weapon: weapon ?? this.weapon,
        schoolYear: schoolYear ?? this.schoolYear,
        startDate: startDate ?? this.startDate,
        clubDays: clubDays ?? this.clubDays,
        rating: rating ?? this.rating,
        club: club ?? this.club,
        equipment: equipment ?? this.equipment,
        admin: admin ?? this.admin,
        active: active ?? this.active);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'usaFencingID': usaFencingID,
      'team': team.toMap(),
      'weapon': weapon.toMap(),
      'schoolYear': schoolYear.toMap(),
      'startDate': startDate.millisecondsSinceEpoch,
      'clubDays': clubDays.map((x) => x.index).toList(),
      'rating': rating,
      'club': club,
      'equipment': equipment.toMap(),
      'admin': admin,
      'active': active,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      usaFencingID: map['usaFencingID'] ?? '',
      team: Team.fromMap(map['team'] ?? ""),
      weapon: Weapon.fromMap(map['weapon'] ?? ""),
      schoolYear: SchoolYear.fromMap(map['schoolYear'] ?? ""),
      startDate: DateTime.fromMillisecondsSinceEpoch(
          map['startDate'] ?? DateTime.now().millisecondsSinceEpoch),
      clubDays: List<DayOfWeek>.from(
          map['clubDays']?.map((x) => DayOfWeek.values[x]) ?? []),
      rating: map['rating'] ?? '',
      club: map['club'] ?? '',
      equipment: Equipment.fromMap(map['equipment'] ?? {}),
      admin: map['admin'] ?? false,
      active: map['active'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, email: $email, firstName: $firstName, lastName: $lastName, usaFencingID: $usaFencingID, team: $team, weapon: $weapon, schoolYear: $schoolYear, startDate: $startDate, clubDays: $clubDays, rating: $rating, club: $club, equipment: $equipment, admin: $admin, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  int compareTo(UserData other) {
    return fullName.compareTo(other.fullName);
  }

  bool isAtPractice(List<Attendance> attendances, String? currentPracticeID) {
    if (currentPracticeID == null) return false;
    List<Attendance> fencerAttendances =
        attendances.where((att) => att.userData.id == id).toList();
    return fencerAttendances
        .where((att) => att.id == currentPracticeID)
        .any((att) => att.attended);
  }
}
