import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/admin/events/event_information_page.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class EventsListPage extends ConsumerWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Practice> practices = [];
    List<PracticeMonth>? practiceMonths =
        ref.watch(practicesProvider).asData?.value.toList();
    if (practiceMonths != null) {
      practices.clear();
      for (var month in practiceMonths) {
        List<Practice> monthPractices = month.practices.toList();
        monthPractices.retainWhere((p) => p.type.hasScoring);
        practices.addAll(monthPractices);
      }
      practices.sort((a, b) => -a.startTime.compareTo(b.startTime));
      return Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
        ),
        body: EventList(practices: practices),
      );
    } else {
      return const LoadingPage();
    }
  }
}

class EventList extends StatelessWidget {
  final List<Practice> practices;

  const EventList({super.key, required this.practices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: practices.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(practices[index].type.type),
          subtitle: Text('Date: ${practices[index].startString}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EventInformationScreen(practice: practices[index]),
              ),
            );
          },
          trailing: const QuickActions(),
        );
      },
    );
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.directions_bus),
          onPressed: () {
            // Add code for setting bus status
            // You may show a modal or navigate to a screen for setting bus status
          },
        ),
        // Add more quick actions as needed
      ],
    );
  }
}
