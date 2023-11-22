import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';
import 'package:lhs_fencing/src/widgets/attendance_status_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';
import 'package:url_launcher/url_launcher.dart';

PracticeShowState practiceShowState = PracticeShowState.all;

@RoutePage()
class PracticePage extends ConsumerWidget {
  final String practiceID;
  const PracticePage({required this.practiceID, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<UserData> fencers = [];
    late Practice practice;
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == practiceID) {
            attendances.add(attendance);
          }
        }
      }
      fencers.sort();
      fencers.retainWhere((fencer) =>
          practice.team == Team.both ? true : fencer.team == practice.team);
      List<List<UserData>> fencerLists = [
        fencers,
        getShownFencers(fencers, attendances, PracticeShowState.attended),
        getShownFencers(fencers, attendances, PracticeShowState.excused),
        getShownFencers(fencers, attendances, PracticeShowState.unexcused),
        getShownFencers(fencers, attendances, PracticeShowState.noReason),
      ];

      return DefaultTabController(
        length: PracticeShowState.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(practice.startString),
            actions: [
              IconButton(
                onPressed: () async {
                  context.router.push(EditPracticeRoute(practice: practice));
                },
                icon: const Icon(Icons.edit),
              ),
            ],
            bottom: TabBar(
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
                                    onPressed: () => context.router.pop(),
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
                                              fencerLists, tod, coach));
                                      try {
                                        launchUrl(url).then(
                                            (value) => context.router.pop());
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
                  int attIndex =
                      attendances.indexWhere((a) => a.userData.id == fencer.id);
                  Attendance? attendance;
                  if (attIndex != -1) {
                    attendance = attendances[attIndex];
                  }
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (attendance != null) AttendanceStatusBar(attendance),
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
                      ],
                    ),
                    onTap: () => context.router.push(
                      EditFencerStatusRoute(
                        fencer: fencer,
                        practice: practice,
                        attendance: attendance,
                      ),
                    ),
                    subtitle:
                        attendance != null ? AttendanceInfo(attendance) : null,
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
          (element) =>
              element.practices.any((element) => element.id == practiceID),
          orElse: () {
        context.popRoute();
        return PracticeMonth(id: "id", practices: [], month: DateTime.now());
      });
      practice =
          month.practices.firstWhere((element) => element.id == practiceID);
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(practicesProvider).when(
          data: whenPracticeData,
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
