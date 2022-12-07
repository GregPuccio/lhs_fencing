import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class PracticePage extends ConsumerWidget {
  final Practice practice;
  const PracticePage({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<UserData> fencers = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == practice.id) {
            attendances.add(attendance);
          }
        }
      }
      attendances
          .sort((a, b) => a.userData.lastName.compareTo(b.userData.lastName));
      List<UserData> absentFencers = fencers
          .where((fencer) => !attendances
              .any((attendance) => attendance.userData.id == fencer.id))
          .toList();
      absentFencers.sort((a, b) => a.lastName.compareTo(b.lastName));

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(practice.startString),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Present"),
                Tab(text: "Not Present"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.separated(
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  Attendance attendance = attendances[index];

                  return ListTile(
                    title: Text(attendance.userData.fullName),
                    subtitle: Text(attendance.info),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
              ListView.separated(
                itemCount: absentFencers.length,
                itemBuilder: (context, index) {
                  UserData fencer = absentFencers[index];

                  return ListTile(
                    title: Text(fencer.fullName),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ],
          ),
        ),
      );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
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
