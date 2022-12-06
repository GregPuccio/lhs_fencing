import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class TodaysAttendance extends ConsumerWidget {
  final List<Attendance> attendances;
  const TodaysAttendance({required this.attendances, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenData(List<PracticeMonth> practiceMonths) {
      if (practiceMonths.isEmpty) {
        return const LoadingTile();
      }
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      DateTime now = DateTime.now();
      final todaysPractice = practices.reduce((a, b) =>
          a.startTime.difference(now).abs() <
                      b.startTime.difference(now).abs() &&
                  a.startTime.isAfter(DateTime.now())
              ? a
              : b);
      final todaysAttendance = attendances.firstWhere(
        (a) => a.practiceStart == todaysPractice.startTime,
        orElse: () => Attendance.noUserCreate(todaysPractice),
      );
      bool attendedToday = todaysAttendance.userData.id.isNotEmpty;

      String checkedIn = DateFormat('h:mm aa').format(todaysAttendance.checkIn);
      String? checkedOut = todaysAttendance.checkOut != null
          ? DateFormat('h:mm aa').format(todaysAttendance.checkOut!)
          : null;
      DateTime closestDateTimeToNow = todaysPractice.startTime;
      String formattedDate =
          DateFormat('EEEE, MMMM d @ h:mm aa').format(closestDateTimeToNow);
      bool today = now.day == closestDateTimeToNow.day;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                today ? "Today's Practice" : "Next Practice",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              ListTile(
                title: Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
                subtitle: attendedToday
                    ? Text(
                        "Checked in: $checkedIn${todaysAttendance.lateReason.isNotEmpty ? "\n${todaysAttendance.lateReason}" : ""}${checkedOut != null ? "\nChecked out: $checkedOut" : ""}${todaysAttendance.earlyLeaveReason.isNotEmpty ? "\n${todaysAttendance.earlyLeaveReason}" : ""}")
                    : null,
                trailing: todaysAttendance.checkOut != null
                    ? null
                    : attendedToday
                        ? CheckOutButton(attendance: todaysAttendance)
                        : CheckInButton(today: today, practices: practices),
              ),
            ],
          ),
        ),
      );
    }

    return ref.watch(practicesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingTile(),
        );
  }
}
