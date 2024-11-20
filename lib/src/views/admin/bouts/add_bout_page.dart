import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/bout_functions.dart';
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
  late TextEditingController fencer1Controller;
  late TextEditingController fencer2Controller;

  @override
  void dispose() {
    fencer1Controller.dispose();
    fencer2Controller.dispose();
    super.dispose();
  }

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
    fencer1Controller = TextEditingController(text: fencer?.fullName);
    fencer2Controller = TextEditingController(text: opponent?.fullName);
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
                  Flexible(
                    child: TypeAheadField(
                      controller: fencer1Controller,
                      builder: (context, controller, node) => TextField(
                        controller: controller,
                        focusNode: node,
                        decoration: InputDecoration(
                          label: const Text("Fencer 1"),
                          suffixIcon: fencer != null
                              ? IconButton(
                                  onPressed: () => setState(() {
                                    fencer = null;
                                    fencer1Controller.clear();
                                  }),
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return fencers
                            .where((fencer) => fencer.fullName
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, fencer) => ListTile(
                        title: Text(fencer.fullName),
                        subtitle:
                            Text("${fencer.team.type} | ${fencer.weapon.type}"),
                      ),
                      onSelected: (suggestion) {
                        setState(() {
                          fencer = suggestion;
                          fencer1Controller.text = fencer!.fullName;
                          weapon ??= fencer!.weapon;
                        });
                      },
                    ),
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
                  Flexible(
                    child: TypeAheadField(
                      controller: fencer2Controller,
                      builder: (context, controller, node) => TextField(
                        controller: controller,
                        focusNode: node,
                        decoration: InputDecoration(
                          label: const Text("Fencer 2"),
                          suffixIcon: opponent != null
                              ? IconButton(
                                  onPressed: () => setState(() {
                                    opponent = null;
                                    fencer2Controller.clear();
                                  }),
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return fencers
                            .where((fencer) => fencer.fullName
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, fencer) => ListTile(
                        title: Text(fencer.fullName),
                        subtitle:
                            Text("${fencer.team.type} | ${fencer.weapon.type}"),
                      ),
                      onSelected: (suggestion) {
                        setState(() {
                          opponent = suggestion;
                          fencer2Controller.text = opponent!.fullName;
                          weapon ??= opponent!.weapon;
                        });
                      },
                    ),
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
                  if (weapon == Weapon.values[index]) {
                    weapon = null;
                  } else {
                    weapon = Weapon.values[index];
                  }
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
                      selectedDate = selectedDate!.addTime();
                      List<BoutMonth> months =
                          ref.read(thisSeasonBoutsProvider).value!;
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
                      // upload bout pair to database
                      await addBoutPair(months, [bout1, bout2]).then((value) {
                        if (context.mounted) {
                          context.maybePop();
                        }
                      });
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
