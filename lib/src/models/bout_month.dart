import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:lhs_fencing/src/models/bout.dart';

class BoutMonth {
  /// [id] is [reference month].millisecondsSinceEpoch.toString();
  String id;
  String fencerID;
  List<Bout> bouts;
  BoutMonth({
    required this.id,
    required this.fencerID,
    required this.bouts,
  });

  BoutMonth copyWith({
    String? id,
    String? fencerID,
    List<Bout>? bouts,
  }) {
    return BoutMonth(
      id: id ?? this.id,
      fencerID: fencerID ?? this.fencerID,
      bouts: bouts ?? this.bouts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fencerID': fencerID,
      'bouts': bouts.map((x) => x.toMap()).toList(),
    };
  }

  factory BoutMonth.fromMap(Map<String, dynamic> map) {
    return BoutMonth(
      id: map['id'] ?? '',
      fencerID: map['fencerID'] ?? '',
      bouts: List<Bout>.from(map['bouts']?.map((x) => Bout.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory BoutMonth.fromJson(String source) =>
      BoutMonth.fromMap(json.decode(source));

  @override
  String toString() =>
      'BoutSeason(id: $id, fencerID: $fencerID, bouts: $bouts)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BoutMonth &&
        other.id == id &&
        other.fencerID == fencerID &&
        listEquals(other.bouts, bouts);
  }

  @override
  int get hashCode => id.hashCode ^ fencerID.hashCode ^ bouts.hashCode;
}
