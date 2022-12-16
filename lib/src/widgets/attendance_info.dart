import 'package:flutter/material.dart';

import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class AttendanceInfo extends StatelessWidget {
  final Attendance attendance;
  final Practice? practice;
  const AttendanceInfo(this.attendance, this.practice, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        attendance.attended
            ? Text(
                "${practice != null ? "${practice!.type.type} | " : ""}${attendance.info}")
            : attendance.excusedAbsense
                ? Text(
                    "${practice != null ? "${practice!.type.type} | " : ""}Excused Absense")
                : Text(
                    "${practice != null ? "${practice!.type.type} | " : ""}Did not check in"),
        if (attendance.comments.isNotEmpty)
          Text(
            "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
            style: Theme.of(context).textTheme.caption,
          ),
      ],
    );
  }
}
