import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AttendancePage extends ConsumerStatefulWidget {
  final String practiceID;
  const AttendancePage({required this.practiceID, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
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
    UserData userData = ref.watch(userDataProvider).asData!.value!;
    late Practice practice;
    Widget whenData(List<AttendanceMonth> months) {
      List<Attendance> attendances = [];
      for (var month in months) {
        attendances.addAll(month.attendances);
      }
      Attendance attendance = attendances.firstWhere(
        (attendance) {
          return attendance.id == widget.practiceID;
        },
        orElse: () => Attendance.noUserCreate(practice),
      );
      attendance.comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return Scaffold(
        appBar: AppBar(
          title: Text(attendance.practiceStartString),
          bottom: attendance.info.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(38),
                  child: Center(child: Text(attendance.info)))
              : null,
        ),
        body: ListView.separated(
          itemCount: attendance.comments.length + 1,
          itemBuilder: (context, index) {
            if (index == attendance.comments.length) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(userData.initials),
                  ),
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      label: const Text("Add Comment"),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: controller.text.isEmpty
                            ? null
                            : () {
                                Comment comment = Comment.create(userData)
                                    .copyWith(text: controller.text);
                                attendance.comments.add(comment);

                                addAttendance(
                                  userData.id,
                                  months,
                                  attendance.copyWith(userData: userData),
                                );
                                controller.clear();
                              },
                      ),
                    ),
                  ),
                ),
              );
            } else {
              Comment comment = attendance.comments[index];
              bool fencerComment = comment.user.id == userData.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: fencerComment
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(attendance.userData.initials),
                ),
                title: Text(comment.text),
                subtitle: Text(comment.createdAtString),
              );
            }
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
    }

    Widget whenPracticeData(List<PracticeMonth> months) {
      List<Practice> practices = [];
      for (var month in months) {
        practices.addAll(month.practices);
      }
      practice = practices.firstWhere((p) => p.id == widget.practiceID);
      return ref.watch(attendancesProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(practicesProvider).when(
          data: whenPracticeData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingTile(),
        );
  }
}
