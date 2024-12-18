import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class CreateLineupPage extends ConsumerStatefulWidget {
  final Team team;
  final Weapon weapon;
  final Map<String, int> adjustAmounts;
  final List<Practice> unaccountedPractices;
  const CreateLineupPage(
      {required this.team,
      required this.weapon,
      required this.adjustAmounts,
      required this.unaccountedPractices,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateLineupPageState();
}

class _CreateLineupPageState extends ConsumerState<CreateLineupPage> {
  late List<Lineup> lineups;
  late List<UserData> fencers;
  late List<UserData> fencersToShow;
  List<UserData> starters = [];
  late Team team;
  late Weapon weapon;
  bool loadFencers = true;
  Lineup? currentLineup;

  @override
  void initState() {
    team = widget.team;
    weapon = widget.weapon;
    super.initState();
  }

  void updateFencers() {}

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var attendanceMonth in attendanceMonths) {
        attendances.addAll(attendanceMonth.attendances);
      }
      List<Attendance> unaccountedAttendances = attendances
          .where(
              (a) => !(currentLineup?.practicesAdded.contains(a.id) ?? false))
          .toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text("Create New Lineup"),
        ),
        body: ReorderableListView.builder(
          header: Column(
            children: [
              Row(
                children: [
                  Flexible(
                      child: ListTile(
                    leading: const Icon(Symbols.swords),
                    subtitle: const Text("Weapon"),
                    title: Text(weapon.type),
                  )),
                  Flexible(
                      child: ListTile(
                    leading: const Icon(Symbols.diversity_3),
                    subtitle: const Text("Team"),
                    title: Text(team.type),
                  )),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Flexible(
                      child: ListTile(
                    // leading: const Icon(Symbols.swords),
                    title: const Text("Starting Lineup:"),
                    subtitle: Text(currentLineup != null
                        ? DateFormat("EEE, MM/dd @ hh:mm aa")
                            .format(currentLineup!.createdAt)
                        : "None found"),
                  )),
                  Flexible(
                    child: ListTile(
                      title: const Text("Attendances Used:"),
                      subtitle: Text(widget.unaccountedPractices
                          .map(
                            (p) =>
                                "${p.type.abbrev} ${DateFormat("MM/dd").format(p.startTime)}",
                          )
                          .join(", ")),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final UserData item = fencersToShow.removeAt(oldIndex);
              fencersToShow.insert(newIndex, item);
            });
          },
          itemCount: fencersToShow.length,
          itemBuilder: (context, index) {
            UserData fencer = fencersToShow[index];
            int adjustAmount =
                widget.adjustAmounts.putIfAbsent(fencer.id, () => 0);
            List<Attendance> fencerAttendances = unaccountedAttendances
                .where((a) =>
                    a.userData.id == fencer.id &&
                    widget.unaccountedPractices.any((p) => p.id == a.id))
                .toList();
            List<Attendance> unexcusedAbsences =
                fencerAttendances.where((a) => a.unexcusedAbsense).toList();
            int practicesMissed = unexcusedAbsences
                .where((a) =>
                    a.userData.id == fencer.id &&
                    widget.unaccountedPractices
                        .where((p) =>
                            p.id == a.id && p.type == TypePractice.practice)
                        .isNotEmpty)
                .length;
            int meetsMissed = unexcusedAbsences.length - practicesMissed;
            int practicesArrivedLate =
                fencerAttendances.where((a) => a.wasLate).length;
            int practicesLeftEarly =
                fencerAttendances.where((a) => a.leftEarly).length;
            return CheckboxListTile(
              enabled: starters.contains(fencer) ? true : starters.length < 2,
              selected: starters.contains(fencer),
              secondary: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              key: ValueKey(fencer),
              title: Row(
                children: [
                  Text(fencer.fullName),
                  const SizedBox(width: 8),
                  Text(fencer.rating.isEmpty ? "U" : fencer.rating),
                  const SizedBox(width: 8),
                  if (adjustAmount > 0) ...[
                    Text(
                      "Dropped $adjustAmount Position${adjustAmount > 1 ? "s" : ""}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Practices Missed: $practicesMissed"),
                  Text("Meets Missed: $meetsMissed"),
                  Text("Arrived Late: $practicesArrivedLate"),
                  Text("Left Early: $practicesLeftEarly"),
                  Text(
                      "Fenced: ${fencerAttendances.any((a) => a.participated)}")
                ],
              ),
              value: starters.contains(fencer),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    starters.add(fencer);
                  } else {
                    starters.remove(fencer);
                  }
                });
              },
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: TextButton.icon(
            onPressed: () async {
              await FirestoreService.instance.addData(
                path: FirestorePath.lineups(),
                data: Lineup(
                        id: "",
                        fencers: fencersToShow,
                        starters: starters,
                        createdAt: DateTime.now(),
                        practicesAdded: widget.unaccountedPractices
                            .map((p) => p.id)
                            .toList(),
                        weapon: weapon,
                        team: team)
                    .toMap(),
              );
              if (context.mounted) {
                await context.maybePop();
              }
            },
            label: const Text("Create This Lineup"),
            icon: const Icon(Icons.save),
          ),
        ),
      );
    }

    Widget whenLineupsData(List<Lineup> data) {
      lineups = data;
      if (loadFencers) {
        fencers = ref.read(activeFencersProvider);

        List<Lineup> filteredLineups =
            lineups.where((l) => l.team == team && l.weapon == weapon).toList();
        currentLineup = filteredLineups.isEmpty ? null : filteredLineups.last;

        fencersToShow =
            fencers.where((f) => f.weapon == weapon && f.team == team).toList();
        List<UserData> fencersNotInLineup = fencersToShow
            .where((f) => !(currentLineup?.fencers.contains(f) ?? false))
            .toList();

        fencersToShow = (currentLineup?.fencers ?? []) + fencersNotInLineup;

        List<UserData> adjustedFencers = fencersToShow.reversed.toList();

        for (int i = 0; i < adjustedFencers.length; i++) {
          UserData fencer = adjustedFencers[i];
          int adjustAmount =
              widget.adjustAmounts.putIfAbsent(fencer.id, () => 0);

          if (i - adjustAmount >= 0) {
            adjustedFencers.removeAt(i);
            adjustedFencers.insert(i - adjustAmount, fencer);
          } else {
            adjustedFencers.removeAt(i);
            adjustedFencers.insert(0, fencer);
          }
        }
        fencersToShow = adjustedFencers.reversed.toList();

        loadFencers = false;
      }
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(lineupsProvider).when(
          data: whenLineupsData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
