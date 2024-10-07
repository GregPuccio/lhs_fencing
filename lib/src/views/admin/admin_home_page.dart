import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_upcoming_events.dart';
import 'package:lhs_fencing/src/views/admin/widgets/no_practice_today.dart';
import 'package:lhs_fencing/src/views/admin/widgets/todays_practice.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  final void Function(int) updateIndexFn;
  const AdminHomePage({super.key, required this.updateIndexFn});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int currentIndex = 0;

  void updateIndex(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<PracticeMonth> practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      Practice? currentPractice;
      if (practices.any(
        (p) => p.endTime.isAfter(
          DateTime.now().subtract(
            const Duration(hours: 2),
          ),
        ),
      )) {
        List<Practice> futurePractices = practices
            .where((p) => p.endTime.isAfter(DateTime.now().subtract(
                  const Duration(hours: 2),
                )))
            .toList();
        currentPractice = futurePractices
            .reduce((a, b) => a.startTime.isBefore(b.startTime) ? a : b);
      }

      List<Practice> upcomingPractices = practices
          .where((prac) => prac.startTime.isAfter(DateTime.now()))
          .toList();
      upcomingPractices.removeWhere((prac) => prac.id == currentPractice?.id);

      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(bottom: 75),
          children: [
            const WelcomeHeader(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Fencer List"),
              subtitle: const Text("View fencers and their participation info"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const FencerListRoute()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.accessibility_new),
              title: const Text("Borrowed Equipment List"),
              subtitle: const Text(
                  "View and edit the equipment fencers have borrowed"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const EquipmentListRoute()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Bout List"),
              subtitle:
                  const Text("View, add or edit bout records for fencers"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const BoutHistoryRoute()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Drills List"),
              subtitle: const Text("View all drills from footwork to bouting"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const DrillsListRoute()),
            ),
            // const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.event),
            //   title: const Text("Meets and Tournaments List"),
            //   subtitle: const Text("View all upcoming meets and tournaments"),
            //   trailing: const Icon(Icons.arrow_forward),
            //   onTap: () => context.router.push(EventsListRoute()),
            // ),
            // ListTile(
            //   title: const Text("Tap Here"),
            //   onTap: () => getCurrentBoysStats(context),
            // ),
            const Divider(),
            if (currentPractice != null)
              TodaysPractice(
                currentPractice: currentPractice,
              )
            else
              const NoPracticeToday(),
            const Divider(),
            AdminUpcomingEvents(
              practices: upcomingPractices,
              updateIndexFn: widget.updateIndexFn,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "HomeFAB",
          onPressed: () => context.pushRoute(AddPracticesRoute()),
          child: const Icon(Icons.add),
        ),
      );
    }

    return ref.watch(practicesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
