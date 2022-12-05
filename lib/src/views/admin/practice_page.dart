import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/firestore/streams.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class PracticePage extends ConsumerWidget {
  final Practice practice;
  const PracticePage({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(practice.startString)),
      body: StreamBuilder<List<Attendance>>(
        stream: FirestoreStreams().practiceAttendances(practice.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Attendance> attendances = snapshot.data!;
            return ListView.separated(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                Attendance attendance = attendances[index];
                String checkedIn =
                    DateFormat('h:mm aa').format(attendance.checkIn);
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
            );
          } else {
            return const LoadingPage();
          }
        },
      ),
    );
  }
}
