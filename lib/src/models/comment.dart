import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:uuid/uuid.dart';

class Comment {
  String id;
  String text;
  UserData user;
  DateTime createdAt;
  Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.createdAt,
  });

  static Comment create(UserData user) {
    return Comment(
      id: const Uuid().v4(),
      text: "",
      user: user,
      createdAt: DateTime.now(),
    );
  }

  String get createdAtString {
    return DateFormat("MMM d - h:mm aa").format(createdAt);
  }

  Comment copyWith({
    String? id,
    String? text,
    UserData? user,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user': user.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      user: UserData.fromMap(map['user']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, user: $user, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.user == user &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ text.hashCode ^ user.hashCode ^ createdAt.hashCode;
  }
}
