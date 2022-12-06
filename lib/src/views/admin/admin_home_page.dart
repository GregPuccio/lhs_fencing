import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_practice_type_bar.dart';
import 'package:lhs_fencing/src/views/admin/widgets/no_practice_today.dart';
import 'package:lhs_fencing/src/views/admin/widgets/todays_practice.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:intl/intl.dart';
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
      List<Practice> pastPractices =
          practices.where((p) => p.endTime.isBefore(DateTime.now())).toList();
      pastPractices.sort((a, b) => -a.startTime.compareTo(b.startTime));

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      int currentPracticeIndex = practices.indexWhere((p) {
        DateTime startTime =
            DateTime(p.startTime.year, p.startTime.month, p.startTime.day);
        return startTime.isAtSameMomentAs(today);
      });

      Practice? currentPractice;
      String? formattedDate;
      if (currentPracticeIndex != -1) {
        currentPractice = practices[currentPracticeIndex];
        formattedDate = DateFormat('EEEE, MMMM d @ h:mm aa')
            .format(currentPractice.startTime);
      }

      List<Practice> futurePractices = practices
          .where(
            (p) => p.startTime.isAfter(
              today.add(
                const Duration(hours: 24),
              ),
            ),
          )
          .toList();
      futurePractices.sort((a, b) => a.startTime.compareTo(b.startTime));
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
                      if (currentPractice != null && formattedDate != null)
                        TodaysPractice(
                          formattedDate: formattedDate,
                          currentPractice: currentPractice,
                        )
                      else
                        const NoPracticeToday(),
                    ],
                  ),
                ),
                SliverPersistentHeader(delegate: PracticeTypeTabBar()),
              ];
            },
            body: TabBarView(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pastPractices.length + 1,
                  itemBuilder: (context, index) {
                    if (index == pastPractices.length) {
                      return OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Text("Sign Out"),
                        label: const Icon(Icons.logout),
                      );
                    } else {
                      index;
                      Practice practice = pastPractices[index];
                      String practiceStart =
                          DateFormat('EEEE, MMMM d @ h:mm aa')
                              .format(practice.startTime);

                      return ListTile(
                        title: Text(practiceStart),
                        onTap: () => context.router
                            .push(PracticeRoute(practice: practice)),
                      );
                    }
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
                ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: futurePractices.length + 1,
                  itemBuilder: (context, index) {
                    if (index == futurePractices.length) {
                      return OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Text("Sign Out"),
                        label: const Icon(Icons.logout),
                      );
                    } else {
                      index;
                      Practice practice = futurePractices[index];
                      String practiceStart =
                          DateFormat('EEEE, MMMM d @ h:mm aa')
                              .format(practice.startTime);
                      return ListTile(
                        title: Text(practiceStart),
                      );
                    }
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
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
