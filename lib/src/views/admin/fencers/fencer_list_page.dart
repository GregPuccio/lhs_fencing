import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/fencers/fencer_details_page.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/indicator.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar_widget.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class FencerListPage extends ConsumerStatefulWidget {
  const FencerListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FencerListPageState();
}

class _FencerListPageState extends ConsumerState<FencerListPage> {
  late TextEditingController controller;
  List<Attendance> attendances = [];
  List<Practice> practices = [];
  Team? teamFilter;
  Weapon? weaponFilter;
  SchoolYear? yearFilter;
  bool? atPractice;
  FencerSortType fencerSortType = FencerSortType.lastName;

  /// null is all fencers, true is active only, false is inactive only
  bool? activeFilter = true;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> fencers = [];
    Widget whenData(List<BoutMonth> boutMonths) {
      List<Bout> bouts = [];
      for (var month in boutMonths) {
        bouts.addAll(month.bouts);
      }
      List<UserData> filteredFencers = fencers.toList();
      if (controller.text.isNotEmpty) {
        filteredFencers = fencers
            .where(
              (f) => f.fullName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
            )
            .toList();
      }
      if (teamFilter != null) {
        filteredFencers.retainWhere((fencer) => fencer.team == teamFilter);
      }
      if (yearFilter != null) {
        filteredFencers
            .retainWhere((fencer) => fencer.schoolYear == yearFilter);
      }
      if (weaponFilter != null) {
        filteredFencers.retainWhere((fencer) => fencer.weapon == weaponFilter);
      }
      if (activeFilter != null) {
        filteredFencers.retainWhere((fencer) => fencer.active == activeFilter);
      }
      // Apply sorting based on the selected sorting type
      switch (fencerSortType) {
        case FencerSortType.firstName:
          filteredFencers.sort((a, b) => a.firstName.compareTo(b.firstName));
          break;
        case FencerSortType.lastName:
          filteredFencers.sort((a, b) => a.lastName.compareTo(b.lastName));
          break;
        case FencerSortType.winRate:
          filteredFencers.sort((a, b) {
            double winRateA = calculateWinRate(a, bouts);
            double winRateB = calculateWinRate(b, bouts);
            return winRateB.compareTo(winRateA);
          });
          break;
        case FencerSortType.boutsFenced:
          filteredFencers.sort((a, b) {
            int boutsA = calculateTotalBouts(a, bouts);
            int boutsB = calculateTotalBouts(b, bouts);
            return boutsB.compareTo(boutsA);
          });
          break;
      }
      List<Practice> currentPractices = practices
          .where((p) =>
              p.startTime.isBefore(DateTime.now()) &&
              p.endTime.isAfter(DateTime.now()))
          .toList();
      String? currentPracticeID;
      if (currentPractices.isNotEmpty) {
        currentPracticeID = currentPractices.first.id;
      }
      if (atPractice == true) {
        filteredFencers.retainWhere(
            (fencer) => fencer.isAtPractice(attendances, currentPracticeID));
      } else if (atPractice == false) {
        filteredFencers.retainWhere(
            (fencer) => !fencer.isAtPractice(attendances, currentPracticeID));
      }
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountSetupPage(user: null),
              ),
            ),
          ),
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Fencer List"),
                const SizedBox(width: 8),
                TextBadge(text: "${filteredFencers.length}/${fencers.length}"),
              ],
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.bug_report),
            //     onPressed: () {
            //       for (var fencer in fencers) {
            //         List<AttendanceMonth> months = attendanceMonths
            //             .where((element) =>
            //                 element.attendances.first.userData.id == fencer.id)
            //             .toList();
            //         for (int index = 0; index < months.length; index++) {
            //           FirestoreService.instance.updateData(
            //             path: FirestorePath.attendance(
            //                 fencer.id, months[index].id),
            //             data: months[index].toMap(),
            //           );
            //         }
            //       }
            //     },
            //   )
            // ],
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: SearchBarWidget(controller)),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: PopupMenuButton<FencerSortType>(
                            initialValue: fencerSortType,
                            onSelected: (value) {
                              setState(() {
                                fencerSortType = value;
                              });
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: FencerSortType.firstName,
                                child: Text("Sort by First Name"),
                              ),
                              const PopupMenuItem(
                                value: FencerSortType.lastName,
                                child: Text("Sort by Last Name"),
                              ),
                              const PopupMenuItem(
                                value: FencerSortType.winRate,
                                child: Text("Sort by Win Rate"),
                              ),
                              const PopupMenuItem(
                                value: FencerSortType.boutsFenced,
                                child: Text("Sort by Bouts Fenced"),
                              ),
                            ],
                            icon: Column(
                              children: [
                                const Icon(Icons.sort),
                                Text(fencerSortType.type)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
                            if (yearFilter == null)
                              PopupMenuButton<SchoolYear>(
                                initialValue: yearFilter,
                                offset: const Offset(0, 30),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemBuilder: (context) =>
                                    List<PopupMenuItem<SchoolYear>>.generate(
                                  SchoolYear.values.length,
                                  (index) => PopupMenuItem(
                                    value: SchoolYear.values[index],
                                    child: Text(SchoolYear.values[index].type),
                                  ),
                                ).toList(),
                                icon: const Row(
                                  children: [
                                    Text("School Year"),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (SchoolYear value) => setState(() {
                                  yearFilter = value;
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
                                    yearFilter = null;
                                  }),
                                  icon: Row(children: [
                                    Text(yearFilter!.type),
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
                            if (currentPracticeID != null) ...[
                              if (atPractice == null)
                                PopupMenuButton<bool>(
                                  initialValue: atPractice,
                                  offset: const Offset(0, 30),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: true,
                                      child: Text("At Practice"),
                                    ),
                                    const PopupMenuItem(
                                      value: false,
                                      child: Text("Not At Practice"),
                                    ),
                                  ],
                                  icon: const Row(
                                    children: [
                                      Text("Attendance"),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                  onSelected: (bool value) => setState(() {
                                    atPractice = value;
                                  }),
                                )
                              else
                                Card(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: IconButton(
                                    iconSize: 16,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    onPressed: () => setState(() {
                                      atPractice = null;
                                    }),
                                    icon: Row(children: [
                                      Text(atPractice!
                                          ? "At Practice"
                                          : "Not At Practice"),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.cancel)
                                    ]),
                                  ),
                                ),
                            ],
                            if (activeFilter == null)
                              PopupMenuButton<bool>(
                                initialValue: activeFilter,
                                offset: const Offset(0, 30),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: true,
                                    child: Text("Active Only"),
                                  ),
                                  const PopupMenuItem(
                                    value: false,
                                    child: Text("Inactive Only"),
                                  ),
                                ],
                                icon: const Row(
                                  children: [
                                    Text("Active"),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (bool value) => setState(() {
                                  activeFilter = value;
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
                                    activeFilter = null;
                                  }),
                                  icon: Row(children: [
                                    Text(activeFilter!
                                        ? "Active Only"
                                        : "Inactive Only"),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.cancel)
                                  ]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.only(bottom: 60),
            itemCount: filteredFencers.length,
            itemBuilder: (context, index) {
              UserData fencer = filteredFencers[index];

              List<Attendance> fencerAttendances = attendances
                  .where((att) => att.userData.id == fencer.id)
                  .toList();
              bool atPractice =
                  fencer.isAtPractice(fencerAttendances, currentPracticeID);
              int attendedPractices = getShownPractices(
                practices,
                fencerAttendances,
                PracticeShowState.attended,
              ).length;
              int excusedPractices = getShownPractices(
                practices,
                fencerAttendances,
                PracticeShowState.excused,
              ).length;
              int unexcusedPractices = getShownPractices(
                practices,
                fencerAttendances,
                PracticeShowState.unexcused,
              ).length;
              int noReasonPractices = getShownPractices(
                practices,
                fencerAttendances,
                PracticeShowState.noReason,
              ).length;

              List<PieChartSectionData> showingSections = [
                PieChartSectionData(
                  value: attendedPractices / practices.length,
                  title: "$attendedPractices",
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                PieChartSectionData(
                  value: excusedPractices / practices.length,
                  title: "$excusedPractices",
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                PieChartSectionData(
                  value: unexcusedPractices / practices.length,
                  title: "$unexcusedPractices",
                  color: Theme.of(context).colorScheme.errorContainer,
                ),
                PieChartSectionData(
                  value: noReasonPractices / practices.length,
                  title: "$noReasonPractices",
                  color: Theme.of(context).disabledColor,
                ),
              ];

              List<Bout> fencerBouts =
                  bouts.where((bout) => bout.fencer.id == fencer.id).toList();

              List<Bout> boutsWon = bouts
                  .where(
                      (bout) => bout.fencer.id == fencer.id && bout.fencerWin)
                  .toList();
              int fencerWin = boutsWon.length;
              int touchesScored = fencerBouts.fold(
                  0, (previousValue, bout) => previousValue + bout.fencerScore);
              List<Bout> boutsLost = bouts
                  .where(
                      (bout) => bout.fencer.id == fencer.id && bout.opponentWin)
                  .toList();
              int fencerLoss = boutsLost.length;
              int touchesReceived = fencerBouts.fold(0,
                  (previousValue, bout) => previousValue + bout.opponentScore);
              String percentWins = (fencerWin / (fencerWin + fencerLoss) * 100)
                  .toStringAsFixed(0);

              return Column(
                children: [
                  if (atPractice) const TextBadge(text: "At Current Practice"),
                  ListTile(
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: PieChart(
                        PieChartData(
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: showingSections,
                          startDegreeOffset: 180,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(fencer.fullName),
                        if (fencer.rating.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(fencer.rating),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fencer.club.isNotEmpty) ...[
                          Text(fencer.club),
                          if (fencer.clubDays.isNotEmpty)
                            Text(
                              "At Club: ${fencer.clubDays.map((e) => e.abbreviation).join(", ")}",
                            ),
                        ],
                        Text(
                            "Bouts: ${fencerWin + fencerLoss} | WR: $percentWins%"),
                        Text(
                            "Record: $fencerWin-$fencerLoss | TS: $touchesScored TR: $touchesReceived"),
                        const Divider(),
                        Text(
                            "${fencer.team.name.capitalize} | ${fencer.schoolYear.type} | ${fencer.weapon.type}"),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(showingSections.length, (index) {
                            String percentage =
                                (showingSections[index].value * 100)
                                    .toStringAsFixed(2);
                            String amount = (showingSections[index].value *
                                    practices.length)
                                .toStringAsFixed(0);
                            return Column(
                              children: [
                                Indicator(
                                  isTouched: false,
                                  size: 12,
                                  color: showingSections[index].color,
                                  text:
                                      "${PracticeShowState.values[index + 1].type}: $amount ($percentage%)",
                                  isSquare: true,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                    onTap: () => context.router.push(
                      FencerDetailsRoute(fencerID: fencer.id),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
    }

    Widget whenPracticeData(List<PracticeMonth> practiceMonths) {
      practices.clear();
      for (var month in practiceMonths) {
        practices.addAll(month.practices.where((practice) => practice.startTime
            .isBefore(DateTime.now().add(const Duration(hours: 1)))));
      }
      return ref.watch(thisSeasonBoutsProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      attendances.clear();
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      return ref.watch(practicesProvider).when(
            data: whenPracticeData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenAttendanceData,
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

// Helper functions
double calculateWinRate(UserData fencer, List<Bout> bouts) {
  final userBouts = bouts.where((bout) => bout.fencer.id == fencer.id).toList();
  final wins = userBouts.where((bout) => bout.fencerWin).length;
  final total = userBouts.length;
  return total > 0 ? (wins / total) * 100 : 0.0;
}

int calculateTotalBouts(UserData fencer, List<Bout> bouts) {
  return bouts.where((bout) => bout.fencer.id == fencer.id).length;
}
