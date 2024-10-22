import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class CreateLineupPage extends ConsumerStatefulWidget {
  final Team? teamFilter;
  final Weapon? weaponFilter;
  const CreateLineupPage({this.teamFilter, this.weaponFilter, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateLineupPageState();
}

class _CreateLineupPageState extends ConsumerState<CreateLineupPage> {
  late List<Lineup> lineups;
  late List<UserData> fencers;
  Team? teamFilter;
  Weapon? weaponFilter;
  bool loadFencers = true;

  @override
  void initState() {
    teamFilter = widget.teamFilter;
    weaponFilter = widget.weaponFilter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var attendanceMonth in attendanceMonths) {
        attendances.addAll(attendanceMonth.attendances);
      }
      List<UserData> fencersToShow = fencers
          .where((f) => f.weapon == weaponFilter && f.team == teamFilter)
          .toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text("Create Lineup"),
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
        body: ReorderableListView.builder(
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
            return ListTile(
              key: ValueKey(fencer),
              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              title: Text(fencer.fullName),
              subtitle: Text(
                  "Rating: ${fencer.rating.isEmpty ? "U" : fencer.rating}"),
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton.icon(
            onPressed: () {
              context.maybePop();
            },
            label: const Text("Create This Lineup"),
            icon: const Icon(Icons.save),
          ),
        ),
      );
    }

    Widget whenFencersData(List<UserData> data) {
      if (loadFencers) {
        fencers = data.toList();
        loadFencers = false;
      }
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
