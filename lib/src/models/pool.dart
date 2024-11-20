import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Pool {
  String id;
  Weapon weapon;
  Team team;
  DateTime date;
  List<String> boutIDs;
  List<UserData> fencers;

  static (Pool, List<List<Bout>>) create(
      Weapon weapon, Team team, List<UserData> fencers) {
    List<List<Bout>> bouts = createPoolBouts(fencers);
    return (
      Pool(
        id: const Uuid().v4(),
        weapon: weapon,
        team: team,
        date: DateTime(0).today,
        boutIDs: bouts.map((b) => b.first.id).toList(),
        fencers: fencers,
      ),
      bouts,
    );
  }

  Pool({
    required this.id,
    required this.weapon,
    required this.team,
    required this.date,
    required this.boutIDs,
    required this.fencers,
  });

  Pool copyWith({
    String? id,
    Weapon? weapon,
    Team? team,
    DateTime? date,
    List<String>? boutIDs,
    List<UserData>? fencers,
  }) {
    return Pool(
      id: id ?? this.id,
      weapon: weapon ?? this.weapon,
      team: team ?? this.team,
      date: date ?? this.date,
      boutIDs: boutIDs ?? this.boutIDs,
      fencers: fencers ?? this.fencers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weapon': weapon.toMap(),
      'team': team.toMap(),
      'date': date.millisecondsSinceEpoch,
      'boutIDs': boutIDs,
      'fencers': fencers.map((x) => x.toMap()).toList(),
    };
  }

  factory Pool.fromMap(Map<String, dynamic> map) {
    return Pool(
      id: map['id'] ?? '',
      weapon: Weapon.fromMap(map['weapon']),
      team: Team.fromMap(map['team']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      boutIDs: List<String>.from(map['boutIDs']),
      fencers:
          List<UserData>.from(map['fencers']?.map((x) => UserData.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pool.fromJson(String source) => Pool.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Pool(id: $id, weapon: $weapon, team: $team, date: $date, boutIDs: $boutIDs, fencers: $fencers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pool &&
        other.id == id &&
        other.weapon == weapon &&
        other.team == team &&
        other.date == date &&
        listEquals(other.boutIDs, boutIDs) &&
        listEquals(other.fencers, fencers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        weapon.hashCode ^
        team.hashCode ^
        date.hashCode ^
        boutIDs.hashCode ^
        fencers.hashCode;
  }
}
