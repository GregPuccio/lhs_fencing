import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

class CheckInButton extends ConsumerWidget {
  final bool today;
  final List<Practice> practices;

  const CheckInButton({
    Key? key,
    required this.today,
    required this.practices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkIn(Practice practice, {String? lateReason}) async {
      UserData userData = ref.read(userDataProvider).asData!.value!;
      List<AttendanceMonth> months =
          ref.read(attendancesProvider).asData!.value;

      return await addAttendance(
        userData.id,
        months,
        Attendance.create(practice, userData).copyWith(
          comments: [
            if (lateReason != null)
              Comment.create(userData).copyWith(text: lateReason)
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: today
          ? () {
              DateTime now = DateTime.now();
              final todaysPractice = practices.reduce((a, b) =>
                  a.startTime.difference(now).abs() <
                          b.startTime.difference(now).abs()
                      ? a
                      : b);
              // if we are too early to check in (more than 15 minutes before practice)
              if (now.isBefore(todaysPractice.startTime
                  .subtract(const Duration(minutes: 15)))) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Too Early For Check In"),
                    content: const Text(
                        "You cannot check in for attendance before practice has started. Make sure it is time for practice before you try checking in again."),
                    actions: [
                      TextButton(
                        onPressed: () => context.popRoute(),
                        child: const Text(
                          "Understood",
                        ),
                      ),
                    ],
                  ),
                );
              }
              // if we are within 15 minutes of starting
              // (since we didnt get caught at the previous if)
              // and have not ended practice yet
              else if (now.isBefore(todaysPractice.endTime)) {
                // if the student is later than 15 minutes to practice
                if (now.isAfter(todaysPractice.startTime
                    .add(const Duration(minutes: 15)))) {
                  TextEditingController controller = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Late Practice Check In"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                                "Please note that you are late to practice and must provide a reason."),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              minLines: 3,
                              maxLines: 5,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                "Please only check in when you are at practice. Are you currently in the fencing gym?"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.popRoute(),
                          child: const Text("No, cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await checkIn(
                              todaysPractice,
                              lateReason: controller.text.isNotEmpty
                                  ? "Late: ${controller.text}"
                                  : null,
                            );
                            context.router.pop();
                          },
                          child: const Text("Yes, check in"),
                        ),
                      ],
                    ),
                  );
                }
                // if they are on time for practice check in
                else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Check In To Practice"),
                      content: const Text(
                          "Please only check in when you are at practice. Are you currently in the fencing gym?"),
                      actions: [
                        TextButton(
                          onPressed: () => context.popRoute(),
                          child: const Text("No, cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await checkIn(todaysPractice);

                            context.router.pop();
                          },
                          child: const Text("Yes, check in"),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Too Late For Check In"),
                    content: const Text(
                        "You cannot check in after practice has ended. Make sure to let a coach know that you attended practice and try not to forget again in the future."),
                    actions: [
                      TextButton(
                        onPressed: () => context.popRoute(),
                        child: const Text(
                          "Understood",
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          : null,
      icon: const Icon(Icons.check),
      label: const Text("Check In"),
    );
  }
}
