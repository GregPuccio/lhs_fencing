import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/calendar/calendar_page.dart';
import 'package:lhs_fencing/src/views/home/home_page.dart';
import 'package:lhs_fencing/src/views/profile/profile_page.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeStructure extends ConsumerStatefulWidget {
  const HomeStructure({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeStructureState();
}

class _HomeStructureState extends ConsumerState<HomeStructure> {
  int currentIndex = 0;
  late UserData userData;
  List<Practice> practices = [];
  late PageController controller;

  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }

      Practice upcomingPractice = practices.reduce((a, b) {
        DateTime now = DateTime.now();
        if (a.endTime.add(const Duration(minutes: 15)).isAfter(now) &&
            b.endTime.add(const Duration(minutes: 15)).isAfter(now)) {
          return a.startTime.compareTo(b.startTime).isNegative ? a : b;
        } else if (a.endTime.add(const Duration(minutes: 15)).isAfter(now)) {
          return a;
        } else {
          return b;
        }
      });

      final todaysAttendance = attendances.firstWhere(
        (a) => a.id == upcomingPractice.id,
        orElse: () => Attendance.noUserCreate(upcomingPractice),
      );

      LinkedHashMap<DateTime, List<Practice>> practicesByDay = LinkedHashMap(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      );
      for (var practice in practices) {
        DateTime practiceDay = DateTime(practice.startTime.year,
            practice.startTime.month, practice.startTime.day);
        List<Practice>? practices = practicesByDay[practiceDay];
        if (practices != null) {
          practices.add(practice);
        } else {
          practicesByDay.addAll({
            practiceDay: [practice]
          });
        }
      }

      return Scaffold(
        appBar: DefaultAppBar(showInstructions: currentIndex == 0),
        body: IndexedStack(
          index: currentIndex,
          children: [
            HomePage(
              todaysAttendance: todaysAttendance,
              upcomingPractice: upcomingPractice,
              attendances: attendances,
              practices: practices,
              userData: userData,
            ),
            CalendarPage(
              practicesByDay: practicesByDay,
              attendances: attendances,
            ),
            ProfilePage(
              userData: userData,
              attendances: attendances,
              practices: practices,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) => setState(() {
            currentIndex = value;
          }),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      );
    }

    Widget whenPracticeData(List<PracticeMonth> practiceMonths) {
      practices.clear();
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      practices
          .retainWhere((p) => p.team == Team.both || p.team == userData.team);
      practices.sort((a, b) => -a.startTime.compareTo(b.startTime));
      if (practices.isEmpty) {
        practices.add(Practice(
          id: "",
          location: "Livingston Aux Gym",
          startTime: DateTime.fromMillisecondsSinceEpoch(0),
          endTime: DateTime.fromMillisecondsSinceEpoch(0)
              .add(const Duration(minutes: 1)),
          type: TypePractice.fundraiser,
          team: Team.both,
        ));
      }
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
          loading: () => const LoadingPage(),
        );
  }
}
