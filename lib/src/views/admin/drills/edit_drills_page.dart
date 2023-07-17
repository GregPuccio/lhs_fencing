import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/drill.dart';
import 'package:lhs_fencing/src/models/drill_season.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

@RoutePage()
class EditDrillsPage extends ConsumerStatefulWidget {
  final Drill drill;
  const EditDrillsPage({required this.drill, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditDrillsPageState();
}

class _EditDrillsPageState extends ConsumerState<EditDrillsPage> {
  late Drill drill;

  @override
  void initState() {
    drill = widget.drill;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Drill"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                ),
                initialValue: drill.description,
                onChanged: (value) => drill.description = value,
                maxLines: 3,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("Type"),
              trailing: DropdownButton<TypeDrill>(
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
            const Divider(),
            OutlinedButton.icon(
              onPressed: () async {
                List<DrillSeason> seasons =
                    ref.read(drillsProvider).asData!.value;
                String currentSeason =
                    "drills${DateTime.now().year.toString().substring(2)}";

                int index = seasons.indexWhere(
                    (m) => m.drills.where((d) => d.id == drill.id).isNotEmpty);
                if (index == -1) {
                  seasons.add(DrillSeason(id: currentSeason, drills: [drill]));
                } else {
                  int pIndex =
                      seasons[index].drills.indexWhere((p) => p.id == drill.id);
                  if (pIndex == -1) {
                    seasons[index].drills.add(drill);
                  } else {
                    seasons[index].drills.replaceRange(
                      pIndex,
                      pIndex + 1,
                      [drill],
                    );
                  }
                }
                await FirestoreService.instance.updateData(
                  path: FirestorePath.drill(seasons[index].id),
                  data: seasons[index].toMap(),
                );
                if (mounted) {
                  context.popRoute();
                }
              },
              icon: const Text("Save Changes"),
              label: const Icon(Icons.save),
            )
          ],
        ),
      ),
    );
  }
}
