import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class TodaysAttendance extends ConsumerWidget {
  final List<Attendance> attendances;
  const TodaysAttendance({required this.attendances, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenData(List<PracticeMonth> practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      DateTime now = DateTime.now();
      final todaysPractice = practices.reduce((a, b) {
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
        (a) => a.practiceStart == todaysPractice.startTime,
        orElse: () => Attendance.noUserCreate(todaysPractice),
      );
      bool todayBool = now.day == todaysPractice.startTime.day;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                todayBool
                    ? "Today's ${todaysPractice.type.type}"
                    : "Next ${todaysPractice.type.type}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              ListTile(
                title: Text(
                  DateFormat("EEE, MMM d @ h:mm aa")
                      .format(todaysPractice.startTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                  maxLines: 1,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    todaysAttendance.attended
                        ? Text(todaysAttendance.info)
                        : todaysAttendance.excusedAbsense
                            ? const Text("Excused Absense")
                            : const Text("Did not check in"),
                    if (todaysAttendance.comments.isNotEmpty)
                      Text(
                        "View ${todaysAttendance.comments.length} comment${todaysAttendance.comments.length == 1 ? "" : "s"}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                  ],
                ),
                trailing: todaysAttendance.checkOut != null
                    ? null
                    : todaysAttendance.attended
                        ? CheckOutButton(
                            attendance: todaysAttendance,
                            practice: todaysPractice,
                          )
                        : CheckInButton(
                            today: todayBool, practice: todaysPractice),
                onTap: () => context.router
                    .push(AttendanceRoute(practiceID: todaysAttendance.id)),
              ),
            ],
          ),
        ),
      );
    }

    return ref.watch(practicesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingTile(),
        );
  }
}
