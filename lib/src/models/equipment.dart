import 'dart:convert';

import 'package:lhs_fencing/src/constants/enums.dart';

class Equipment {
  bool mask;
  bool jacket;
  bool knickers;
  bool plastron;
  bool chestProtector;
  bool lame;
  int bodyCordCount;
  int maskCordCount;
  int weaponCount;
  Equipment({
    this.mask = false,
    this.jacket = false,
    this.knickers = false,
    this.plastron = false,
    this.chestProtector = false,
    this.lame = false,
    this.bodyCordCount = 0,
    this.maskCordCount = 0,
    this.weaponCount = 0,
  });

  static Equipment create() {
    return Equipment();
  }

  void giveEquipment(Weapon equipmentWeapon) {
    mask = jacket = knickers = plastron = chestProtector = lame = true;
    bodyCordCount = maskCordCount = weaponCount = 1;
  }

  Equipment copyWith({
    bool? mask,
    bool? jacket,
    bool? knickers,
    bool? plastron,
    bool? chestProtector,
    bool? lame,
    int? bodyCordCount,
    int? maskCordCount,
    int? weaponCount,
  }) {
    return Equipment(
      mask: mask ?? this.mask,
      jacket: jacket ?? this.jacket,
      knickers: knickers ?? this.knickers,
      plastron: plastron ?? this.plastron,
      chestProtector: chestProtector ?? this.chestProtector,
      lame: lame ?? this.lame,
      bodyCordCount: bodyCordCount ?? this.bodyCordCount,
      maskCordCount: maskCordCount ?? this.maskCordCount,
      weaponCount: weaponCount ?? this.weaponCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mask': mask,
      'jacket': jacket,
      'knickers': knickers,
      'plastron': plastron,
      'chestProtector': chestProtector,
      'lame': lame,
      'bodyCordCount': bodyCordCount,
      'maskCordCount': maskCordCount,
      'weaponCount': weaponCount,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      mask: map['mask'] ?? false,
      jacket: map['jacket'] ?? false,
      knickers: map['knickers'] ?? false,
      plastron: map['plastron'] ?? false,
      chestProtector: map['chestProtector'] ?? false,
      lame: map['lame'] ?? false,
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
    return 'Equipment(mask: $mask, jacket: $jacket, knickers: $knickers, plastron: $plastron, chestProtector: $chestProtector, lame: $lame, bodyCordCount: $bodyCordCount, maskCordCount: $maskCordCount, weaponCount: $weaponCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Equipment &&
        other.mask == mask &&
        other.jacket == jacket &&
        other.knickers == knickers &&
        other.plastron == plastron &&
        other.chestProtector == chestProtector &&
        other.lame == lame &&
        other.bodyCordCount == bodyCordCount &&
        other.maskCordCount == maskCordCount &&
        other.weaponCount == weaponCount;
  }

  @override
  int get hashCode {
    return mask.hashCode ^
        jacket.hashCode ^
        knickers.hashCode ^
        plastron.hashCode ^
        chestProtector.hashCode ^
        lame.hashCode ^
        bodyCordCount.hashCode ^
        maskCordCount.hashCode ^
        weaponCount.hashCode;
  }
}
