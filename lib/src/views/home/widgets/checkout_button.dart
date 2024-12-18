import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

/// A button that allows users to check out from a practice session
///
/// This widget handles different check-out scenarios:
/// 1. Regular check-out at or near practice end time
/// 2. Early check-out with a required reason
class CheckOutButton extends ConsumerWidget {
  /// The current attendance record
  final Attendance attendance;

  /// The practice session details
  final Practice practice;

  /// Constructor for the CheckOutButton
  const CheckOutButton({
    super.key,
    required this.attendance,
    required this.practice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Performs the check-out process
    ///
    /// [earlyLeaveReason] is an optional parameter for recording why
    /// a user is leaving early
    Future<void> checkOut({String? earlyLeaveReason}) async {
      // Retrieve current user data and attendance records
      UserData userData = ref.read(userDataProvider).value!;
      List<AttendanceMonth> months = ref.read(attendancesProvider).value!;

      // Update the attendance record with check-out time and optional comment
      return await updateAttendance(
        userData.id,
        months,
        attendance.copyWith(
          checkOut: DateTime.now(),
          comments: [
            if (earlyLeaveReason != null)
              Comment.create(userData).copyWith(text: earlyLeaveReason)
          ],
        ),
      );
    }

    // Only enable check-out button on the day of practice
    return ElevatedButton(
      onPressed: practice.endTime.isToday
          ? () {
              // Determine if the check-out is early (before 15 minutes before end time)
              // Check if the current time is more than 15 minutes before the practice end time

              // Get practice type for user-friendly messaging
              String practiceType = practice.type.type;

              if (practice.isLeavingEarly) {
                // Show dialog for early checkout with reason input
                _showEarlyCheckoutDialog(
                  context,
                  practiceType,
                  checkOut,
                );
              } else {
                // Show standard check-out confirmation dialog
                _showStandardCheckoutDialog(
                  context,
                  practiceType,
                  checkOut,
                );
              }
            }
          : null,
      child: Text(practice.isLeavingEarly ? "Leaving Early?" : "Check Out"),
    );
  }

  /// Displays a dialog for early checkout with reason input
  void _showEarlyCheckoutDialog(
    BuildContext context,
    String practiceType,
    Future<void> Function({String? earlyLeaveReason}) checkOut,
  ) {
    // Controller for the reason text input
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Leaving $practiceType Early"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Please note that you are leaving the $practiceType early and must provide a reason."),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Reason for leaving early...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => context.maybePop(),
            child: const Text("Cancel"),
          ),
          // Confirm check-out button
          TextButton(
            onPressed: () {
              checkOut(
                earlyLeaveReason: controller.text.isNotEmpty
                    ? "Left Early: ${controller.text}"
                    : null,
              ).then((value) {
                if (context.mounted) {
                  context.maybePop();
                }
              });
            },
            child: const Text("Complete check out"),
          ),
        ],
      ),
    );
  }

  /// Displays a standard check-out confirmation dialog
  void _showStandardCheckoutDialog(
    BuildContext context,
    String practiceType,
    Future<void> Function({String? earlyLeaveReason}) checkOut,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$practiceType Check Out"),
        content: const Text(
            "Thank you for letting us know when you leave! It makes it easier to keep track of everybody. See you next time."),
        actions: [
          TextButton(
            onPressed: () {
              context.router.maybePop();
            },
            child: const Text(
              "Bye!",
            ),
          ),
        ],
      ),
    ).then((value) => checkOut());
  }
}
