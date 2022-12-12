import 'dart:convert';

import 'package:intl/intl.dart';

class Practice {
  String id;
  String location;
  DateTime startTime;
  DateTime endTime;
  Practice({
    required this.id,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  String get startString {
    return DateFormat("EEEE, MMM d @ h:mm aa").format(startTime);
  }

  String get emailString {
    return DateFormat("MM/dd").format(startTime);
  }

  Practice copyWith({
    String? id,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Practice(
      id: id ?? this.id,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
    };
  }

  factory Practice.fromMap(Map<String, dynamic> map) {
    return Practice(
      id: map['id'] ?? '',
      location: map['location'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Practice.fromJson(String source) =>
      Practice.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Practice(id: $id, location: $location, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Practice &&
        other.id == id &&
        other.location == location &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        location.hashCode ^
        startTime.hashCode ^
        endTime.hashCode;
  }
}
