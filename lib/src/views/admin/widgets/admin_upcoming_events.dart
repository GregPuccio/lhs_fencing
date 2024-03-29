import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class AdminUpcomingEvents extends StatelessWidget {
  final List<Practice> practices;
  final void Function(int) updateIndexFn;
  const AdminUpcomingEvents({
    required this.practices,
    super.key,
    required this.updateIndexFn,
  });

  @override
  Widget build(BuildContext context) {
    practices.sort((a, b) => a.startTime.compareTo(b.startTime));
    int tileNumber = (practices.length > 7 ? 7 : practices.length) + 1;
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

        Practice practice = practices[index];

        return Column(
          children: [
            ListTile(
              title: Wrap(
                children: [
                  TextBadge(text: practice.team.type),
                  const SizedBox(width: 8),
                  Text(practice.type.type),
                  const Text(" | "),
                  Text(practice.timeframe),
                ],
              ),
              subtitle: Text("${practice.runTime}\n${practice.location}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(
                PracticeRoute(practiceID: practice.id),
              ),
            ),
            const Divider(),
          ],
        );
      }),
    );
  }
}
