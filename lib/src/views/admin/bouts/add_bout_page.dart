import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class AddBoutPage extends ConsumerStatefulWidget {
  final UserData? fencer;
  final UserData? opponent;
  final DateTime? selectedDate;
  const AddBoutPage({this.fencer, this.opponent, this.selectedDate, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddBoutPageState();
}

class _AddBoutPageState extends ConsumerState<AddBoutPage> {
  UserData? fencer;
  UserData? opponent;
  DateTime? selectedDate;
  Weapon? weapon;
  int? fencerScore;
  int? opponentScore;
  bool fencerWin = false;
  bool opponentWin = false;

  @override
  void initState() {
    fencer = widget.fencer;
    opponent = widget.opponent;
    if (widget.fencer != null) {
      weapon =
          fencer?.weapon == Weapon.unsure ? opponent?.weapon : fencer?.weapon;
    } else {
      weapon = opponent?.weapon;
    }
    selectedDate = widget.selectedDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenFencerData(List<UserData> fencers) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add Bout"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Row(
                children: [
                  DropdownButton<UserData>(
                    hint: const Text("Fencer 1"),
                    items: List.generate(
                      fencers.length,
                      (index) => DropdownMenuItem(
                        value: fencers[index],
                        child: Text(fencers[index].fullName),
                      ),
                    ),
                    value: fencer,
                    onChanged: (value) {
                      setState(() {
                        fencer = value;
                        weapon ??= fencer!.weapon != Weapon.unsure
                            ? fencer!.weapon
                            : weapon;
                      });
                    },
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: "${fencerScore ?? 0}",
                  decoration: const InputDecoration(label: Text("Score")),
                  onChanged: (value) => setState(() {
                    fencerScore = int.tryParse(value) ?? 0;
                  }),
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  DropdownButton<UserData>(
                    hint: const Text("Fencer 2"),
                    items: List.generate(
                      fencers.length,
                      (index) => DropdownMenuItem(
                        value: fencers[index],
                        child: Text(fencers[index].fullName),
                      ),
                    ),
                    value: opponent,
                    onChanged: (value) {
                      setState(() {
                        opponent = value;
                        weapon ??= opponent!.weapon;
                      });
                    },
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: "${opponentScore ?? 0}",
                  decoration: const InputDecoration(label: Text("Score")),
                  onChanged: (value) => setState(() {
                    opponentScore = int.tryParse(value) ?? 0;
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
                    (index) => Weapon.values[index] == weapon),
                children: List.generate(
                  Weapon.values.length - 1,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(Weapon.values[index].type),
                  ),
                ),
                onPressed: (index) {
                  setState(() {
                    weapon = Weapon.values[index];
                  });
                },
              ),
            ),
            if (fencerScore == opponentScore)
              ListTile(
                title: const Text("Select Winner"),
                subtitle: const Text("Fencing doesn't end in a tie!"),
                trailing: ToggleButtons(
                  isSelected: [
                    fencerWin,
                    opponentWin,
                  ],
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(fencer?.firstName ?? "Fencer 1"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(opponent?.firstName ?? "Fencer 2"),
                    ),
                  ],
                  onPressed: (value) {
                    setState(() {
                      if (value == 0) {
                        fencerWin = !fencerWin;
                        if (fencerWin) {
                          opponentWin = false;
                        }
                      } else if (value == 1) {
                        opponentWin = !opponentWin;
                        if (opponentWin) {
                          fencerWin = false;
                        }
                      }
                    });
                  },
                ),
              ),
            ListTile(
              title: Text(
                  "Date: ${selectedDate != null ? DateFormat("EEEE, MMMM dd, yyyy").format(selectedDate!) : "Not Selected"}"),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                currentDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 1),
                lastDate: DateTime(DateTime.now().year + 2),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    selectedDate = value;
                  });
                }
              }),
            ),
            const Divider(),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: fencer != null &&
                      opponent != null &&
                      selectedDate != null &&
                      (fencerScore != opponentScore || fencerWin || opponentWin)
                  ? () async {
                      List<BoutMonth> months = ref.read(boutsProvider).value!;
                      fencer = fencer?.copyWith(weapon: weapon);
                      opponent = opponent?.copyWith(weapon: weapon);
                      // create bout for [fencer]
                      Bout bout1 = Bout.create(
                        fencer: fencer!,
                        opponent: opponent!,
                        fencerScore: fencerScore ?? 0,
                        opponentScore: opponentScore ?? 0,
                        date: selectedDate,
                        original: true,
                      );
                      // create bout for [opponent]
                      Bout bout2 = Bout.create(
                        fencer: opponent!,
                        opponent: fencer!,
                        fencerScore: opponentScore ?? 0,
                        opponentScore: fencerScore ?? 0,
                        date: selectedDate,
                      );
                      if (bout1.fencerScore > bout1.opponentScore) {
                        bout1.fencerWin = true;
                        bout2.opponentWin = true;
                      } else if (bout1.fencerScore < bout1.opponentScore) {
                        bout1.opponentWin = true;
                        bout2.fencerWin = true;
                      } else {
                        bout1.fencerWin = bout2.opponentWin = fencerWin;
                        bout1.opponentWin = bout2.fencerWin = opponentWin;
                      }
                      // update bouts with [partnerID]
                      bout1.partnerID = bout2.id;
                      bout2.partnerID = bout1.id;
                      //upload [fencer] bout
                      int index = months.indexWhere((m) =>
                          m.fencerID == fencer!.id &&
                          m.id ==
                              bout1.date.monthOnly.millisecondsSinceEpoch
                                  .toString());
                      if (index == -1) {
                        months.add(BoutMonth(
                            id: bout1.date.monthOnly.millisecondsSinceEpoch
                                .toString(),
                            fencerID: fencer!.id,
                            bouts: [bout1]));
                        index = months.indexWhere((m) =>
                            m.fencerID == fencer!.id &&
                            m.id ==
                                bout1.date.monthOnly.millisecondsSinceEpoch
                                    .toString());
                        await FirestoreService.instance.setData(
                          path:
                              FirestorePath.bout(fencer!.id, months[index].id),
                          data: months[index].toMap(),
                        );
                      } else {
                        months[index].bouts.add(bout1);
                        await FirestoreService.instance.updateData(
                          path:
                              FirestorePath.bout(fencer!.id, months[index].id),
                          data: months[index].toMap(),
                        );
                      }
                      // upload [opponent] bout
                      index = months.indexWhere((m) =>
                          m.fencerID == opponent!.id &&
                          m.id ==
                              bout1.date.monthOnly.millisecondsSinceEpoch
                                  .toString());
                      if (index == -1) {
                        months.add(BoutMonth(
                            id: bout2.date.monthOnly.millisecondsSinceEpoch
                                .toString(),
                            fencerID: opponent!.id,
                            bouts: [bout2]));
                        index = months.indexWhere((m) =>
                            m.fencerID == opponent!.id &&
                            m.id ==
                                bout1.date.monthOnly.millisecondsSinceEpoch
                                    .toString());
                        await FirestoreService.instance
                            .setData(
                              path: FirestorePath.bout(
                                  opponent!.id, months[index].id),
                              data: months[index].toMap(),
                            )
                            .then((value) => context.popRoute());
                      } else {
                        months[index].bouts.add(bout2);
                        await FirestoreService.instance
                            .updateData(
                              path: FirestorePath.bout(
                                  opponent!.id, months[index].id),
                              data: months[index].toMap(),
                            )
                            .then((value) => context.popRoute());
                      }
                    }
                  : null,
              icon: const Text("Add Bout"),
              label: const Icon(Icons.add),
            )
          ],
        ),
      );
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
