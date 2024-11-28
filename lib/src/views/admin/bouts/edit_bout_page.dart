import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/firestore/functions/bout_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

@RoutePage()
class EditBoutPage extends ConsumerStatefulWidget {
  final Bout bout;
  const EditBoutPage({required this.bout, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditBoutPageState();
}

class _EditBoutPageState extends ConsumerState<EditBoutPage> {
  late Bout bout;

  @override
  void initState() {
    bout = Bout.fromJson(widget.bout.toJson());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future saveChanges() async {
      List<BoutMonth> seasons = ref.read(thisSeasonBoutsProvider).value!;
      Bout partnerBout = Bout(
        id: bout.partnerID,
        partnerID: bout.id,
        fencer: bout.opponent,
        opponent: bout.fencer,
        fencerScore: bout.opponentScore,
        opponentScore: bout.fencerScore,
        fencerWin: bout.opponentWin,
        opponentWin: bout.fencerWin,
        date: bout.date,
        original: !bout.original,
        poolBout: bout.poolBout,
      );
      if (bout.fencerScore > bout.opponentScore) {
        bout.fencerWin = partnerBout.opponentWin = true;
        bout.opponentWin = partnerBout.fencerWin = false;
      } else if (bout.fencerScore < bout.opponentScore) {
        bout.opponentWin = partnerBout.fencerWin = true;
        bout.fencerWin = partnerBout.opponentWin = false;
      } else {
        partnerBout.fencerWin = bout.opponentWin;
        partnerBout.opponentWin = bout.fencerWin;
      }

      int index =
          seasons.indexWhere((m) => m.bouts.any((d) => d.id == bout.id));
      int pIndex = seasons[index].bouts.indexWhere((p) => p.id == bout.id);

      seasons[index].bouts.replaceRange(
        pIndex,
        pIndex + 1,
        [bout],
      );

      await FirestoreService.instance.updateData(
        path: FirestorePath.currentSeasonBoutMonth(
            bout.fencer.id, seasons[index].id),
        data: seasons[index].toMap(),
      );

      index =
          seasons.indexWhere((m) => m.bouts.any((d) => d.id == partnerBout.id));
      pIndex = seasons[index].bouts.indexWhere((p) => p.id == partnerBout.id);

      seasons[index].bouts.replaceRange(
        pIndex,
        pIndex + 1,
        [partnerBout],
      );

      await FirestoreService.instance
          .updateData(
            path: FirestorePath.currentSeasonBoutMonth(
                partnerBout.fencer.id, seasons[index].id),
            data: seasons[index].toMap(),
          )
          .then((value) => bout = widget.bout);
      if (context.mounted) {
        context.maybePop(true);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (bout != widget.bout) {
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
          title: const Text("Edit Bout"),
          actions: [
            IconButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text("Delete Bout"),
                          content: const Text(
                              "Are you sure you want to delete this bout from the app?"),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                List<BoutMonth> boutMonths =
                                    ref.read(thisSeasonBoutsProvider).value!;

                                await deleteBoutPair(boutMonths, bout);

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
        body: ListView(
          children: [
            const SizedBox(height: 8),
            ListTile(
              title: Text("Fencer 1: ${bout.fencer.fullName}"),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: "${bout.fencerScore}",
                  decoration: const InputDecoration(label: Text("Score")),
                  onChanged: (value) => setState(() {
                    bout.fencerScore = int.tryParse(value) ?? 0;
                  }),
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text("Fencer 2: ${bout.opponent.fullName}"),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: "${bout.opponentScore}",
                  decoration: const InputDecoration(label: Text("Score")),
                  onChanged: (value) => setState(() {
                    bout.opponentScore = int.tryParse(value) ?? 0;
                  }),
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
              ),
            ),
            ListTile(
              title: const Text("Weapon"),
              subtitle: const Text("This will default to the fencer's weapon."),
              trailing: ToggleButtons(
                isSelected: List.generate(Weapon.values.length - 1,
                    (index) => Weapon.values[index] == bout.fencer.weapon),
                children: List.generate(
                  Weapon.values.length - 1,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Weapon.values[index].type),
                  ),
                ),
                onPressed: (index) {
                  setState(() {
                    bout.fencer.weapon = Weapon.values[index];
                    bout.opponent.weapon = Weapon.values[index];
                  });
                },
              ),
            ),
            if (bout.fencerScore == bout.opponentScore) ...[
              const SizedBox(height: 8),
              ListTile(
                title: const Text("Select Winner"),
                subtitle: const Text("Fencing doesn't end in a tie!"),
                trailing: ToggleButtons(
                  isSelected: [
                    bout.fencerWin,
                    bout.opponentWin,
                  ],
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bout.fencer.firstName),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(bout.opponent.firstName),
                    ),
                  ],
                  onPressed: (value) {
                    setState(() {
                      if (value == 0) {
                        bout.fencerWin = !bout.fencerWin;
                        if (bout.fencerWin) {
                          bout.opponentWin = false;
                        }
                      } else if (value == 1) {
                        bout.opponentWin = !bout.opponentWin;
                        if (bout.opponentWin) {
                          bout.fencerWin = false;
                        }
                      }
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                  "Date: ${DateFormat("EEEE, MMMM dd, yyyy").format(bout.date)}"),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => showDatePicker(
                context: context,
                currentDate: bout.date,
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime(DateTime.now().year + 2),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    bout.date = value;
                  });
                }
              }),
            ),
            const Divider(),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: saveChanges,
              icon: const Text("Save Changes"),
              label: const Icon(Icons.save),
            )
          ],
        ),
      ),
    );
  }
}
