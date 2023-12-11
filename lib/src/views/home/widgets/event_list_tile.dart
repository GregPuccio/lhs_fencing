import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';

import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class EventListTile extends ConsumerWidget {
  final Practice practice;
  final Attendance attendance;
  const EventListTile(
      {required this.practice, required this.attendance, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              TextBadge(text: practice.team.type),
              const SizedBox(width: 8),
              Text("${practice.type.type} | ${practice.timeframe}"),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${practice.runTime}\n${practice.location}"),
              AttendanceInfo(attendance),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () =>
              context.router.push(AttendanceRoute(practiceID: attendance.id)),
        ),
      ],
    );
  }
}
