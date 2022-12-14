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
    practices.sort((a, b) => a.startTime.compareTo(b.startTime));

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
                      ListTile(
                        title: Text(practice.startString),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(practice.type.type),
                            if (attendance.comments.isNotEmpty)
                              Text(
                                "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
                              ),
                          ],
                        ),
                        onTap: () => context.router.push(
                          AttendanceRoute(practiceID: attendance.id),
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
