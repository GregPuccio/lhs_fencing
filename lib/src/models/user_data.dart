import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:lhs_fencing/src/constants/enums.dart';

class UserData extends Comparable<UserData> {
  String id;
  String email;
  String firstName;
  String lastName;
  Team team;
  Weapon weapon;
  SchoolYear schoolYear;

  bool admin;
  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.team,
    required this.weapon,
    required this.schoolYear,
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
      weapon: Weapon.fromMap(map['weapon'] ?? ""),
      schoolYear: SchoolYear.fromMap(map['schoolYear'] ?? ""),
      admin: map['admin'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, email: $email, firstName: $firstName, lastName: $lastName, team: $team, weapon: $weapon, schoolYear: $schoolYear, admin: $admin)';
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
        admin.hashCode;
  }

  @override
  int compareTo(UserData other) {
    return fullName.compareTo(other.fullName);
  }
}
