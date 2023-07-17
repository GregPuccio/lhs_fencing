import 'dart:convert';

import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:uuid/uuid.dart';

class Drill {
  String id;
  String name;
  String description;
  TypeDrill type;
  DateTime? lastUsed;
  DateTime created;
  int timesUsed;
  Drill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.lastUsed,
    required this.created,
    required this.timesUsed,
  });

  static Drill create() {
    return Drill(
      id: const Uuid().v4(),
      name: "",
      description: "",
      type: TypeDrill.footwork,
      created: DateTime.now(),
      timesUsed: 0,
    );
  }

  Drill copyWith({
    String? id,
    String? name,
    String? description,
    TypeDrill? type,
    DateTime? lastUsed,
    DateTime? created,
    int? timesUsed,
  }) {
    return Drill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      lastUsed: lastUsed ?? this.lastUsed,
      created: created ?? this.created,
      timesUsed: timesUsed ?? this.timesUsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toMap(),
      'lastUsed': lastUsed?.millisecondsSinceEpoch,
      'created': created.millisecondsSinceEpoch,
      'timesUsed': timesUsed,
    };
  }

  factory Drill.fromMap(Map<String, dynamic> map) {
    return Drill(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: TypeDrill.fromMap(map['type']),
      lastUsed: map['lastUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUsed'])
          : null,
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      timesUsed: map['timesUsed']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Drill.fromJson(String source) => Drill.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Drill(id: $id, name: $name, description: $description, type: $type, lastUsed: $lastUsed, created: $created, timesUsed: $timesUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Drill &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        other.lastUsed == lastUsed &&
        other.created == created &&
        other.timesUsed == timesUsed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        lastUsed.hashCode ^
        created.hashCode ^
        timesUsed.hashCode;
  }
}
