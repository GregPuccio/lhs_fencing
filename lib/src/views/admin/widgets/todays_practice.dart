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

class TodaysPractice extends ConsumerWidget {
  const TodaysPractice({Key? key, required this.currentPractice})
      : super(key: key);

  final Practice currentPractice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<UserData> fencers = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == currentPractice.id) {
            attendances.add(attendance);
          }
        }
      }
      int presentFencers = fencers
          .where((fencer) => attendances
              .any((attendance) => attendance.userData.id == fencer.id))
          .length;
      int absentFencers = fencers
          .where((fencer) => !attendances
              .any((attendance) => attendance.userData.id == fencer.id))
          .length;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "Today's Practice",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              ListTile(
                title: Text(
                  currentPractice.startString,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                subtitle: Text(
                  "$presentFencers Checked In | $absentFencers Absent",
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.router.push(
                  PracticeRoute(practice: currentPractice),
                ),
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
          loading: () => const LoadingTile());
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingTile(),
        );
  }
}
