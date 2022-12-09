import 'dart:convert';

import 'package:lhs_fencing/src/models/user_data.dart';

class Comment {
  String id;
  String text;
  UserData user;
  Comment({
    required this.id,
    required this.text,
    required this.user,
  });

  Comment copyWith({
    String? id,
    String? text,
    UserData? user,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'user': user.toMap(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      user: UserData.fromMap(map['user']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

  @override
  String toString() => 'Comment(id: $id, text: $text, user: $user)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.user == user;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ user.hashCode;
}
