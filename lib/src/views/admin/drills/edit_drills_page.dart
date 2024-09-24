import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    drill = Drill.fromJson(widget.drill.toJson());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future saveChanges() async {
      List<DrillSeason> seasons = ref.read(drillsProvider).value!;

      int index =
          seasons.indexWhere((m) => m.drills.any((d) => d.id == drill.id));
      int pIndex = seasons[index].drills.indexWhere((p) => p.id == drill.id);

      seasons[index].drills.replaceRange(
        pIndex,
        pIndex + 1,
        [drill],
      );

      await FirestoreService.instance
          .updateData(
            path: FirestorePath.drill(seasons[index].id),
            data: seasons[index].toMap(),
          )
          .then((value) => drill = widget.drill);
      if (context.mounted) {
        context.maybePop(true);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (drill != widget.drill) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Save Changes"),
              content:
                  const Text("Would you like to save or discard your changes?"),
              actions: [
                TextButton(
                  onPressed: saveChanges,
                  child: const Text("Save"),
                ),
                TextButton(
                  onPressed: () => context.maybePop(true),
                  child: const Text("Discard"),
                ),
              ],
            ),
          );
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Drill"),
          actions: [
            IconButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Delete Drill"),
                          content: const Text(
                              "Are you sure you want to delete this drill from the app?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                List<DrillSeason> seasons =
                                    ref.read(drillsProvider).value!;

                                int index = seasons.indexWhere((m) =>
                                    m.drills.any((d) => d.id == drill.id));
                                await FirestoreService.instance.updateData(
                                  path: FirestorePath.drill(seasons[index].id),
                                  data: {
                                    "drills": FieldValue.arrayRemove(
                                        [widget.drill.toMap()])
                                  },
                                );
                                if (context.mounted) {
                                  context.maybePop(true);
                                }
                              },
                              child: const Text("Delete"),
                            ),
                            TextButton(
                              onPressed: () => context.maybePop(),
                              child: const Text("Cancel"),
                            ),
                          ],
                        )).then((value) {
                  if (value == true && context.mounted) {
                    context.maybePop(true);
                  }
                });
              },
              icon: const Icon(Icons.delete),
            ),
          ],
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
                onPressed: saveChanges,
                icon: const Text("Save Changes"),
                label: const Icon(Icons.save),
              )
            ],
          ),
        ),
      ),
    );
  }
}
