import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<PracticeMonth> practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }

      return Scaffold(
        body: Column(
          children: [
            const WelcomeHeader(),
            const Divider(),
            ListTile(
              title: const Text("Fencer List"),
              subtitle:
                  const Text("View fencers and their number of practices"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const FencerListRoute()),
            ),
            const Divider(),
            ListTile(
              title: const Text("Drills List"),
              subtitle: const Text("View all drills from footwork to bouting"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(const DrillsListRoute()),
            ),
            const Divider(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushRoute(const AddPracticesRoute()),
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
