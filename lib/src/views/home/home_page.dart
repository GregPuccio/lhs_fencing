import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/admin/widgets/future_practices.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/views/home/widgets/past_attendances.dart';
import 'package:lhs_fencing/src/widgets/practice_type_tab_bar.dart';
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

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: const DefaultAppBar(),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: const [
                      WelcomeHeader(),
                      Divider(),
                      Instructions(),
                      Divider(),
                    ],
                  ),
                ),
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: FencerPracticeTypeTabBar(attendances),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                PastAttendances(practices: practices),
                FuturePractices(practices: practices),
              ],
            ),
          ),
        ),
      );
    }

    Widget whenPracticeData(List<PracticeMonth> practiceMonths) {
      practices.clear();
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
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
