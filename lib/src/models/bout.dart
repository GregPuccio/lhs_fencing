import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:lhs_fencing/src/models/user_data.dart';

class Bout implements Comparable<Bout> {
  String id;
  String partnerID;
  UserData fencer;
  UserData opponent;
  int fencerScore;
  int opponentScore;
  bool fencerWin;
  bool opponentWin;
  DateTime date;
  bool original;
  bool poolBout;

  Bout({
    required this.id,
    required this.partnerID,
    required this.fencer,
    required this.opponent,
    required this.fencerScore,
    required this.opponentScore,
    required this.fencerWin,
    required this.opponentWin,
    required this.date,
    required this.original,
    required this.poolBout,
  });

  static Bout create({
    required UserData fencer,
    required UserData opponent,
    int fencerScore = 0,
    int opponentScore = 0,
    bool fencerWin = false,
    bool opponentWin = false,
    DateTime? date,
    bool original = false,
    bool poolBout = false,
  }) {
    return Bout(
      id: const Uuid().v4(),
      partnerID: "",
      fencer: fencer,
      opponent: opponent,
      fencerScore: fencerScore,
      opponentScore: opponentScore,
      fencerWin: fencerWin,
      opponentWin: opponentWin,
      date: date ?? DateTime.now(),
      original: original,
      poolBout: poolBout,
    );
  }

  Bout copyWith({
    String? id,
    String? partnerID,
    UserData? fencer,
    UserData? opponent,
    int? fencerScore,
    int? opponentScore,
    bool? fencerWin,
    bool? opponentWin,
    DateTime? date,
    bool? original,
    bool? poolBout,
  }) {
    return Bout(
      id: id ?? this.id,
      partnerID: partnerID ?? this.partnerID,
      fencer: fencer ?? this.fencer,
      opponent: opponent ?? this.opponent,
      fencerScore: fencerScore ?? this.fencerScore,
      opponentScore: opponentScore ?? this.opponentScore,
      fencerWin: fencerWin ?? this.fencerWin,
      opponentWin: opponentWin ?? this.opponentWin,
      date: date ?? this.date,
      original: original ?? this.original,
      poolBout: poolBout ?? this.poolBout,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partnerID': partnerID,
      'fencer': fencer.toMap(),
      'opponent': opponent.toMap(),
      'fencerScore': fencerScore,
      'opponentScore': opponentScore,
      'fencerWin': fencerWin,
      'opponentWin': opponentWin,
      'date': date.millisecondsSinceEpoch,
      'original': original,
      'poolBout': poolBout,
    };
  }

  factory Bout.fromMap(Map<String, dynamic> map) {
    return Bout(
      id: map['id'] ?? '',
      partnerID: map['partnerID'] ?? '',
      fencer: UserData.fromMap(map['fencer']),
      opponent: UserData.fromMap(map['opponent']),
      fencerScore: map['fencerScore']?.toInt() ?? 0,
      opponentScore: map['opponentScore']?.toInt() ?? 0,
      fencerWin: map['fencerWin'] ?? false,
      opponentWin: map['opponentWin'] ?? false,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      original: map['original'] ?? false,
      poolBout: map['poolBout'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Bout.fromJson(String source) => Bout.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Bout(id: $id, partnerID: $partnerID, fencer: $fencer, opponent: $opponent, fencerScore: $fencerScore, opponentScore: $opponentScore, fencerWin: $fencerWin, opponentWin: $opponentWin, date: $date, original: $original, poolBout: $poolBout)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bout &&
        other.id == id &&
        other.partnerID == partnerID &&
        other.fencer == fencer &&
        other.opponent == opponent &&
        other.fencerScore == fencerScore &&
        other.opponentScore == opponentScore &&
        other.fencerWin == fencerWin &&
        other.opponentWin == opponentWin &&
        other.date == date &&
        other.original == original &&
        other.poolBout == poolBout;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        partnerID.hashCode ^
        fencer.hashCode ^
        opponent.hashCode ^
        fencerScore.hashCode ^
        opponentScore.hashCode ^
        fencerWin.hashCode ^
        opponentWin.hashCode ^
        date.hashCode ^
        original.hashCode ^
        poolBout.hashCode;
  }

  @override
  int compareTo(Bout other) {
    int dateCompare = other.date.compareTo(date);
    if (dateCompare == 0) {
      return fencer.fullName.compareTo(other.fencer.fullName);
    } else {
      return dateCompare;
    }
  }
}

List<List<Bout>> createPoolBouts(List<UserData> fencers) {
  List<List<Bout>> boutList = [];
  for (var i = 0; i < fencers.length; i++) {
    for (var j = i + 1; j < fencers.length; j++) {
      Bout fencerBout = Bout.create(
        fencer: fencers[i],
        opponent: fencers[j],
        original: true,
        poolBout: true,
      );
      Bout opponentBout = Bout.create(
        fencer: fencers[j],
        opponent: fencers[i],
        poolBout: true,
      );
      fencerBout.partnerID = opponentBout.id;
      opponentBout.partnerID = fencerBout.id;
      boutList.add([fencerBout, opponentBout]);
    }
  }

  return boutList;
}
