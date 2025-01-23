import 'package:auto_route/auto_route.dart';
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
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_status_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar_widget.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/firestore/firestore_service.dart';

PracticeShowState practiceShowState = PracticeShowState.all;

@RoutePage()
class PracticePage extends ConsumerStatefulWidget {
  final String practiceID;
  const PracticePage({required this.practiceID, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  late TextEditingController controller;
  Team teamToShow = Team.both;
  Weapon? weaponToShow = Weapon.unsure;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {
        if (teamToShow != Team.both && controller.text.isNotEmpty) {
          teamToShow = Team.both;
        }
        if (weaponToShow != Weapon.unsure && controller.text.isNotEmpty) {
          weaponToShow = Weapon.unsure;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future updatePractice(Practice practice) async {
    List<PracticeMonth> months = ref.read(thisSeasonPracticesProvider).value!;

    DateTime date = DateTime(practice.startTime.year, practice.startTime.month);
    int index = months.indexWhere((m) => m.month.isAtSameMomentAs(date));
    if (index == -1) {
      months.add(PracticeMonth(id: "", practices: [practice], month: date));
    } else {
      int pIndex =
          months[index].practices.indexWhere((p) => p.id == practice.id);
      if (pIndex == -1) {
        months[index].practices.add(practice);
      } else {
        months[index].practices.replaceRange(
          pIndex,
          pIndex + 1,
          [practice],
        );
      }
    }
    await FirestoreService.instance.updateData(
      path: FirestorePath.thisSeasonPractice(months[index].id),
      data: months[index].toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> fencers = [];
    late Practice practice;
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == widget.practiceID) {
            attendances.add(attendance);
          }
        }
      }
      fencers.sort();
      fencers.retainWhere((fencer) =>
          (practice.team == Team.both ? true : fencer.team == practice.team) &&
          fencer.active);
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
      if (teamToShow != Team.both) {
        filteredFencers.retainWhere((f) => f.team == teamToShow);
      }
      if (weaponToShow == null) {
        filteredFencers.retainWhere((f) => f.weapon != Weapon.manager);
      } else if (weaponToShow != Weapon.unsure) {
        filteredFencers.retainWhere((f) => f.weapon == weaponToShow);
      }
      List<List<UserData>> fencerLists = [
        filteredFencers,
        getShownFencers(
            filteredFencers, attendances, PracticeShowState.attended),
        getShownFencers(
            filteredFencers, attendances, PracticeShowState.excused),
        getShownFencers(
            filteredFencers, attendances, PracticeShowState.unexcused),
        getShownFencers(
            filteredFencers, attendances, PracticeShowState.noReason),
      ];
      UserData me = ref.watch(userDataProvider).value!;
      List<BoutMonth> months = ref.watch(thisSeasonBoutsProvider).value ?? [];
      bool isTakingBus = practice.busCoaches.any((coach) => coach.id == me.id);
      return DefaultTabController(
        length: PracticeShowState.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(practice.location),
            actions: [
              IconButton(
                onPressed: () async {
                  context.router.push(EditPracticeRoute(practice: practice));
                },
                icon: const Icon(Icons.edit),
              ),
            ],
            bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(130 + (practice.type.usesBus ? 70 : 0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextBadge(text: practice.team.type),
                        const SizedBox(width: 8),
                        Text(practice.type.type),
                        const SizedBox(width: 4),
                        const Text("|"),
                        const SizedBox(width: 4),
                        Text(practice.startString),
                      ],
                    ),
                  ),
                  if (practice.type.usesBus)
                    CheckboxListTile.adaptive(
                      title: const Text("Coaches Taking The Bus:"),
                      subtitle: Text(practice.busCoaches.isEmpty
                          ? "None yet"
                          : practice.busCoaches
                              .map((c) => c.firstName)
                              .join(", ")),
                      value: isTakingBus,
                      onChanged: (val) {
                        if (isTakingBus) {
                          setState(() {
                            practice.busCoaches
                                .removeWhere((coach) => coach.id == me.id);
                          });
                        } else {
                          setState(() {
                            practice.busCoaches.add(me);
                          });
                        }
                        updatePractice(practice);
                      },
                    ),
                  // if (practice.type.hasScoring)
                  //   const ListTile(
                  //     title: Text("Scoring"),
                  //     subtitle: Text("14-13 | Won @ 6 | 7-6-2"),
                  //   ),
                  // const Divider(),
                  Row(
                    children: [
                      Flexible(child: SearchBarWidget(controller)),
                      if (practice.team == Team.both)
                        SizedBox(
                          width: 75,
                          child: IconButton(
                            onPressed: () async {
                              Team? retVal = await showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Scaffold(
                                      appBar: AppBar(
                                        title: Text("Selected Team"),
                                      ),
                                      body: Column(
                                        children: Team.values.map((team) {
                                          return RadioListTile.adaptive(
                                              value: team,
                                              groupValue: teamToShow,
                                              title: Text(team.type),
                                              onChanged: (value) async {
                                                if (value != null) {
                                                  await context.maybePop(value);
                                                }
                                              });
                                        }).toList(),
                                      ),
                                    );
                                  });
                              if (retVal != null) {
                                setState(() {
                                  teamToShow = retVal;
                                });
                              }
                            },
                            icon: Column(
                              children: [
                                const Icon(Icons.people),
                                Text(teamToShow.shortName)
                              ],
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 75,
                        child: IconButton(
                          onPressed: () async {
                            dynamic retVal = await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Scaffold(
                                    appBar: AppBar(
                                      title: Text("Selected Weapon"),
                                    ),
                                    body: Column(
                                      children: List.generate(
                                          Weapon.values.length + 1, (index) {
                                        if (index == Weapon.values.length) {
                                          return RadioListTile.adaptive(
                                              value: null,
                                              groupValue: weaponToShow,
                                              title: const Text(
                                                  "Fencers (Non Managers)"),
                                              onChanged: (value) async {
                                                await context.maybePop(true);
                                              });
                                        } else {
                                          Weapon weapon = Weapon.values[index];
                                          return RadioListTile.adaptive(
                                              value: weapon,
                                              groupValue: weaponToShow,
                                              title: Text(weapon.shortName),
                                              onChanged: (value) async {
                                                if (value != null) {
                                                  await context.maybePop(value);
                                                }
                                              });
                                        }
                                      }).toList(),
                                    ),
                                  );
                                });
                            if (retVal != null) {
                              setState(() {
                                retVal == true
                                    ? weaponToShow = null
                                    : weaponToShow = retVal;
                              });
                            }
                          },
                          icon: Column(
                            children: [
                              const Icon(Symbols.swords),
                              Text(weaponToShow?.shortName ?? "Fencers")
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  TabBar(
                    isScrollable: true,
                    tabs: List.generate(
                      PracticeShowState.values.length,
                      (index) => Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(PracticeShowState.values[index].fencerType),
                            const SizedBox(width: 8),
                            TextBadge(text: "${fencerLists[index].length}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: List.generate(
              PracticeShowState.values.length,
              (index) => ListView.separated(
                padding: const EdgeInsets.only(bottom: 60),
                itemCount: fencerLists[index].length +
                    (index == PracticeShowState.values.length - 1 ? 1 : 0),
                itemBuilder: (context, i) {
                  if (index == PracticeShowState.values.length - 1) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Send An Email"),
                                content: const Text(
                                    "Do you want to send an email to all of the students not present for this practice?\n(This will open a prepopulated message in the email app and you will be able to edit it before sending)"),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.router.maybePop(),
                                    child: const Text("No, cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      int hour = DateTime.now().hour;
                                      String tod = hour < 12
                                          ? "Morning"
                                          : hour < 18
                                              ? "Afternoon"
                                              : "Evening";
                                      UserData coach = ref
                                          .read(userDataProvider)
                                          .asData!
                                          .value!;
                                      Uri url = Uri(
                                          scheme: "mailto",
                                          path: coach.email,
                                          query: practice.emailMessage(
                                              fencerLists[index], tod, coach));
                                      try {
                                        launchUrl(url).then((value) =>
                                            context.mounted
                                                ? context.router.maybePop()
                                                : 0);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(e.toString())));
                                      }
                                    },
                                    child: const Text("Yes, please"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Text("Email Absent Fencers"),
                          label: const Icon(Icons.email),
                        ),
                      );
                    } else {
                      i--;
                    }
                  }
                  UserData fencer = fencerLists[index][i];
                  List<Bout> bouts = [];
                  for (var month in months) {
                    if (month.fencerID == fencer.id) {
                      bouts.addAll(month.bouts);
                    }
                  }
                  bouts.retainWhere((b) =>
                      DateTime(b.date.year, b.date.month, b.date.day)
                          .isAtSameMomentAs(DateTime(
                              practice.startTime.year,
                              practice.startTime.month,
                              practice.startTime.day)));

                  Attendance attendance = attendances.firstWhere(
                    (element) =>
                        element.id == practice.id &&
                        element.userData.id == fencer.id,
                    orElse: () => Attendance.create(practice, fencer),
                  );

                  bool didBout = bouts.length >= 3;

                  return ListTile(
                    textColor: index == 1
                        ? !didBout
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary
                        : null,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AttendanceStatusBar(attendance),
                        Row(
                          children: [
                            Text(fencer.fullName),
                            if (fencer.clubDays.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                  "(${fencer.clubDays.map((e) => e.abbreviation).join(",")})"),
                            ],
                          ],
                        ),
                        if (bouts.isNotEmpty && index == 1)
                          Text(
                              "Recorded: ${bouts.length} bout${bouts.length == 1 ? "" : "s"}"),
                      ],
                    ),
                    onTap: () => context.router.push(
                      EditFencerStatusRoute(
                        fencer: fencer,
                        practice: practice,
                        attendance: attendance,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fencer.info +
                            (fencer.clubDays.any((d) =>
                                    d.weekday == practice.startTime.weekday)
                                ? " | Normally At Club"
                                : "")),
                        Text(attendance.status(practice)),
                        if (attendance.comments.isNotEmpty)
                          Text(
                            "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.edit),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ),
        ),
      );
    }

    Widget whenPracticeData(List<PracticeMonth> data) {
      PracticeMonth month = data.firstWhere(
          (element) => element.practices
              .any((element) => element.id == widget.practiceID), orElse: () {
        context.maybePop();
        return PracticeMonth(id: "id", practices: [], month: DateTime.now());
      });
      practice = month.practices
          .firstWhere((element) => element.id == widget.practiceID);
      return ref.watch(thisSeasonAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data.toList();
      return ref.watch(thisSeasonPracticesProvider).when(
          data: whenPracticeData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(thisSeasonFencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}

List<UserData> getShownFencers(List<UserData> fencers,
    List<Attendance> attendances, PracticeShowState practiceShowState) {
  return fencers.where((p) {
    switch (practiceShowState) {
      case PracticeShowState.all:
        return true;
      case PracticeShowState.attended:
        return attendances.any((a) => p.id == a.userData.id && a.attended);
      case PracticeShowState.excused:
        return attendances
            .any((a) => p.id == a.userData.id && a.excusedAbsense);
      case PracticeShowState.unexcused:
        return attendances
            .any((a) => p.id == a.userData.id && a.unexcusedAbsense);
      case PracticeShowState.noReason:
        return !attendances.any((a) =>
            p.id == a.userData.id &&
            (a.attended || a.excusedAbsense || a.unexcusedAbsense));
    }
  }).toList();
}
