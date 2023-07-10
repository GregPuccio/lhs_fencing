import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/activities.dart';

import 'package:lhs_fencing/src/models/practice.dart';

class TodaysSchedule extends ConsumerWidget {
  final Practice practice;
  const TodaysSchedule({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool todayBool = DateTime.now().day == practice.startTime.day;
    Map<DateTime, String> activities = Activities(practice).activities;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            "${todayBool ? "Today's" : "${DateFormat("EEEE").format(practice.startTime)}'s"} ${practice.type.type} Schedule",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
