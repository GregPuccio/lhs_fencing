import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';

class UpcomingEvents extends StatelessWidget {
  final List<Practice> practices;
  const UpcomingEvents({required this.practices, super.key});

  @override
  Widget build(BuildContext context) {
    List<Practice> upcomingPractices = practices
        .where((prac) => prac.startTime.isAfter(DateTime.now()))
        .toList();
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
              SizedBox(
                height: 100,
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingPractices.length > 7
                        ? 7
                        : upcomingPractices.length,
                    itemBuilder: (context, index) {
                      Practice practice = upcomingPractices[index];
                      return Row(
                        children: [
                          Ink(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer),
                            width: 175,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => context.router.push(
                                  AttendanceRoute(practiceID: practice.id)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    practice.startTime.isToday
                                        ? "Today"
                                        : practice.startTime.isTomorrow
                                            ? "Tomorrow"
                                            : practice.startTime.isThisWeek
                                                ? DateFormat("EEEE")
                                                    .format(practice.startTime)
                                                : DateFormat("EEE M/d")
                                                    .format(practice.startTime),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(practice.type.type),
                                  Text(
                                    "${DateFormat("hh:mm aa").format(practice.startTime)} - ${DateFormat("hh:mm aa").format(practice.endTime)}",
                                  ),
                                  Text(practice.location),
                                ],
                              ),
                            ),
                          ),
                          const VerticalDivider(),
                        ],
                      );
                    }),
              ),
            ],
          );
  }
}
