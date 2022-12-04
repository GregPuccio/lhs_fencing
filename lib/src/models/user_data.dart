import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class UserData {
  String id;
  String email;
  String firstName;
  String lastName;

  bool admin;
  UserData({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.admin,
  });

  static UserData create(User user) {
    String firstName =
        user.displayName?.substring(0, user.displayName?.indexOf(" ")) ?? "";
    String lastName =
        (user.displayName == null || !user.displayName!.contains(" "))
            ? ""
            : user.displayName?.substring(user.displayName!.indexOf(" ")) ?? "";
    return UserData(
      id: user.uid,
      email: user.email ?? "",
      firstName: firstName,
      lastName: lastName,
      admin: false,
    );
  }

  UserData copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
  }) {
    return UserData(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      admin: admin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'admin': admin,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      admin: map['admin'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, email: $email, firstName: $firstName, lastName: $lastName, admin: $admin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.admin == admin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        admin.hashCode;
  }
}
