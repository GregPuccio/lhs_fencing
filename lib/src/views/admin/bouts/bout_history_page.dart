import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class BoutHistoryPage extends ConsumerStatefulWidget {
  const BoutHistoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BoutHistoryPageState();
}

class _BoutHistoryPageState extends ConsumerState<BoutHistoryPage> {
  late List<UserData> fencers;
  UserData? fencer;
  UserData? opponent;
  DateTime? selectedDate;
  List<Bout> bouts = [];
  late TextEditingController fencer1Controller;
  late TextEditingController fencer2Controller;

  @override
  void initState() {
    fencer1Controller = TextEditingController();
    fencer2Controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    fencer1Controller.dispose();
    fencer2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<BoutMonth> seasons) {
      bouts.clear();
      if (fencer != null || opponent != null || selectedDate != null) {
        bouts.addAll(seasons.map((s) => s.bouts).expand((x) => x));
      }
      if (fencer != null) {
        bouts.retainWhere((bout) => bout.fencer.id == fencer!.id);
      }
      if (opponent != null) {
        bouts.retainWhere((bout) => bout.opponent.id == opponent!.id);
      }
      if (selectedDate != null) {
        bouts.retainWhere((bout) => bout.date.isSameDayAs(selectedDate));
        if (fencer == null && opponent == null) {
          bouts.retainWhere((bout) => bout.original);
        }
      }
      bouts = bouts.toSet().toList();
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bout History"),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: (bouts.isEmpty ? 1 : bouts.length) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              title: Text(fencer.fullShortenedName),
                              subtitle: Text(
                                  "${fencer.team.type} | ${fencer.weapon.type}"),
                            ),
                            onSelected: (suggestion) {
                              setState(() {
                                fencer = suggestion;
                                fencer1Controller.text = fencer!.fullName;
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("vs."),
                        ),
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
                              title: Text(fencer.fullShortenedName),
                              subtitle: Text(
                                  "${fencer.team.type} | ${fencer.weapon.type}"),
                            ),
                            onSelected: (suggestion) {
                              setState(() {
                                opponent = suggestion;
                                fencer2Controller.text = opponent!.fullName;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                        "Date: ${selectedDate != null ? DateFormat("EEEE, MMMM dd, yyyy").format(selectedDate!) : "Not Selected"}"),
                    trailing: selectedDate == null
                        ? const Icon(Icons.calendar_month)
                        : TextButton.icon(
                            onPressed: () => setState(() {
                              selectedDate = null;
                            }),
                            label: const Icon(Icons.clear),
                            icon: const Text("Clear Date"),
                          ),
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
                  if (bouts.isNotEmpty) ...[
                    const Divider(),
                    if (fencer != null && opponent != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(fencer!.fullName),
                              Text(
                                  "${bouts.where((bout) => bout.fencer.id == fencer!.id && bout.fencerWin).length}"),
                            ],
                          ),
                          Column(
                            children: [
                              Text(opponent!.fullName),
                              Text(
                                  "${bouts.where((bout) => bout.opponent.id == opponent!.id && bout.opponentWin).length}"),
                            ],
                          )
                        ],
                      ),
                    ] else if (fencer != null) ...[
                      Text("${fencer!.firstName}'s Overall Record"),
                      Text(
                          "${bouts.where((bout) => bout.fencer.id == fencer!.id && bout.fencerWin).length}"
                          "-"
                          "${bouts.where((bout) => bout.fencer.id == fencer!.id && bout.opponentWin).length}"),
                    ] else if (opponent != null) ...[
                      Text("${opponent!.firstName}'s Overall Record"),
                      Text(
                          "${bouts.where((bout) => bout.opponent.id == opponent!.id && bout.opponentWin).length}"
                          "-"
                          "${bouts.where((bout) => bout.opponent.id == opponent!.id && bout.fencerWin).length}"),
                    ] else ...[
                      Text("${bouts.length} Bouts Found"),
                    ],
                  ],
                ],
              );
            } else {
              if (bouts.isEmpty) {
                return Center(
                  child: Text(fencer == null &&
                          opponent == null &&
                          selectedDate == null
                      ? "Add a fencer or the date you are searching for above"
                      : "No bouts found for this combination!"),
                );
              } else {
                Bout bout = bouts[index - 1];
                return Column(
                  children: [
                    Text(DateFormat("EEEE, MMMM dd, yyyy").format(bout.date),
                        style: Theme.of(context).textTheme.bodyLarge),
                    Table(
                      columnWidths: const {2: FractionColumnWidth(0.2)},
                      key: ValueKey(bout),
                      children: [
                        TableRow(
                          children: [
                            Container(
                              color: bout.fencerWin
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                              child: Column(
                                children: [
                                  Text(
                                    bout.fencer.fullName,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: bout.fencerWin
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                  Text(
                                    "${bout.fencerScore}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: bout.fencerWin
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              color: bout.opponentWin
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                              child: Column(
                                children: [
                                  Text(
                                    bout.opponent.fullName,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: bout.opponentWin
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                  Text(
                                    "${bout.opponentScore}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: bout.opponentWin
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.router.push(
                                EditBoutRoute(bout: bout),
                              ),
                              icon: const Icon(Icons.edit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }
            }
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.router.push(
            AddBoutRoute(
              fencer: fencer,
              opponent: opponent,
              selectedDate: selectedDate,
            ),
          ),
          child: const Icon(Icons.add),
        ),
      );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(boutsProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
