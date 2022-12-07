import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar.dart';

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
      if (controller.text.isNotEmpty) {
        fencers = fencers
            .where(
              (f) => f.fullName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
            )
            .toList();
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text("Fencer List"),
            bottom: SearchBar(controller),
          ),
          body: ListView.separated(
            itemCount: fencers.length,
            itemBuilder: (context, index) {
              UserData fencer = fencers[index];

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
