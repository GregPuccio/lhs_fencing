import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;
  late UserData userData;
  List<Practice> practices = [];

  @override
  Widget build(BuildContext context) {
    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      attendances.sort((a, b) => a.checkIn.compareTo(b.checkIn));

      return Scaffold(
        appBar: const DefaultAppBar(),
        body: ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: practices.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  const WelcomeHeader(),
                  const Divider(),
                  const Instructions(),
                  const Divider(),
                  TodaysAttendance(attendances: attendances),
                  const Divider(),
                  Text(
                    "Previous Practices",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (practices.isEmpty)
                    Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "No Practices Found",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                ],
              );
            } else {
              index--;
              Practice practice = practices[index];
              Attendance attendance = attendances.firstWhere(
                (element) => element.id == practice.id,
                orElse: () => Attendance.noUserCreate(practice),
              );
              bool attendedToday = attendance.userData.id.isNotEmpty;
              return ListTile(
                title: Text(practice.startString),
                subtitle: attendedToday
                    ? Text(attendance.info)
                    : const Text("Did not check in"),
              );
            }
          },
          separatorBuilder: (context, index) =>
              index == 0 ? Container() : const Divider(),
        ),
      );
    }

    Widget whenPracticeData(List<PracticeMonth> practiceMonths) {
      practices.clear();
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      practices =
          practices.where((p) => p.endTime.isBefore(DateTime.now())).toList();
      practices.sort((a, b) => -a.startTime.compareTo(b.startTime));
      return ref.watch(attendancesProvider).when(
            data: whenAttendanceData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    Widget whenData(UserData? data) {
      if (data != null) {
        userData = data;
        return ref.watch(practicesProvider).when(
              data: whenPracticeData,
              error: (error, stackTrace) => const ErrorPage(),
              loading: () => const LoadingPage(),
            );
      } else {
        return const LoadingPage();
      }
    }

    return ref.watch(userDataProvider).when(
        data: whenData,
        error: (error, stackTrace) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}
