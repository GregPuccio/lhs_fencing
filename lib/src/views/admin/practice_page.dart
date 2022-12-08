import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class PracticePage extends ConsumerWidget {
  final Practice practice;
  const PracticePage({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<UserData> fencers = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == practice.id) {
            attendances.add(attendance);
          }
        }
      }
      attendances
          .sort((a, b) => a.userData.lastName.compareTo(b.userData.lastName));
      List<UserData> absentFencers = fencers
          .where((fencer) => !attendances
              .any((attendance) => attendance.userData.id == fencer.id))
          .toList();
      absentFencers.sort((a, b) => a.lastName.compareTo(b.lastName));

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(practice.startString),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Present"),
                      const SizedBox(width: 8),
                      TextBadge(text: "${attendances.length}"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not Present"),
                      const SizedBox(width: 8),
                      TextBadge(text: "${absentFencers.length}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.separated(
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  Attendance attendance = attendances[index];

                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (attendance.lateReason.isNotEmpty) ...[
                              TextBadge(
                                text: "Late Arrival",
                                boxColor: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (attendance.earlyLeaveReason.isNotEmpty)
                              TextBadge(
                                text: "Early Leave",
                                boxColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                          ],
                        ),
                        Text(attendance.userData.fullName),
                      ],
                    ),
                    subtitle: Text(attendance.info),
                    trailing: TextButton.icon(
                      icon: const Text("Edit"),
                      label: const Icon(Icons.edit),
                      onPressed: () => context.router.push(
                        EditFencerStatusRoute(
                          fencer: attendance.userData,
                          practice: practice,
                          attendance: attendance,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
              ListView.separated(
                itemCount: absentFencers.length,
                itemBuilder: (context, index) {
                  UserData fencer = absentFencers[index];

                  return ListTile(
                    title: Text(fencer.fullName),
                    trailing: TextButton.icon(
                      icon: const Text("Edit"),
                      label: const Icon(Icons.edit),
                      onPressed: () => context.router.push(
                        EditFencerStatusRoute(
                          fencer: fencer,
                          practice: practice,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ],
          ),
        ),
      );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
