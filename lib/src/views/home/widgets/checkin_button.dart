import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

/// A widget that manages the check-in process for a specific practice
///
/// This widget handles various check-in scenarios:
/// - Checking in too early
/// - Checking in too late
/// - Checking in on time
/// - Checking in late with a required reason
class CheckInButton extends ConsumerWidget {
  /// The practice for which the check-in is being performed
  final Practice practice;

  /// Constructor for the CheckInButton
  const CheckInButton({
    super.key,
    required this.practice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Render the check-in button
    // The button is enabled if the practice is today and is not over
    return ElevatedButton.icon(
      onPressed: practice.startTime.isToday && !practice.isOver
          ? () => _handleCheckIn(context, ref)
          : null,
      icon: const Icon(Icons.check),
      label: const Text("Check In"),
    );
  }

  /// Primary method to handle the check-in process
  ///
  /// This method manages the different check-in scenarios based on
  /// the current time relative to the practice start time
  Future<void> _handleCheckIn(BuildContext context, WidgetRef ref) async {
    // Check if the practice is too late for check-in
    if (practice.isTooLate) {
      _showCannotCheckInDialog(
        context: context,
        title: "Too Late For Check In",
        content:
            "You cannot check in through the app this late after the ${practice.type.type} has begun. Ask one of the coaches to check you in.",
      );
      return;
    }

    // Check if the practice check-in is too early
    if (practice.tooSoonForCheckIn) {
      _showCannotCheckInDialog(
        context: context,
        title: "Too Early For Check In",
        content:
            "You cannot check in for attendance before the ${practice.type.type} has started. Make sure it is less than ${practice.type.tooEarlyTime} ahead of the ${practice.type.type} before you try checking in again.",
      );
      return;
    }

    // Handle late check-in scenario
    if (practice.isLate) {
      await _handleLateCheckIn(context, ref);
    }
    // Handle on-time check-in scenario
    else if (practice.canCheckIn) {
      await _handleOnTimeCheckIn(context, ref);
    }
  }

  /// Handles the check-in process when the user is late to the practice
  ///
  /// Displays a dialog requesting a reason for being late
  /// Performs the check-in if the user confirms
  Future<void> _handleLateCheckIn(BuildContext context, WidgetRef ref) async {
    // Create a controller to manage the late reason text input
    final controller = TextEditingController();

    // Show the late check-in dialog and wait for user response
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLateCheckInDialog(context, controller),
    );

    // Proceed with check-in if user confirms
    if (result == true) {
      try {
        // Perform check-in with late reason if provided
        await _performCheckIn(
          ref,
          lateReason:
              controller.text.isNotEmpty ? "Late: ${controller.text}" : null,
        );

        // Close the current screen if the context is still mounted
        if (context.mounted) context.router.maybePop();
      } catch (e) {
        // Show error dialog if check-in fails
        if (context.mounted) {
          _showCannotCheckInDialog(
            context: context,
            title: "Check-In Error",
            content: "There was a problem checking in. Please try again.",
          );
        }
      }
    }
  }

  /// Handles the check-in process when the user is on time
  ///
  /// Displays a confirmation dialog and performs the check-in if confirmed
  Future<void> _handleOnTimeCheckIn(BuildContext context, WidgetRef ref) async {
    // Show the on-time check-in dialog and wait for user response
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildOnTimeCheckInDialog(context),
    );

    // Proceed with check-in if user confirms
    if (result == true) {
      try {
        // Perform check-in without a late reason
        await _performCheckIn(ref);

        // Close the current screen if the context is still mounted
        if (context.mounted) context.router.maybePop();
      } catch (e) {
        // Show error dialog if check-in fails
        if (context.mounted) {
          _showCannotCheckInDialog(
            context: context,
            title: "Check-In Error",
            content: "There was a problem checking in. Please try again.",
          );
        }
      }
    }
  }

  /// Performs the actual check-in process
  ///
  /// Creates an Attendance record with the current time and optional late reason
  /// Uses Riverpod providers to access user and attendance data
  Future<void> _performCheckIn(WidgetRef ref, {String? lateReason}) async {
    // Retrieve current user data from the provider
    final userData = ref.read(userDataProvider).value!;

    // Retrieve attendance months from the provider
    final months = ref.read(attendancesProvider).value!;

    // Add the attendance record to Firestore
    await addAttendance(
      userData.id,
      months,
      Attendance.create(practice, userData).copyWith(
        // Set check-in time to current time
        checkIn: DateTime.now(),
        // Add a comment if a late reason is provided
        comments: [
          if (lateReason != null)
            Comment.create(userData).copyWith(text: lateReason)
        ],
      ),
    );
  }

  /// Displays a simple informational dialog
  ///
  /// Used for showing error messages or other brief notifications
  void _showCannotCheckInDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => context.maybePop(),
            child: const Text("Understood"),
          ),
        ],
      ),
    );
  }

  /// Builds the dialog for late check-ins
  ///
  /// Allows users to provide a reason for being late
  /// Includes validation and confirmation
  AlertDialog _buildLateCheckInDialog(
      BuildContext context, TextEditingController controller) {
    return AlertDialog(
      title: Text("Late ${practice.type.type} Check In"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Explanation of late check-in requirement
            Text(
                "Please note that you are late to the ${practice.type.type} and must provide a reason."),
            const SizedBox(height: 8),

            // Text input for late reason
            TextFormField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Reason for being late",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Validate that a reason is provided
              validator: (value) =>
                  value?.isNotEmpty == true ? null : "Please provide a reason.",
            ),
            const SizedBox(height: 8),

            // Confirmation of current location
            Text(
                "Check in ONLY when you have arrived at the ${practice.type.type}. Are you currently at: ${practice.location}${practice.type.usesBus ? " or on/waiting for a Livingston Bus" : ""}?"),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => context.maybePop(false),
          child: const Text("No, cancel"),
        ),
        // Confirm check-in button
        TextButton(
          onPressed: () => context.maybePop(true),
          child: const Text("Yes, check in"),
        ),
      ],
    );
  }

  /// Builds the dialog for on-time check-ins
  ///
  /// Confirms the user's current location before checking in
  AlertDialog _buildOnTimeCheckInDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Check In To ${practice.type.type}"),
      content: Text(
        "Check in ONLY when you have arrived at the ${practice.type.type} or at the location of the event! Are you currently at: ${practice.location}${practice.type.usesBus ? " or on/waiting for a Livingston Bus" : ""}?",
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => context.maybePop(false),
          child: const Text("No, cancel"),
        ),
        // Confirm check-in button
        TextButton(
          onPressed: () => context.maybePop(true),
          child: const Text("Yes, check in"),
        ),
      ],
    );
  }
}
