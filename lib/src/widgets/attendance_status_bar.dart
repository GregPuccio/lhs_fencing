import 'package:flutter/material.dart';

import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class AttendanceStatusBar extends StatelessWidget {
  final Attendance attendance;
  const AttendanceStatusBar(this.attendance, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (attendance.wasLate) ...[
          const TextBadge(
            text: "Late Arrival",
          ),
          const SizedBox(width: 8),
        ],
        if (attendance.leftEarly)
          const TextBadge(
            text: "Early Leave",
          ),
      ],
    );
  }
}
