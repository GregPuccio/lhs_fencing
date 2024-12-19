import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class LineupPage extends ConsumerStatefulWidget {
  const LineupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LineupPageState();
}

class _LineupPageState extends ConsumerState<LineupPage> {
  late List<Lineup> lineups;
  late List<UserData> fencers;
  late List<Practice> practices;
  Team? teamFilter;
  Weapon? weaponFilter;

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var attendanceMonth in attendanceMonths) {
        attendances.addAll(attendanceMonth.attendances);
      }

      List<Lineup> filteredLineups = lineups
          .where((l) => l.team == teamFilter && l.weapon == weaponFilter)
          .toList();
      filteredLineups.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      Lineup? currentLineup =
          filteredLineups.isEmpty ? null : filteredLineups.last;

      List<UserData> fencersToShow = fencers
          .where((f) => f.team == teamFilter && f.weapon == weaponFilter)
          .toList();

      List<UserData> fencersNoLongerInWeapon = currentLineup?.fencers
              .where((f) => !(fencersToShow.contains(f)))
              .toList() ??
          [];

      List<UserData> fencersNotInLineup = fencersToShow
          .where((f) => !(currentLineup?.fencers.contains(f) ?? false))
          .toList();

      // remove practices and attendances overall that are already taken into account
      List<Practice> unaccountedPractices = practices
          .where((p) =>
              !(currentLineup?.practicesAdded.contains(p.id) ?? false) &&
              p.type.adjustsLineup)
          .toList();
      List<Attendance> unaccountedAttendances = attendances
          .where(
              (a) => !(currentLineup?.practicesAdded.contains(a.id) ?? false))
          .toList();

      Map<String, int> adjustAmounts = {};

      // look at fencers one by one starting at the top and moving them to the bottom
      // if they have fenced and are not a starter in one of the top 2 spots
      List<UserData> fencerAdjustmentList =
          currentLineup?.fencers.toList() ?? [];
      for (int i = 0; i < fencerAdjustmentList.length; i++) {
        UserData fencer = fencerAdjustmentList[i];
        // inside of this collect attendances for this fencer specifically
        List<Attendance> fencerAttendances = unaccountedAttendances
            .where((a) => a.userData.id == fencer.id)
            .toList();

        List<Attendance> unexcusedAbsences =
            fencerAttendances.where((a) => a.unexcusedAbsense).toList();
        List<Attendance> practicesArrivedLate =
            fencerAttendances.where((a) => a.wasLate).toList();
        List<Attendance> practicesLeftEarly =
            fencerAttendances.where((a) => a.leftEarly).toList();

        double adjustmentAmount = 0;
        for (var practice in unaccountedPractices) {
          if (unexcusedAbsences.any((a) => a.id == practice.id)) {
            if (practice.type == TypePractice.practice) {
              adjustmentAmount += 1;
            } else {
              adjustmentAmount += 3;
            }
          }
          if (practicesArrivedLate.any((a) => a.id == practice.id)) {
            adjustmentAmount += 0.49;
          }
          if (practicesLeftEarly.any((a) => a.id == practice.id)) {
            adjustmentAmount += 0.49;
          }
        }
        adjustAmounts.putIfAbsent(fencer.id, () => adjustmentAmount.round());
      }

      if (adjustAmounts.isNotEmpty) {
        for (int i = 0; i < fencerAdjustmentList.length; i++) {
          UserData fencer = fencerAdjustmentList[i];
          int adjustmentNumber = adjustAmounts.putIfAbsent(fencer.id, () => 0);
          int numberOfFencersBelowWithoutAdjustments =
              adjustAmounts.values.skip(i).where((val) => val == 0).length;
          if (adjustmentNumber > numberOfFencersBelowWithoutAdjustments) {
            adjustAmounts.update(
                fencer.id, (value) => numberOfFencersBelowWithoutAdjustments);
          }
        }
      }

      return Scaffold(
        floatingActionButton: teamFilter != null && weaponFilter != null
            ? FloatingActionButton.extended(
                onPressed: () => context.router.push(
                  CreateLineupRoute(
                    adjustAmounts: adjustAmounts,
                    unaccountedPractices: unaccountedPractices,
                    team: teamFilter!,
                    weapon: weaponFilter!,
                  ),
                ),
                label: Text(
                    "${currentLineup != null ? "Update" : "Create"} Lineup"),
                icon: const Icon(Icons.update),
              )
            : null,
        appBar: AppBar(
          title: const Text("Current Lineup"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, left: 15),
                  child: SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (teamFilter == null)
                          PopupMenuButton<Team>(
                            initialValue: teamFilter,
                            offset: const Offset(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (context) =>
                                List<PopupMenuItem<Team>>.generate(
                              Team.values.length - 1,
                              (index) => PopupMenuItem(
                                value: Team.values[index],
                                child: Text(Team.values[index].type),
                              ),
                            ).toList(),
                            icon: const Row(
                              children: [
                                Text("Team"),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            onSelected: (Team value) => setState(() {
                              teamFilter = value;
                            }),
                          )
                        else
                          Card(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: IconButton(
                              iconSize: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              onPressed: () => setState(() {
                                teamFilter = null;
                              }),
                              icon: Row(children: [
                                Text(teamFilter!.type),
                                const SizedBox(width: 4),
                                const Icon(Icons.cancel)
                              ]),
                            ),
                          ),
                        if (weaponFilter == null)
                          PopupMenuButton<Weapon>(
                            initialValue: weaponFilter,
                            offset: const Offset(0, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (context) =>
                                List<PopupMenuItem<Weapon>>.generate(
                              Weapon.values.length,
                              (index) => PopupMenuItem(
                                value: Weapon.values[index],
                                child: Text(Weapon.values[index].type),
                              ),
                            ).toList(),
                            icon: const Row(
                              children: [
                                Text("Weapon"),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                            onSelected: (Weapon value) => setState(() {
                              weaponFilter = value;
                            }),
                          )
                        else
                          Card(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: IconButton(
                              iconSize: 16,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              onPressed: () => setState(() {
                                weaponFilter = null;
                              }),
                              icon: Row(children: [
                                Text(weaponFilter!.type),
                                const SizedBox(width: 4),
                                const Icon(Icons.cancel)
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: teamFilter == null || weaponFilter == null
            ? const ListTile(
                title: Text("Select your filters!"),
                subtitle: Text(
                    "Select a team and weapon filter to show the current lineup"),
              )
            : ListView.separated(
                itemCount: fencersToShow.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    if (currentLineup != null) {
                      return ListTile(
                        title: Text(
                            "As of ${DateFormat("EEEE, MM/dd/y 'at' hh:mm aa").format(currentLineup.createdAt)}"),
                      );
                    } else {
                      return ListTile(
                        title: const Text("No lineups found!"),
                        subtitle: const Text('Tap here or below to create one'),
                        onTap: () => context.router.push(
                          CreateLineupRoute(
                            adjustAmounts: adjustAmounts,
                            unaccountedPractices: unaccountedPractices,
                            team: teamFilter!,
                            weapon: weaponFilter!,
                          ),
                        ),
                      );
                    }
                  } else {
                    index--;

                    if (currentLineup == null ||
                        currentLineup.fencers.length < index) {
                      UserData fencer = fencersNotInLineup[
                          index - (currentLineup?.fencers.length ?? 0)];
                      return ListTile(
                        key: ValueKey(fencer),
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                          child: const Text("-"),
                        ),
                        title: Text(fencer.fullName),
                        subtitle: Text(
                            "Rating: ${fencer.rating.isEmpty ? "U" : fencer.rating}"),
                      );
                    } else {
                      UserData fencer = currentLineup.fencers[index];
                      bool removeFencer =
                          fencersNoLongerInWeapon.contains(fencer);
                      int adjustAmount =
                          adjustAmounts.putIfAbsent(fencer.id, () => 0);
                      bool isStarter = currentLineup.starters.contains(fencer);
                      List<Attendance> fencerAttendances =
                          unaccountedAttendances
                              .where((a) =>
                                  a.userData.id == fencer.id &&
                                  unaccountedPractices.any((p) => p.id == a.id))
                              .toList();
                      List<Attendance> unexcusedAbsences = fencerAttendances
                          .where((a) => a.unexcusedAbsense)
                          .toList();
                      int practicesMissed = unexcusedAbsences
                          .where((a) =>
                              a.userData.id == fencer.id &&
                              unaccountedPractices
                                  .where((p) =>
                                      p.id == a.id &&
                                      p.type == TypePractice.practice)
                                  .isNotEmpty)
                          .length;
                      int meetsMissed =
                          unexcusedAbsences.length - practicesMissed;
                      int practicesArrivedLate =
                          fencerAttendances.where((a) => a.wasLate).length;
                      int practicesLeftEarly =
                          fencerAttendances.where((a) => a.leftEarly).length;
                      return ListTile(
                        key: ValueKey(fencer),
                        leading: CircleAvatar(
                          backgroundColor: isStarter
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          foregroundColor: isStarter
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                          child: Text("${index + 1}"),
                        ),
                        title: Wrap(
                          children: [
                            if (removeFencer) ...[
                              Text("FENCER TO BE REMOVED"),
                              const SizedBox(width: 8),
                            ],
                            Text(fencer.fullName + (isStarter ? "*" : "")),
                            const SizedBox(width: 8),
                            Text(fencer.rating.isEmpty ? "U" : fencer.rating),
                            const SizedBox(width: 8),
                            if (adjustAmount > 0) ...[
                              Icon(
                                Icons.arrow_downward,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              Text(
                                "$adjustAmount",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                      );
                    }
                  }
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
      );
    }

    Widget whenPracticesData(List<PracticeMonth> data) {
      practices = [];
      for (var month in data) {
        practices.addAll(month.practices);
      }
      practices = practices.where((p) => p.isOver).toList();
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    Widget whenLineupsData(List<Lineup> data) {
      lineups = data;
      fencers = ref.watch(activeFencersProvider);
      return ref.watch(practicesProvider).when(
          data: whenPracticesData,
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
