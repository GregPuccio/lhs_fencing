import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class PracticePage extends ConsumerWidget {
  final Practice practice;
  const PracticePage({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      return Scaffold(
        appBar: AppBar(
          title: Text(practice.startString),
        ),
        body: ListView.separated(
          itemCount: attendances.length,
          itemBuilder: (context, index) {
            Attendance attendance = attendances[index];
            String checkedIn = DateFormat('h:mm aa').format(attendance.checkIn);
            String? checkedOut = attendance.checkOut != null
                ? DateFormat('h:mm aa').format(attendance.checkOut!)
                : null;
            return ListTile(
              title: Text(attendance.userData.fullName),
              subtitle: Text(
                  "Checked in: $checkedIn${attendance.lateReason.isNotEmpty ? "\n${attendance.lateReason}" : ""}${checkedOut != null ? "\nChecked out: $checkedOut" : ""}${attendance.earlyLeaveReason.isNotEmpty ? "\n${attendance.earlyLeaveReason}" : ""}"),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
    }

    return ref.watch(allAttendancesProvider).when(
        data: whenData,
        error: (error, stackTrace) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}
