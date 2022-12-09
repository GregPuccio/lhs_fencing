import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class FencerListPage extends ConsumerStatefulWidget {
  const FencerListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FencerListPageState();
}

class _FencerListPageState extends ConsumerState<FencerListPage> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> fencers = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      List<UserData> filteredFencers = fencers.toList();
      if (controller.text.isNotEmpty) {
        filteredFencers = fencers
            .where(
              (f) => f.fullName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
            )
            .toList();
      }
      return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Fencer List"),
                const SizedBox(width: 8),
                TextBadge(text: "${fencers.length}"),
              ],
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.bug_report),
            //     onPressed: () {
            //       for (var fencer in fencers) {
            //         List<AttendanceMonth> months = attendanceMonths
            //             .where((element) =>
            //                 element.attendances.first.userData.id == fencer.id)
            //             .toList();
            //         for (int index = 0; index < months.length; index++) {
            //           FirestoreService.instance.updateData(
            //             path: FirestorePath.attendance(
            //                 fencer.id, months[index].id),
            //             data: months[index].toMap(),
            //           );
            //         }
            //       }
            //     },
            //   )
            // ],
            bottom: SearchBar(controller),
          ),
          body: ListView.separated(
            itemCount: filteredFencers.length,
            itemBuilder: (context, index) {
              UserData fencer = filteredFencers[index];

              List<Attendance> fencerAttendances = attendances
                  .where((att) => att.userData.id == fencer.id)
                  .toList();

              return ListTile(
                title: Text(fencer.fullName),
                subtitle: Text(
                    "Participated in ${fencerAttendances.length} practices"),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
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
