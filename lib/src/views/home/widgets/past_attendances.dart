import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class PastAttendances extends ConsumerWidget {
  const PastAttendances({
    Key? key,
    required this.practices,
  }) : super(key: key);

  final List<Practice> practices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Practice> pastPractices =
        practices.where((p) => p.endTime.isBefore(DateTime.now())).toList();
    pastPractices.sort((a, b) => -a.startTime.compareTo(b.startTime));

    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      return CustomScrollView(
        key: const PageStorageKey<String>("past"),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Practice practice = pastPractices[index];
                List<Attendance> attendances = [];
                for (var month in attendanceMonths) {
                  for (var attendance in month.attendances) {
                    if (attendance.id == practice.id) {
                      attendances.add(attendance);
                    }
                  }
                }
                Attendance attendance = attendances.firstWhere(
                  (element) => element.id == practice.id,
                  orElse: () => Attendance.noUserCreate(practice),
                );
                bool attendedToday = attendance.userData.id.isNotEmpty;
                return Column(
                  children: [
                    ListTile(
                      title: Text(practice.startString),
                      subtitle: attendedToday
                          ? Text(attendance.info)
                          : const Text("Did not check in"),
                    ),
                    if (index != pastPractices.length - 1) const Divider(),
                  ],
                );
              },
              childCount: pastPractices.length,
            ),
          ),
        ],
      );
    }

    return ref.watch(attendancesProvider).when(
        data: whenData,
        error: (error, stackTrace) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}
