import 'package:flutter/material.dart';

import 'package:lhs_fencing/src/models/practice.dart';

class PracticeInfo extends StatelessWidget {
  final Practice practice;
  final int presentFencers;
  final int absentFencers;
  final int comments;
  const PracticeInfo(
      this.practice, this.presentFencers, this.absentFencers, this.comments,
      {super.key});

  @override
  Widget build(BuildContext context) {
    String status = practice.tooSoonForCheckIn
        ? "Status: Too Early to Check In"
        : "Attendance: $presentFencers Checked In • $absentFencers Absent";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(status),
        Text(
          "Tap to view or add comments ($comments)",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
