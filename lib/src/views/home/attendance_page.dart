import 'package:auto_route/auto_route.dart';
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
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class AttendancePage extends ConsumerStatefulWidget {
  final String practiceID;
  const AttendancePage(
      {@PathParam('practiceID') required this.practiceID, super.key});

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
    UserData? userData = ref.watch(userDataProvider).asData?.value;
    if (userData == null) {
      return const CircularProgressIndicator.adaptive();
    }
    late Practice practice;
    Widget whenData(List<AttendanceMonth> months) {
      bool todayBool = DateTime.now().day == practice.startTime.day;
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
      attendance.comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(125),
          child: AppBar(
            title: Text(attendance.practiceStartString),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: ListTile(
                title: Text(practice.type.type),
                subtitle: Text(attendance.attendanceStatus),
                trailing: attendance.checkOut != null
                    ? null
                    : attendance.attended
                        ? CheckOutButton(
                            attendance: attendance,
                            practice: practice,
                          )
                        : CheckInButton(today: todayBool, practice: practice),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Flexible(
              child: ListView.separated(
                reverse: true,
                itemCount: attendance.comments.length,
                itemBuilder: (context, index) {
                  Comment comment = attendance.comments[index];
                  bool fencerComment = comment.user.id == userData.id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: fencerComment
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                      child: Text(
                        attendance.userData.initials,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                    title: Text(comment.text),
                    subtitle: Text(comment.createdAtString),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: Theme.of(context).colorScheme.primaryContainer),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      userData.initials,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Add a comment",
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
              ),
            ),
          ],
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
          loading: () => const LoadingPage(),
        );
  }
}
