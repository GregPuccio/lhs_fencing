import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkin_button.dart';
import 'package:lhs_fencing/src/views/home/widgets/checkout_button.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

/// A widget that displays practice attendance information in a tile format
class AttendanceTile extends StatelessWidget {
  /// The practice associated with this attendance tile
  final Practice practice;

  /// The attendance record for the practice
  final Attendance attendance;

  /// Whether the tile can be tapped to view details
  final bool canTap;

  /// Whether to show status change buttons (check-in/check-out)
  final bool showStatusChange;

  /// Whether this tile represents today's practice
  final bool isTodaysPractice;

  const AttendanceTile({
    required this.practice,
    required this.attendance,
    this.canTap = true,
    this.showStatusChange = false,
    this.isTodaysPractice = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the practice is in the past
    final bool inPast = DateTime.now().isAfter(practice.endTime);

    // If it's today's practice and in the past, show a "no more events" message
    if (isTodaysPractice && inPast) {
      return _buildNoEventsContainer(context);
    }

    // If it's today's practice, build the today's practice tile
    if (isTodaysPractice) {
      return _buildTodaysEventTile(context);
    }

    // Otherwise, build a standard practice tile
    return _buildStandardEventTile(context);
  }

  /// Builds a container shown when there are no more upcoming events
  Widget _buildNoEventsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "More Events TBA",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const ListTile(
              title: Text(
                "Looks like there are no more upcoming events!",
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                "If you think this is an error, please let Coach Greg know",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the tile for today's practice
  Widget _buildTodaysEventTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
          title: _buildPracticeTitleText(context),
          subtitle: _buildPracticeSubtitle(context),
          trailing: _buildTrailingIcon(context),
          onTap: canTap ? () => _navigateToAttendanceDetails(context) : null,
        ),
      ),
    );
  }

  /// Builds a standard practice tile for non-today practices
  Widget _buildStandardEventTile(BuildContext context) {
    return ListTile(
      title: _buildPracticeTitleRow(context),
      subtitle: _buildPracticeSubtitle(context),
      trailing: _buildTrailingIcon(context),
      onTap: canTap ? () => _navigateToAttendanceDetails(context) : null,
    );
  }

  /// Builds the title text for the practice tile
  Widget _buildPracticeTitleText(BuildContext context) {
    return Text(
      practice.startTime.isToday
          ? "Today's ${practice.type.type} @ ${DateFormat("h:mm aa").format(practice.startTime)}"
          : "Next: ${practice.timeframe} - ${practice.type.type}",
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }

  /// Builds the title row for a standard practice tile
  Widget _buildPracticeTitleRow(BuildContext context) {
    return Row(
      children: [
        TextBadge(text: practice.team.type),
        const SizedBox(width: 8),
        Text(
          "${practice.type.type} | ${practice.timeframe}",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  /// Builds the subtitle with practice details and optional status change buttons
  Widget _buildPracticeSubtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Practice details column
        _buildPracticeDetailsColumn(context),

        // Status change buttons (if applicable)
        if (showStatusChange && attendance.checkOut == null)
          if (attendance.attended)
            CheckOutButton(
              attendance: attendance,
              practice: practice,
            )
          else
            CheckInButton(practice: practice)
      ],
    );
  }

  /// Builds a column with practice details
  Widget _buildPracticeDetailsColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          practice.location,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(practice.runTime),
        Text(attendance.status(practice)),
        // Show comments count if any comments exist
        if (attendance.comments.isNotEmpty)
          Text(
            "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  /// Builds the trailing icon (arrow forward)
  Widget? _buildTrailingIcon(BuildContext context) {
    return showStatusChange ? null : const Icon(Icons.arrow_forward);
  }

  /// Navigates to the attendance details page
  void _navigateToAttendanceDetails(BuildContext context) {
    context.router.push(AttendanceRoute(practiceID: attendance.id));
  }
}
