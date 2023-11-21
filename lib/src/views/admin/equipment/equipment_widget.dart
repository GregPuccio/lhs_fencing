import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/equipment.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

class EquipmentWidget extends StatefulWidget {
  final UserData fencer;
  const EquipmentWidget(this.fencer, {super.key});

  @override
  State<EquipmentWidget> createState() => _EquipmentWidgetState();
}

class _EquipmentWidgetState extends State<EquipmentWidget> {
  late Equipment equipment;
  late TextEditingController bodyCordCountController;
  late TextEditingController maskCordCountController;
  late TextEditingController weaponCountController;
  late Weapon defaultWeaponEquipment;

  @override
  void initState() {
    equipment = widget.fencer.equipment;
    bodyCordCountController =
        TextEditingController(text: equipment.bodyCordCount.toString());
    bodyCordCountController.addListener(() {});
    maskCordCountController =
        TextEditingController(text: equipment.maskCordCount.toString());
    maskCordCountController.addListener(() {});
    weaponCountController =
        TextEditingController(text: equipment.weaponCount.toString());
    weaponCountController.addListener(() {});
    defaultWeaponEquipment = widget.fencer.weapon;
    super.initState();
  }

  void updateUserData() async {
    await FirestoreService.instance.updateData(
      path: FirestorePath.user(widget.fencer.id),
      data: widget.fencer.toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: CheckboxListTile.adaptive(
                      value: equipment.mask,
                      title: const Text("Mask"),
                      onChanged: (value) {
                        setState(() {
                          equipment.mask = value ?? false;
                        });
                        updateUserData();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: CheckboxListTile.adaptive(
                      enabled: widget.fencer.weapon != Weapon.epee,
                      value: equipment.lame,
                      title: const Text("Lamé"),
                      onChanged: (value) {
                        setState(() {
                          equipment.lame = value ?? false;
                        });
                        updateUserData();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: CheckboxListTile.adaptive(
                value: equipment.jacket,
                title: const Text("Jacket"),
                onChanged: (value) {
                  setState(() {
                    equipment.jacket = value ?? false;
                  });
                  updateUserData();
                },
              ),
            ),
            Flexible(
              child: CheckboxListTile.adaptive(
                value: equipment.knickers,
                title: const Text("Knickers"),
                onChanged: (value) {
                  setState(() {
                    equipment.knickers = value ?? false;
                  });
                  updateUserData();
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: CheckboxListTile.adaptive(
                value: equipment.plastron,
                title: const Text("Plastron"),
                onChanged: (value) {
                  setState(() {
                    equipment.plastron = value ?? false;
                  });
                  updateUserData();
                },
              ),
            ),
            Flexible(
              child: CheckboxListTile.adaptive(
                enabled: widget.fencer.team != Team.boys,
                value: equipment.chestProtector,
                title: const Text("Chest Protector"),
                onChanged: (value) {
                  setState(() {
                    equipment.chestProtector = value ?? false;
                  });
                  updateUserData();
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Flexible(
                    flex: 2,
                    child: ListTile(
                      title: Text("Body Cords"),
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      keyboardType: const TextInputType.numberWithOptions(),
                      controller: bodyCordCountController,
                      onChanged: (value) {
                        equipment.bodyCordCount = int.tryParse(value) ?? 0;
                        updateUserData();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 2,
                    child: ListTile(
                      title: const Text("Mask Cords"),
                      enabled: widget.fencer.weapon != Weapon.epee,
                    ),
                  ),
                  Flexible(
                    child: TextField(
                        enabled: widget.fencer.weapon != Weapon.epee,
                        keyboardType: const TextInputType.numberWithOptions(),
                        controller: maskCordCountController,
                        onChanged: (value) {
                          equipment.maskCordCount = int.tryParse(value) ?? 0;
                          updateUserData();
                        }),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            Flexible(
              child: CheckboxListTile.adaptive(
                value: equipment.glove,
                title: const Text("Glove"),
                onChanged: (value) {
                  setState(() {
                    equipment.glove = value ?? false;
                  });
                  updateUserData();
                },
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 2,
                    child: ListTile(
                      title: Text(
                          "${widget.fencer.weapon == Weapon.unsure ? "Foil" : widget.fencer.weapon.type}s"),
                    ),
                  ),
                  Flexible(
                    child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(),
                        controller: weaponCountController,
                        onChanged: (value) {
                          equipment.weaponCount = int.tryParse(value) ?? 0;
                          updateUserData();
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
