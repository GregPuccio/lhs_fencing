import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/streams.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class FencerListPage extends ConsumerWidget {
  const FencerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fencer List"),
      ),
      body: StreamBuilder<List<UserData>>(
        stream: FirestoreStreams().fencerList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<UserData> fencers = snapshot.data!;
            return ListView.separated(
              itemCount: fencers.length,
              itemBuilder: (context, index) {
                UserData fencer = fencers[index];
                return StreamBuilder<List<AttendanceMonth>>(
                  stream: FirestoreStreams().previousAttendances(fencer.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<AttendanceMonth> months = snapshot.data!;
                      List<Attendance> attendances = [];
                      for (var month in months) {
                        attendances.addAll(month.attendances);
                      }
                      return ListTile(
                        title: Text(fencer.fullName),
                        subtitle: Text(
                            "Participated in ${attendances.length} practices"),
                      );
                    } else {
                      return const LoadingTile();
                    }
                  },
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
