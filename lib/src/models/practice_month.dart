import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';

class PracticeMonth {
  String id;
  List<Practice> practices;
  DateTime month;

  PracticeMonth({
    required this.id,
    required this.practices,
    required this.month,
  });

  PracticeMonth copyWith({
    String? id,
    List<Practice>? practices,
    DateTime? month,
  }) {
    return PracticeMonth(
      id: id ?? this.id,
      practices: practices ?? this.practices,
      month: month ?? this.month,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practices': practices.map((x) => x.toMap()).toList(),
      'month': month.millisecondsSinceEpoch,
    };
  }

  factory PracticeMonth.fromMap(Map<String, dynamic> map) {
    print(FirestorePath.thisSeasonPractices());
    return PracticeMonth(
      id: map['id'] ?? '',
      practices: map['practices'] != null
          ? List<Practice>.from(
              map['practices'].map((x) => Practice.fromMap(x)))
          : [],
      month: DateTime.fromMillisecondsSinceEpoch(map['month'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory PracticeMonth.fromJson(String source) =>
      PracticeMonth.fromMap(json.decode(source));

  @override
  String toString() =>
      'PracticeMonth(id: $id, practices: $practices, month: $month)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PracticeMonth &&
        other.id == id &&
        listEquals(other.practices, practices) &&
        other.month == month;
  }

  @override
  int get hashCode => id.hashCode ^ practices.hashCode ^ month.hashCode;
}
