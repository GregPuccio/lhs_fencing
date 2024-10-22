import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class FencerDetailsPage extends ConsumerStatefulWidget {
  final String fencerID;
  const FencerDetailsPage({required this.fencerID, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FencerDetailsPageState();
}

class _FencerDetailsPageState extends ConsumerState<FencerDetailsPage> {
  late TextEditingController controller;
  PracticeShowState practiceShowState = PracticeShowState.all;

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
    late UserData fencer;
    List<Practice> practices = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        if (month.attendances.first.userData.id == fencer.id) {
          attendances.addAll(month.attendances);
        }
      }
      practices
          .retainWhere((p) => p.team == fencer.team || p.team == Team.both);
      practices.sort((a, b) => -a.startTime.compareTo(b.startTime));

      List<List<Practice>> practiceLists = [
        practices,
        getShownPractices(practices, attendances, PracticeShowState.attended),
        getShownPractices(practices, attendances, PracticeShowState.excused),
        getShownPractices(practices, attendances, PracticeShowState.unexcused),
        getShownPractices(practices, attendances, PracticeShowState.noReason),
      ];

      return DefaultTabController(
        length: PracticeShowState.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(fencer.fullName),
                    if (fencer.rating.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(fencer.rating),
                    ],
                  ],
                ),
                if (fencer.club.isNotEmpty) ...[
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        fencer.club,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (fencer.clubDays.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          "(${fencer.clubDays.map((e) => e.abbreviation).join(",")})",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
            bottom: TabBar(
              isScrollable: true,
              onTap: (int index) => setState(
                () => practiceShowState = PracticeShowState.values[index],
              ),
              tabs: List.generate(
                PracticeShowState.values.length,
                (index) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(PracticeShowState.values[index].type),
                      const SizedBox(width: 8),
                      TextBadge(text: practiceLists[index].length.toString()),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AccountSetupPage(
                        user: ref.watch(authStateChangesProvider).value!,
                        userData: fencer,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
          body: TabBarView(
            children: List.generate(
              practiceLists.length,
              (index) => ListView.separated(
                padding: const EdgeInsets.only(bottom: 60),
                itemCount: practiceLists[index].length,
                itemBuilder: (context, i) {
                  Practice practice = practiceLists[index][i];

                  Attendance attendance = attendances.firstWhere(
                    (element) => element.id == practice.id,
                    orElse: () => Attendance.create(practice, fencer),
                  );
                  bool isToday = practice.startTime.isToday;

                  return ListTile(
                    tileColor: isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isToday)
                          TextBadge(text: "Today's ${practice.type.type}"),
                        Text(practice.startString),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${practice.type.type} - ${practice.location}"),
                        Text(
                            "${attendance.wasLate ? "Arrived Late" : ""}${attendance.wasLate && attendance.leftEarly ? " | " : " "}${attendance.leftEarly ? "Left Early" : ""}"),
                      ],
                    ),
                    trailing: Icon(
                      attendance.attended
                          ? Icons.check
                          : attendance.excusedAbsense
                              ? Icons.admin_panel_settings
                              : attendance.unexcusedAbsense
                                  ? Icons.cancel
                                  : Icons.question_mark,
                      color: attendance.attended
                          ? Colors.green
                          : attendance.excusedAbsense
                              ? Colors.amber
                              : attendance.unexcusedAbsense
                                  ? Colors.red
                                  : Colors.purple,
                    ),
                    onTap: () => context.router.push(
                      EditFencerStatusRoute(
                        fencer: fencer,
                        practice: practice,
                        attendance: attendance,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ),
        ),
      );
    }

    Widget whenFencerData(List<UserData> data) {
      fencer = data.firstWhere((fencer) => fencer.id == widget.fencerID);
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    Widget whenPracticeData(List<PracticeMonth> data) {
      practices = [];
      for (var month in data) {
        practices.addAll(month.practices);
      }
      return ref.watch(fencersProvider).when(
            data: whenFencerData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    return ref.watch(practicesProvider).when(
          data: whenPracticeData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}

List<Practice> getShownPractices(List<Practice> practices,
    List<Attendance> attendances, PracticeShowState practiceShowState) {
  return practices.where((p) {
    switch (practiceShowState) {
      case PracticeShowState.all:
        return true;
      case PracticeShowState.attended:
        return attendances.any((a) => p.id == a.id && a.attended);
      case PracticeShowState.excused:
        return attendances.any((a) => p.id == a.id && a.excusedAbsense);
      case PracticeShowState.unexcused:
        return attendances.any((a) => p.id == a.id && a.unexcusedAbsense);
      case PracticeShowState.noReason:
        return !attendances.any((a) =>
            p.id == a.id &&
            (a.attended || a.excusedAbsense || a.unexcusedAbsense));
    }
  }).toList();
}
