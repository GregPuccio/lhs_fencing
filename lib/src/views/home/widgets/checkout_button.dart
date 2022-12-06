import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

class CheckOutButton extends ConsumerWidget {
  final Attendance attendance;

  const CheckOutButton({
    Key? key,
    required this.attendance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkOut({String? earlyLeaveReason}) async {
      UserData userData = ref.read(userDataProvider).asData!.value!;
      List<AttendanceMonth> months =
          ref.read(attendancesProvider).asData!.value;

      return await updateAttendance(
        userData.id,
        months,
        attendance.copyWith(
          checkOut: DateTime.now(),
          earlyLeaveReason: earlyLeaveReason,
        ),
      );
    }

    DateTime now = DateTime.now();
    final practiceEnd = attendance.practiceEnd;
    return ElevatedButton(
      onPressed: () {
        DateTime now = DateTime.now();
        final practiceEnd = attendance.practiceEnd;
        // if we are too early to check in (more than 15 minutes before practice)
        if (now.isBefore(practiceEnd.subtract(const Duration(minutes: 15)))) {
          TextEditingController controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Leaving Practice Early"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Please note that you are leaving practive early and must provide a reason."),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      minLines: 3,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.popRoute(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await checkOut(earlyLeaveReason: controller.text);
                    context.router.pop();
                  },
                  child: const Text("Complete check out"),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Practice Check Out"),
              content: const Text(
                  "Thank you for letting us know when you leave! It makes it easier to keep track of everybody. See you next practice."),
              actions: [
                TextButton(
                  onPressed: () async {
                    await checkOut();
                    context.router.pop();
                  },
                  child: const Text(
                    "Bye!",
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: Text(
          now.isBefore(practiceEnd.subtract(const Duration(minutes: 15)))
              ? "Leaving Early?"
              : "Check Out"),
    );
  }
}
