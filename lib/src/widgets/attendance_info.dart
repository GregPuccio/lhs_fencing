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
        attendance.attended
            ? Text(attendance.info)
            : const Text("Did not check in"),
        if (attendance.comments.isNotEmpty)
          Text(
            "View ${attendance.comments.length} comments",
            style: Theme.of(context).textTheme.caption,
          ),
      ],
    );
  }
}
