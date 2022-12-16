import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/practice_type_tab_bar.dart';
import 'package:lhs_fencing/src/views/admin/widgets/future_practices.dart';
import 'package:lhs_fencing/src/views/admin/widgets/past_practices.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
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

      Practice upcomingPractice = practices.reduce((a, b) {
        DateTime now = DateTime.now();
        if (a.endTime.add(const Duration(minutes: 15)).isAfter(now) &&
            b.endTime.add(const Duration(minutes: 15)).isAfter(now)) {
          return a.startTime.compareTo(b.startTime).isNegative ? a : b;
        } else if (a.endTime.add(const Duration(minutes: 15)).isAfter(now)) {
          return a;
        } else {
          return b;
        }
      });

      List<Practice> pastPractices =
          practices.where((p) => p.endTime.isBefore(DateTime.now())).toList();
      List<Practice> futurePractices =
          practices.where((p) => p.startTime.isAfter(DateTime.now())).toList();

      pastPractices.remove(upcomingPractice);
      futurePractices.remove(upcomingPractice);

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: const DefaultAppBar(),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const WelcomeHeader(),
                      const Divider(),
                      ListTile(
                        title: const Text("Fencer List"),
                        subtitle: const Text(
                            "View fencers and their number of practices"),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () =>
                            context.router.push(const FencerListRoute()),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: PracticeTypeTabBar(upcomingPractice),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                PastPractices(practices: pastPractices),
                FuturePractices(practices: futurePractices),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.pushRoute(const AddPracticesRoute()),
            child: const Icon(Icons.add),
          ),
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
