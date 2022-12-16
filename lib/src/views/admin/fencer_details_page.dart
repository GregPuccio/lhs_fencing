import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/boxed_info.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class FencerDetailsPage extends ConsumerStatefulWidget {
  final String fencerID;
  const FencerDetailsPage({required this.fencerID, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FencerDetailsPageState();
}

class _FencerDetailsPageState extends ConsumerState<FencerDetailsPage> {
  late TextEditingController controller;

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
      practices.sort((a, b) => a.startTime.compareTo(b.startTime));
      int numAttended = attendances
          .where((a) => practices.any((p) => p.id == a.id) && a.attended)
          .length;
      int numExcused = attendances
          .where((a) => practices.any((p) => p.id == a.id) && a.excusedAbsense)
          .length;
      int numAbsent = practices.length - numAttended - numExcused;

      return Scaffold(
          appBar: AppBar(
            title: Text("${fencer.fullName}'s Practices"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BoxedInfo(
                    value: practices.length.toString(),
                    title: "Total",
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  BoxedInfo(
                    value: numAttended.toString(),
                    title: "Attended",
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  BoxedInfo(
                    value: numExcused.toString(),
                    title: "Excused",
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  BoxedInfo(
                    value: numAbsent.toString(),
                    title: "Absent",
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                  ),
                ],
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.only(bottom: 60),
            itemCount: practices.length,
            itemBuilder: (context, index) {
              Practice practice = practices[index];

              Attendance attendance = attendances.firstWhere(
                (element) => element.id == practice.id,
                orElse: () => Attendance.create(practice, fencer),
              );

              return ListTile(
                title: Text(practice.startString),
                subtitle: Text(
                    "${attendance.isLate ? "Arrived Late" : ""}${attendance.isLate && attendance.leftEarly ? " | " : " "}${attendance.leftEarly ? "Left Early" : ""}"),
                trailing: Icon(
                  attendance.attended
                      ? Icons.check
                      : attendance.excusedAbsense
                          ? Icons.admin_panel_settings
                          : Icons.cancel,
                  color: attendance.attended
                      ? Colors.green
                      : attendance.excusedAbsense
                          ? Colors.amber
                          : Colors.red,
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
          ));
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
