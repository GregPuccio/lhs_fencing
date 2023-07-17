import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/views/home/widgets/event_list_tile.dart';

class UpcomingEvents extends StatelessWidget {
  final List<Practice> practices;
  final List<Attendance> attendances;
  const UpcomingEvents({
    required this.practices,
    required this.attendances,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Practice> upcomingPractices = practices;
    // .where((prac) => prac.startTime.isAfter(DateTime.now()))
    // .toList();
    upcomingPractices.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcomingPractices.isEmpty
        ? Container()
        : Column(
            children: [
              Text(
                "Upcoming Events",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(
                    upcomingPractices.length > 7 ? 7 : upcomingPractices.length,
                    (index) {
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
              ),
            ],
          );
  }
}
