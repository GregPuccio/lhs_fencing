import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/practice_status.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class AdminUpcomingEvents extends ConsumerStatefulWidget {
  final void Function(int) updateIndexFn;
  const AdminUpcomingEvents({
    super.key,
    required this.updateIndexFn,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AdminUpcomingEventsState();
}

class _AdminUpcomingEventsState extends ConsumerState<AdminUpcomingEvents> {
  @override
  Widget build(BuildContext context) {
    List<Attendance> attendances = [];
    List<UserData> fencers = [];
    Widget whenData(practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
        practices.removeWhere((e) => e.endTime.isBefore(DateTime(0).today));
      }
      practices.sort((a, b) => a.startTime.compareTo(b.startTime));
      List<Practice> currentPractices = practices
          .where((e) =>
              e.startTime.isToday &&
              e.endTime
                  .isAfter(DateTime.now().subtract(const Duration(hours: 2))))
          .toList();
      practices.removeWhere((p) => currentPractices.any((c) => c.id == p.id));
      int numTiles = (practices.length > 7 ? 7 : practices.length) +
          (currentPractices.isNotEmpty ? 1 : 0) +
          1;

      return Column(
        children: List.generate(numTiles, (index) {
          if (currentPractices.isNotEmpty && index == 0) {
            return Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "Currently In Progress:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Column(
                    children: List.generate(
                      currentPractices.length,
                      (i) {
                        Practice practice = currentPractices[i];
                        List<Attendance> practiceAttendances = attendances
                            .where((a) => a.id == practice.id)
                            .toList();
                        int comments = 0;
                        for (var attendance in practiceAttendances) {
                          comments += attendance.comments.length;
                        }
                        int presentFencers = fencers
                            .where((fencer) => practiceAttendances.any(
                                (attendance) =>
                                    attendance.id == practice.id &&
                                    attendance.userData.id == fencer.id &&
                                    attendance.attended))
                            .length;
                        int absentFencers = fencers
                            .where((fencer) => !practiceAttendances.any(
                                (attendance) =>
                                    attendance.id == practice.id &&
                                    attendance.userData.id == fencer.id &&
                                    attendance.attended))
                            .length;
                        return Column(
                          children: [
                            ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextBadge(text: practice.team.type),
                                      const SizedBox(width: 8),
                                      Text(practice.type.type),
                                    ],
                                  ),
                                  Text(
                                      "${practice.runTime}\n${practice.location}"),
                                  PracticeInfo(practice, presentFencers,
                                      absentFencers, comments),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () => context.router.push(
                                PracticeRoute(practiceID: practice.id),
                              ),
                            ),
                            if (i != currentPractices.length - 1)
                              const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          if (index == numTiles - 1) {
            return ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("View All Events"),
              subtitle: const Text("Tap here to go to the calendar"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => widget.updateIndexFn(1),
            );
          }

          Practice practice =
              practices[index + (currentPractices.isNotEmpty ? -1 : 0)];
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
            ],
          );
        }),
      );
    }

    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      attendances.clear();
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }

      return ref.watch(practicesProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    Widget whenFencerData(List<UserData> fencerList) {
      fencers = fencerList.toList();
      fencers.retainWhere((fencer) => fencer.active);
      return ref.watch(allAttendancesProvider).when(
          data: whenAttendanceData,
          error: (error, stackTrace) => const ErrorTile(),
          loading: () => const LoadingTile());
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorTile(),
          loading: () => const LoadingTile(),
        );
  }
}
