import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/admin/admin_home_page.dart';
import 'package:lhs_fencing/src/views/calendar/calendar_page.dart';
import 'package:lhs_fencing/src/views/profile/profile_page.dart';
import 'package:lhs_fencing/src/views/useful_links/useful_links.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminHomeStructure extends ConsumerStatefulWidget {
  const AdminHomeStructure({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeStructureState();
}

class _HomeStructureState extends ConsumerState<AdminHomeStructure> {
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
        appBar: DefaultAppBar(currentIndex: currentIndex),
        body: IndexedStack(
          index: currentIndex,
          children: [
            const AdminHomePage(),
            CalendarPage(
              practicesByDay: practicesByDay,
              attendances: attendances,
            ),
            const UsefulLinks(),
            ProfilePage(
              userData: userData,
              attendances: attendances,
              practices: practices,
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              bottom: kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                  ? 20
                  : 0),
          child: BottomNavigationBar(
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
                icon: Icon(Icons.link),
                label: "Useful Links",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
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
