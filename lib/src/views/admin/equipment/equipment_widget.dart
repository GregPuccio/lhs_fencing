import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/equipment.dart';
import 'package:lhs_fencing/src/models/user_data.dart';

class EquipmentWidget extends StatefulWidget {
  final UserData fencer;
  const EquipmentWidget(this.fencer, {super.key});

  @override
  State<EquipmentWidget> createState() => _EquipmentWidgetState();
}

class _EquipmentWidgetState extends State<EquipmentWidget> {
  Equipment equipment = Equipment();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              flex: 2,
              child: CheckboxListTile.adaptive(
                value: equipment.mask != null,
                title: const Text("Mask"),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    equipment.mask = EquipmentWeapon.foil;
                  } else {
                    equipment.mask = null;
                  }
                }),
              ),
            ),
            Flexible(
              child: DropdownButton(
                items: const [],
                onChanged: (value) {},
              ),
            )
          ],
        ),
      ],
    );
  }
}
