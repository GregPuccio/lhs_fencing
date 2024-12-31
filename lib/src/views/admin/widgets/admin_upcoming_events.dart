import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_event_list_tile.dart';
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
  // Data lists to store attendance and fencer information.
  List<Attendance> attendances = [];
  List<UserData> fencers = [];

  @override
  Widget build(BuildContext context) {
    // Widget to handle data from practicesProvider.
    Widget whenData(List<PracticeMonth> practiceMonths) {
      // Gather practices from the fetched months and filter out past events.
      List<Practice> practices =
          practiceMonths.expand((month) => month.practices).toList();

      practices.removeWhere((e) => e.endTime.isBefore(DateTime(0).today));

      // Sort practices by start time.
      practices.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Identify currently ongoing practices.
      List<Practice> currentPractices = practices
          .where((e) =>
              e.startTime
                  .isBefore(DateTime.now().add(const Duration(hours: 6))) &&
              e.endTime
                  .isAfter(DateTime.now().subtract(const Duration(hours: 1))))
          .toList();

      // Remove current practices from the general list to avoid duplication.
      practices.removeWhere((p) => currentPractices.any((c) => c.id == p.id));

      // Calculate the number of tiles to display.
      int numTiles = (practices.length > 7 ? 7 : practices.length) +
          (currentPractices.isNotEmpty ? 1 : 0) +
          1; // +1 for the "View All Events" tile.

      return Column(
        children: List.generate(numTiles, (index) {
          // Display ongoing practices in a separate card.
          if (currentPractices.isNotEmpty && index == 0) {
            return Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "In Progress Events:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Column(
                    children: List.generate(currentPractices.length, (i) {
                      Practice practice = currentPractices[i];
                      return Card(
                        child: AdminEventListTile(
                          attendances: attendances,
                          practice: practice,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }

          // Display "View All Events" tile at the end.
          if (index == numTiles - 1) {
            return ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text("View All Events"),
              subtitle: const Text("Tap here to go to the calendar"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => widget.updateIndexFn(1),
            );
          }

          // Display upcoming practices.
          Practice practice =
              practices[index + (currentPractices.isNotEmpty ? -1 : 0)];
          // Filter the attendances relevant to the current practice
          final attendanceList = attendances
              .where((attendance) => attendance.id == practice.id)
              .toList();

          final int fencerComments =
              attendanceList.expand((a) => a.comments).length;

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
                subtitle: Text(
                    "${practice.runTime}\n${practice.location}\n${fencerComments != 0 ? "Comments: $fencerComments" : ""}"),
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

    // Process attendance data and forward it to whenData.
    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      attendances =
          attendanceMonths.expand((month) => month.attendances).toList();
      return ref.watch(thisSeasonPracticesProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    // Process fencer data and forward it to whenAttendanceData.
    Widget whenFencerData(List<UserData> fencerList) {
      fencers = fencerList.where((fencer) => fencer.active).toList();
      return ref.watch(thisSeasonAttendancesProvider).when(
            data: whenAttendanceData,
            error: (error, stackTrace) => const ErrorTile(),
            loading: () => const LoadingTile(),
          );
    }

    // Watch fencersProvider and start the data processing pipeline.
    return ref.watch(thisSeasonFencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorTile(),
          loading: () => const LoadingTile(),
        );
  }
}
