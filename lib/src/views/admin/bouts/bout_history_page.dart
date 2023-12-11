import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: DropdownButton<UserData>(
                          hint: const Text("Fencer 1"),
                          items: List.generate(
                            fencers.length,
                            (index) => DropdownMenuItem(
                              value: fencers[index],
                              child: Text(fencers[index].fullShortenedName),
                            ),
                          ),
                          value: fencer,
                          onChanged: (value) {
                            setState(() {
                              fencer = value;
                            });
                          },
                          icon: fencer != null
                              ? IconButton(
                                  onPressed: () => setState(() {
                                        fencer = null;
                                      }),
                                  icon: const Icon(Icons.clear))
                              : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("vs."),
                      ),
                      Flexible(
                        child: DropdownButton<UserData>(
                          hint: const Text("Fencer 2"),
                          items: List.generate(
                            fencers.length,
                            (index) => DropdownMenuItem(
                              value: fencers[index],
                              child: Text(fencers[index].fullShortenedName),
                            ),
                          ),
                          value: opponent,
                          onChanged: (value) {
                            setState(() {
                              opponent = value;
                            });
                          },
                          icon: opponent != null
                              ? IconButton(
                                  onPressed: () => setState(() {
                                        opponent = null;
                                      }),
                                  icon: const Icon(Icons.clear))
                              : null,
                        ),
                      ),
                    ],
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
