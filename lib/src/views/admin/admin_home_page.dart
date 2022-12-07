import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_practice_type_bar.dart';
import 'package:lhs_fencing/src/views/admin/widgets/future_practices.dart';
import 'package:lhs_fencing/src/views/admin/widgets/no_practice_today.dart';
import 'package:lhs_fencing/src/views/admin/widgets/past_practices.dart';
import 'package:lhs_fencing/src/views/admin/widgets/todays_practice.dart';
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

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      int currentPracticeIndex = practices.indexWhere((p) {
        DateTime startTime =
            DateTime(p.startTime.year, p.startTime.month, p.startTime.day);
        return startTime.isAtSameMomentAs(today);
      });

      Practice? currentPractice;
      if (currentPracticeIndex != -1) {
        currentPractice = practices[currentPracticeIndex];
      }

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
                      if (currentPractice != null)
                        TodaysPractice(currentPractice: currentPractice)
                      else
                        const NoPracticeToday(),
                    ],
                  ),
                ),
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: PracticeTypeTabBar(),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                PastPractices(practices: practices),
                FuturePractices(practices: practices),
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
