import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:lhs_fencing/src/models/drill.dart';

class DrillSeason {
  String id;
  List<Drill> drills;
  DrillSeason({
    required this.id,
    required this.drills,
  });

  DrillSeason copyWith({
    String? id,
    List<Drill>? drills,
  }) {
    return DrillSeason(
      id: id ?? this.id,
      drills: drills ?? this.drills,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drills': drills.map((x) => x.toMap()).toList(),
    };
  }

  factory DrillSeason.fromMap(Map<String, dynamic> map) {
    return DrillSeason(
      id: map['id'] ?? '',
      drills: List<Drill>.from(
        map['drills']?.map((x) => Drill.fromMap(x)) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DrillSeason.fromJson(String source) =>
      DrillSeason.fromMap(json.decode(source));

  @override
  String toString() => 'DrillSeason(id: $id, drills: $drills)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrillSeason &&
        other.id == id &&
        listEquals(other.drills, drills);
  }

  @override
  int get hashCode => id.hashCode ^ drills.hashCode;
}
