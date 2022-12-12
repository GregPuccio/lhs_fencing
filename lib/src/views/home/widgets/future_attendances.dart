import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class FutureAttendances extends ConsumerWidget {
  const FutureAttendances({
    Key? key,
    required this.practices,
  }) : super(key: key);

  final List<Practice> practices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    List<Practice> futurePractices = practices
        .where((p) => p.startTime.isAfter(today.add(const Duration(hours: 24))))
        .toList();
    futurePractices.sort((a, b) => a.startTime.compareTo(b.startTime));
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      return CustomScrollView(
        key: const PageStorageKey<String>("future"),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Practice practice = futurePractices[index];
                Attendance attendance = attendances.firstWhere(
                  (element) => element.id == practice.id,
                  orElse: () => Attendance.noUserCreate(practice),
                );

                return Column(
                  children: [
                    ListTile(
                      title: Text(practice.emailDate),
                      subtitle: attendance.comments.isNotEmpty
                          ? Text(
                              "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
                            )
                          : null,
                      onTap: () => context.router.push(
                        AttendanceRoute(attendanceID: attendance.id),
                      ),
                    ),
                    if (index != futurePractices.length - 1) const Divider(),
                  ],
                );
              },
              childCount: futurePractices.length,
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
