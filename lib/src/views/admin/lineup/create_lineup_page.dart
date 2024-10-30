import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class CreateLineupPage extends ConsumerStatefulWidget {
  final Team? teamFilter;
  final Weapon? weaponFilter;
  final Map<String, int> adjustAmounts;
  const CreateLineupPage(
      {this.teamFilter,
      this.weaponFilter,
      required this.adjustAmounts,
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
  Team? teamFilter;
  Weapon? weaponFilter;
  bool loadFencers = true;

  @override
  void initState() {
    teamFilter = widget.teamFilter;
    weaponFilter = widget.weaponFilter;
    super.initState();
  }

  void updateFencers() {
    fencersToShow = fencers
        .where((f) => f.weapon == weaponFilter && f.team == teamFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var attendanceMonth in attendanceMonths) {
        attendances.addAll(attendanceMonth.attendances);
      }

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
                              updateFencers();
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
                                updateFencers();
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
                    "Team and weapon filters must be selected to create a lineup"),
              )
            : ReorderableListView.builder(
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
                  return CheckboxListTile(
                    enabled:
                        starters.contains(fencer) ? true : starters.length < 2,
                    selected: starters.contains(fencer),
                    secondary: CircleAvatar(
                      child: Text("${index + 1}"),
                    ),
                    key: ValueKey(fencer),
                    title: Text(fencer.fullName),
                    subtitle: Text(
                        "Rating: ${fencer.rating.isEmpty ? "U" : fencer.rating}"),
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
            onPressed: teamFilter == null || weaponFilter == null
                ? null
                : () async {
                    await FirestoreService.instance.addData(
                      path: FirestorePath.lineups(),
                      data: Lineup(
                              id: "",
                              fencers: fencersToShow,
                              starters: starters,
                              createdAt: DateTime.now(),
                              practicesAdded: [],
                              weapon: weaponFilter!,
                              team: teamFilter!)
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

    Widget whenFencersData(List<UserData> data) {
      if (loadFencers) {
        fencers = data.toList();
        updateFencers();
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
