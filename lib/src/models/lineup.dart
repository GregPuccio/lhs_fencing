import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Lineup {
  /// identification to easily select this lineup
  String id;

  /// store all fencers in order of highest position to lowest position
  List<UserData> fencers;

  /// this should only store a maximum of 2 top fencers who are selected
  /// at the beginning of the season and should only adjusted inside of a
  /// lineup at creation of the lineup
  List<UserData> starters;

  /// use this value to always grab the most recently created lineup
  DateTime createdAt;

  /// this is stored as a reference to ensure only practices not yet included
  /// are taken into account
  List<String> practicesAdded;

  /// used to differentiate between different lineups
  Weapon weapon;

  /// used to differentiate between different lineups
  Team team;

  Lineup({
    required this.id,
    required this.fencers,
    required this.starters,
    required this.createdAt,
    required this.practicesAdded,
    required this.weapon,
    required this.team,
  });

  Lineup copyWith({
    String? id,
    List<UserData>? fencers,
    List<UserData>? starters,
    DateTime? createdAt,
    List<String>? practicesAdded,
    Weapon? weapon,
    Team? team,
  }) {
    return Lineup(
      id: id ?? this.id,
      fencers: fencers ?? this.fencers,
      starters: starters ?? this.starters,
      createdAt: createdAt ?? this.createdAt,
      practicesAdded: practicesAdded ?? this.practicesAdded,
      weapon: weapon ?? this.weapon,
      team: team ?? this.team,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fencers': fencers.map((x) => x.toMap()).toList(),
      'starters': starters.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'practicesAdded': practicesAdded,
      'weapon': weapon.toMap(),
      'team': team.toMap(),
    };
  }

  factory Lineup.fromMap(Map<String, dynamic> map) {
    return Lineup(
      id: map['id'] ?? '',
      fencers:
          List<UserData>.from(map['fencers']?.map((x) => UserData.fromMap(x))),
      starters:
          List<UserData>.from(map['starters']?.map((x) => UserData.fromMap(x))),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      practicesAdded: List<String>.from(map['practicesAdded']),
      weapon: Weapon.fromMap(map['weapon']),
      team: Team.fromMap(map['team']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Lineup.fromJson(String source) => Lineup.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Lineup(id: $id, fencers: $fencers, starters: $starters, createdAt: $createdAt, practicesAdded: $practicesAdded, weapon: $weapon, team: $team)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lineup &&
        other.id == id &&
        listEquals(other.fencers, fencers) &&
        listEquals(other.starters, starters) &&
        other.createdAt == createdAt &&
        listEquals(other.practicesAdded, practicesAdded) &&
        other.weapon == weapon &&
        other.team == team;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fencers.hashCode ^
        starters.hashCode ^
        createdAt.hashCode ^
        practicesAdded.hashCode ^
        weapon.hashCode ^
        team.hashCode;
  }
}
