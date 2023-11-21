import 'dart:convert';

import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class Equipment {
  bool mask;
  bool jacket;
  bool knickers;
  bool plastron;
  bool chestProtector;
  bool lame;
  bool glove;
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
    this.glove = false,
    this.bodyCordCount = 0,
    this.maskCordCount = 0,
    this.weaponCount = 0,
  });

  static Equipment create() {
    return Equipment();
  }

  bool hasEquipment(UserData fencer) {
    bool hasBase = mask &&
        jacket &&
        knickers &&
        plastron &&
        glove &&
        bodyCordCount > 0 &&
        weaponCount > 0;
    int counter = 0;
    if (hasBase) {
      counter++;
      if (fencer.team == Team.girls) {
        if (chestProtector) {
          counter++;
        }
      } else {
        counter++;
      }
      if (fencer.weapon != Weapon.epee) {
        if (lame && maskCordCount > 0) {
          counter++;
        }
      } else {
        counter++;
      }
      if (counter == 3) {
        return true;
      }
    }
    return false;
  }

  void giveEquipment(UserData fencer) {
    mask = jacket = knickers = plastron = glove = true;
    bodyCordCount = weaponCount = 1;
    if (fencer.team == Team.girls) {
      chestProtector = true;
    }
    if (fencer.weapon != Weapon.epee) {
      lame = true;
      maskCordCount = 1;
    }
  }

  void removeEquipment() {
    mask = jacket = knickers = plastron = chestProtector = lame = glove = false;
    bodyCordCount = maskCordCount = weaponCount = 0;
  }

  Equipment copyWith({
    bool? mask,
    bool? jacket,
    bool? knickers,
    bool? plastron,
    bool? chestProtector,
    bool? lame,
    bool? glove,
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
      glove: glove ?? this.glove,
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
      'glove': glove,
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
      glove: map['glove'] ?? false,
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
    return 'Equipment(mask: $mask, jacket: $jacket, knickers: $knickers, plastron: $plastron, chestProtector: $chestProtector, lame: $lame, glove: $glove, bodyCordCount: $bodyCordCount, maskCordCount: $maskCordCount, weaponCount: $weaponCount)';
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
        other.glove == glove &&
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
        glove.hashCode ^
        bodyCordCount.hashCode ^
        maskCordCount.hashCode ^
        weaponCount.hashCode;
  }
}
