import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';

class TodaysAttendance extends ConsumerWidget {
  final Attendance todaysAttendance;
  final Practice practice;
  const TodaysAttendance(
      {required this.todaysAttendance, required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool inPast = DateTime.now().isAfter(practice.endTime);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: inPast
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "More Events TBA",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const ListTile(
                      title: Text(
                        "Looks like there are no more upcoming events!",
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        "If you think this is an error, please let Coach Greg know",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : InkWell(
              onTap: () => context.router
                  .push(AttendanceRoute(practiceID: todaysAttendance.id)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        practice.startTime.isToday
                            ? "Today's ${practice.type.type} @ ${DateFormat("h:mm aa").format(practice.startTime)}"
                            : "Next: ${practice.timeframe} - ${practice.type.type}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ListTile(
                        title: Text(practice.runTime),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(practice.location),
                            AttendanceInfo(todaysAttendance),
                          ],
                        ),
                        trailing: todaysAttendance.checkOut != null
                            ? null
                            : todaysAttendance.attended
                                ? CheckOutButton(
                                    attendance: todaysAttendance,
                                    practice: practice,
                                  )
                                : CheckInButton(practice: practice),
                        onTap: () => context.router.push(
                            AttendanceRoute(practiceID: todaysAttendance.id)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
