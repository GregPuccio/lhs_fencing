import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';

class TodaysAttendance extends ConsumerWidget {
  final List<Attendance> attendances;
  final Practice practice;
  const TodaysAttendance(
      {required this.attendances, required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool todayBool = DateTime.now().day == practice.startTime.day;
    final todaysAttendance = attendances.firstWhere(
      (a) => a.id == practice.id,
      orElse: () => Attendance.noUserCreate(practice),
    );

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              todayBool
                  ? "Today's ${practice.type.type}"
                  : "Next ${practice.type.type}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              title: Text(
                DateFormat("EEE, MMM d @ h:mm aa").format(practice.startTime),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                maxLines: 1,
              ),
              subtitle: AttendanceInfo(todaysAttendance, practice),
              trailing: todaysAttendance.checkOut != null
                  ? null
                  : todaysAttendance.attended
                      ? CheckOutButton(
                          attendance: todaysAttendance,
                          practice: practice,
                        )
                      : CheckInButton(today: todayBool, practice: practice),
              onTap: () => context.router
                  .push(AttendanceRoute(practiceID: todaysAttendance.id)),
            ),
          ],
        ),
      ),
    );
  }
}
