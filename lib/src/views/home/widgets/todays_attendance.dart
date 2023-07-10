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
import 'package:lhs_fencing/src/models/activities.dart';

class TodaysAttendance extends ConsumerWidget {
  final Attendance todaysAttendance;
  final Practice practice;
  const TodaysAttendance(
      {required this.todaysAttendance, required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool todayBool = DateTime.now().day == practice.startTime.day;
    Map<DateTime, String> activities = Activities(practice).activities;

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              todayBool
                  ? "Today's ${practice.type.type} @ ${DateFormat("h:mm aa").format(practice.startTime)}"
                  : "Next: ${DateFormat("EEEE").format(practice.startTime)}'s ${practice.type.type}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              title: Text(DateFormat("MM/dd${todayBool ? "" : " @ h:mm aa"}")
                  .format(practice.startTime)),
              subtitle: AttendanceInfo(todaysAttendance),
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
            const Divider(),
            Text(
              "${practice.type.type} Schedule",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            DataTable(
              border: TableBorder.all(
                  color: Theme.of(context).colorScheme.onBackground),
              headingTextStyle: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "Time",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                      child: Text(
                    "Activity",
                    textAlign: TextAlign.center,
                  )),
                ),
              ],
              rows: List.generate(
                activities.length,
                (index) => DataRow(cells: [
                  DataCell(
                    Text(
                      DateFormat("hh:mm aa").format(
                        activities.keys.elementAt(index),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        activities.values.elementAt(index),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
