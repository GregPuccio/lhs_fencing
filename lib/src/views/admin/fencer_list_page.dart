import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/streams.dart';
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
    Widget whenData(List<UserData> fencers) {
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
                    return const LoadingTile(text: "Loading Fencer");
                  }
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
    }

    return ref.watch(fencersProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
