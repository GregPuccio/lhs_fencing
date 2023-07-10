import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:lhs_fencing/src/constants/enums.dart';

class UserData extends Comparable<UserData> {
  String id;
  String email;
  String firstName;
  String lastName;
  Team team;
  Weapon weapon;
  SchoolYear schoolYear;
  int yoe;
  List<String> foodAllergies;
  List<DayOfWeek> clubDays;

  bool admin;

  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.team,
    required this.weapon,
    required this.schoolYear,
    required this.yoe,
    required this.foodAllergies,
    required this.clubDays,
    required this.admin,
  });

  static UserData noUserCreate() {
    return UserData(
      id: "",
      email: "",
      firstName: "",
      lastName: "",
      admin: false,
      team: Team.boys,
      weapon: Weapon.foil,
      schoolYear: SchoolYear.freshman,
      yoe: 0,
      foodAllergies: [],
      clubDays: [],
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
      admin: false,
      team: Team.boys,
      weapon: Weapon.foil,
      schoolYear: SchoolYear.freshman,
      yoe: 0,
      foodAllergies: [],
      clubDays: [],
    );
  }

  String get fullName {
    return "$firstName $lastName";
  }

  String get initials {
    return "${firstName.substring(0, 1).toUpperCase()}${lastName.substring(0, 1).toUpperCase()}";
  }

  UserData copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    Team? team,
    Weapon? weapon,
    SchoolYear? schoolYear,
    int? yoe,
    List<String>? foodAllergies,
    List<DayOfWeek>? clubDays,
    bool? admin,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      team: team ?? this.team,
      weapon: weapon ?? this.weapon,
      schoolYear: schoolYear ?? this.schoolYear,
      yoe: yoe ?? this.yoe,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      clubDays: clubDays ?? this.clubDays,
      admin: admin ?? this.admin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'team': team.toMap(),
      'weapon': weapon.toMap(),
      'schoolYear': schoolYear.toMap(),
      'yoe': yoe,
      'foodAllergies': foodAllergies,
      'clubDays': clubDays.map((x) => x.index).toList(),
      'admin': admin,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      team: Team.fromMap(map['team'] ?? ""),
      weapon: Weapon.fromMap(map['weapon']),
      schoolYear: SchoolYear.fromMap(map['schoolYear']),
      yoe: map['yoe']?.toInt() ?? 0,
      foodAllergies: List<String>.from(map['foodAllergies']),
      clubDays: List<DayOfWeek>.from(
          map['clubDays']?.map((x) => DayOfWeek.values[x])),
      admin: map['admin'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, email: $email, firstName: $firstName, lastName: $lastName, team: $team, weapon: $weapon, schoolYear: $schoolYear, yoe: $yoe, foodAllergies: $foodAllergies, clubDays: $clubDays, admin: $admin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.team == team &&
        other.weapon == weapon &&
        other.schoolYear == schoolYear &&
        other.yoe == yoe &&
        listEquals(other.foodAllergies, foodAllergies) &&
        listEquals(other.clubDays, clubDays) &&
        other.admin == admin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        team.hashCode ^
        weapon.hashCode ^
        schoolYear.hashCode ^
        yoe.hashCode ^
        foodAllergies.hashCode ^
        clubDays.hashCode ^
        admin.hashCode;
  }

  @override
  int compareTo(UserData other) {
    return fullName.compareTo(other.fullName);
  }
}
