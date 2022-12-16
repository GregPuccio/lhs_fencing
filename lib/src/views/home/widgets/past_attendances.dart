import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';
import 'package:lhs_fencing/src/widgets/attendance_status_bar.dart';
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
    practices.sort((a, b) => -a.startTime.compareTo(b.startTime));

    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      return CustomScrollView(
        key: const PageStorageKey<String>("past"),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 60),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Practice practice = practices[index];
                  Attendance attendance = attendances.firstWhere(
                    (element) => element.id == practice.id,
                    orElse: () => Attendance.noUserCreate(practice),
                  );
                  return Column(
                    children: [
                      if (index == 0 &&
                          (attendance.isLate || attendance.leftEarly))
                        const SizedBox(height: 8),
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AttendanceStatusBar(attendance),
                            Text(practice.startString),
                          ],
                        ),
                        subtitle: AttendanceInfo(attendance, practice),
                        onTap: () {
                          context.router.push(
                            AttendanceRoute(practiceID: attendance.id),
                          );
                        },
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
                      ),
                      if (index != practices.length - 1) const Divider(),
                    ],
                  );
                },
                childCount: practices.length,
              ),
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
