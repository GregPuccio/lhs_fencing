import 'package:flutter/material.dart';

import 'package:lhs_fencing/src/models/attendance.dart';

class AttendanceInfo extends StatelessWidget {
  final Attendance attendance;
  const AttendanceInfo(this.attendance, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(attendance.attendanceStatus),
        if (attendance.comments.isNotEmpty)
          Text(
            "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
