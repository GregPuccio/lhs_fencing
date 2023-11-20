import 'dart:convert';

import 'package:lhs_fencing/src/constants/enums.dart';

class Equipment {
  EquipmentWeapon? mask;
  bool jacket;
  bool knickers;
  bool plastron;
  EquipmentWeapon? lame;
  EquipmentWeapon? bodyCord;
  int bodyCordCount;
  int maskCordCount;
  EquipmentWeapon? weapon;
  int weaponCount;
  Equipment({
    this.jacket = false,
    this.knickers = false,
    this.plastron = false,
    this.bodyCordCount = 0,
    this.maskCordCount = 0,
    this.weaponCount = 0,
  });

  static Equipment create() {
    return Equipment();
  }

  void giveEquipment(EquipmentWeapon equipmentWeapon) {
    mask = lame = bodyCord = weapon = equipmentWeapon;
    jacket = knickers = plastron = true;
    bodyCordCount = maskCordCount = weaponCount = 1;
  }

  Equipment copyWith({
    bool? jacket,
    bool? knickers,
    bool? plastron,
    int? bodyCordCount,
    int? maskCordCount,
    int? weaponCount,
  }) {
    return Equipment(
      jacket: jacket ?? this.jacket,
      knickers: knickers ?? this.knickers,
      plastron: plastron ?? this.plastron,
      bodyCordCount: bodyCordCount ?? this.bodyCordCount,
      maskCordCount: maskCordCount ?? this.maskCordCount,
      weaponCount: weaponCount ?? this.weaponCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jacket': jacket,
      'knickers': knickers,
      'plastron': plastron,
      'bodyCordCount': bodyCordCount,
      'maskCordCount': maskCordCount,
      'weaponCount': weaponCount,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      jacket: map['jacket'] ?? false,
      knickers: map['knickers'] ?? false,
      plastron: map['plastron'] ?? false,
      bodyCordCount: map['bodyCordCount']?.toInt() ?? 0,
      maskCordCount: map['maskCordCount']?.toInt() ?? 0,
      weaponCount: map['weaponCount']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Equipment.fromJson(String source) =>
      Equipment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Equipment(jacket: $jacket, knickers: $knickers, plastron: $plastron, bodyCordCount: $bodyCordCount, maskCordCount: $maskCordCount, weaponCount: $weaponCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Equipment &&
        other.jacket == jacket &&
        other.knickers == knickers &&
        other.plastron == plastron &&
        other.bodyCordCount == bodyCordCount &&
        other.maskCordCount == maskCordCount &&
        other.weaponCount == weaponCount;
  }

  @override
  int get hashCode {
    return jacket.hashCode ^
        knickers.hashCode ^
        plastron.hashCode ^
        bodyCordCount.hashCode ^
        maskCordCount.hashCode ^
        weaponCount.hashCode;
  }
}
