import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/views/home/widgets/event_list_tile.dart';

class UpcomingEvents extends StatelessWidget {
  final List<Practice> practices;
  final List<Attendance> attendances;
  final void Function(int) updateIndexFn;
  const UpcomingEvents({
    required this.practices,
    required this.attendances,
    required this.updateIndexFn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Practice> upcomingPractices = practices
        .where((prac) => prac.startTime.isAfter(DateTime.now()))
        .toList();
    upcomingPractices.sort((a, b) => a.startTime.compareTo(b.startTime));
    int tileNumber =
        (upcomingPractices.length > 7 ? 7 : upcomingPractices.length) + 1;
    return Column(
      children: List.generate(tileNumber, (index) {
        if (index == tileNumber - 1) {
          return ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("View All Events"),
            subtitle: const Text("Tap here to go to the calendar"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => updateIndexFn(1),
          );
        }

        Practice practice = upcomingPractices[index];
        Attendance attendance = attendances.firstWhere(
          (attendance) => attendance.id == practice.id,
          orElse: () => Attendance.noUserCreate(practice),
        );
        return Column(
          children: [
            EventListTile(practice: practice, attendance: attendance),
            const Divider(),
          ],
        );
      }),
    );
  }
}
