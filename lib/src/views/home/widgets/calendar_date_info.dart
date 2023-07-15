import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';

import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class CalendarDateInfo extends ConsumerWidget {
  final Practice practice;
  final Attendance attendance;
  const CalendarDateInfo(
      {required this.practice, required this.attendance, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Map<DateTime, String> activities = Activities(practice).activities;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                TextBadge(text: practice.team.type),
                const SizedBox(width: 8),
                Text(
                    "${DateFormat("MMM d").format(practice.startTime)} - ${practice.type.type}"),
              ],
            ),
            subtitle: AttendanceInfo(attendance),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () =>
                context.router.push(AttendanceRoute(practiceID: attendance.id)),
          ),
          // Text(
          //   "${DateFormat("EEEE").format(practice.startTime)}'s ${practice.type.type} Schedule",
          //   style: Theme.of(context).textTheme.titleLarge,
          // ),
        ],
      ),
    );
  }
}
