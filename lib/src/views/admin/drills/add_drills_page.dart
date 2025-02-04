import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/drill.dart';
import 'package:lhs_fencing/src/models/drill_season.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class AddDrillsPage extends ConsumerStatefulWidget {
  const AddDrillsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDrillsPageState();
}

class _AddDrillsPageState extends ConsumerState<AddDrillsPage> {
  late Drill drill;

  @override
  void initState() {
    drill = Drill.create();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Drill"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: DropdownButton<TypeDrill>(
                        value: drill.type,
                        items: List.generate(
                          TypeDrill.values.length,
                          (index) => DropdownMenuItem(
                            value: TypeDrill.values[index],
                            child: Text(TypeDrill.values[index].type),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            drill.type = value;
                          });
                        }),
                  ),
                ),
                Flexible(
                  child: ListTile(
                    leading: const Icon(Symbols.swords),
                    title: DropdownButton<Weapon>(
                        value: drill.weapon,
                        items: List.generate(
                          Weapon.values.length - 1,
                          (index) => DropdownMenuItem(
                            value: Weapon.values[index],
                            child: Text(Weapon.values[index].drillType),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            drill.weapon = value;
                          });
                        }),
                  ),
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                initialValue: drill.name,
                onChanged: (value) => drill.name = value,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  label: Text("Description"),
                  alignLabelWithHint: true,
                ),
                initialValue: drill.description,
                onChanged: (value) => drill.description = value,
                maxLines: 3,
              ),
            ),
            const Divider(),
            OutlinedButton.icon(
              onPressed: () async {
                List<DrillSeason> seasons = ref.read(drillsProvider).value!;
                String currentSeason = drillSeason23;
                int index = seasons.indexWhere((m) => m.id == currentSeason);
                if (index == -1) {
                  seasons.add(DrillSeason(id: currentSeason, drills: [drill]));
                  index = seasons.indexWhere((m) => m.id == currentSeason);
                  await FirestoreService.instance
                      .addData(
                        path: FirestorePath.drill(seasons[index].id),
                        data: seasons[index].toMap(),
                      )
                      .then(
                          (value) => context.mounted ? context.maybePop() : 0);
                } else {
                  seasons[index].drills.add(drill);
                  await FirestoreService.instance
                      .updateData(
                        path: FirestorePath.drill(seasons[index].id),
                        data: seasons[index].toMap(),
                      )
                      .then(
                          (value) => context.mounted ? context.maybePop() : 0);
                }
              },
              icon: const Text("Add Drill"),
              label: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
