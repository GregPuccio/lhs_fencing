import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/lineup/create_lineup_page.dart';
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
  Team? teamFilter;
  Weapon? weaponFilter;

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var attendanceMonth in attendanceMonths) {
        attendances.addAll(attendanceMonth.attendances);
      }

      Lineup currentLineup = Lineup(
          id: "id",
          fencers: [fencers[0], fencers[1], fencers[3]],
          starters: [fencers[0], fencers[3]],
          createdAt: DateTime.now(),
          practicesAdded: [],
          weapon: Weapon.epee,
          team: Team.boys);

      List<UserData> fencersNotInLineup =
          fencers.where((f) => !currentLineup.fencers.contains(f)).toList();

      return DefaultTabController(
        length: PracticeShowState.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Current Lineup"),
            actions: [
              IconButton(
                onPressed: () => context.router.push(
                  CreateLineupRoute(
                    teamFilter: teamFilter,
                    weaponFilter: weaponFilter,
                  ),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
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
          body: lineups.isNotEmpty
              ? const ListTile()
              : ListView.separated(
                  itemCount: fencers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text(
                            "As of ${DateFormat("EEEE, MM/dd/y 'at' hh:mm aa").format(currentLineup.createdAt)}"),
                      );
                    } else {
                      index--;
                      if (currentLineup.fencers.length <= index) {
                        UserData fencer = fencersNotInLineup[
                            index - currentLineup.fencers.length];
                        return ListTile(
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
                        bool isStarter =
                            currentLineup.starters.contains(fencer);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isStarter
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            foregroundColor: isStarter
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                            child: Text("${index + 1}"),
                          ),
                          title: Text(fencer.fullName + (isStarter ? "*" : "")),
                          subtitle: Text(
                              "Rating: ${fencer.rating.isEmpty ? "U" : fencer.rating}"),
                        );
                      }
                    }
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
        ),
      );
    }

    Widget whenFencersData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    Widget whenLineupsData(List<Lineup> data) {
      lineups = data;
      return ref.watch(fencersProvider).when(
          data: whenFencersData,
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
