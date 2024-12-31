import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/indicator.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class AdminEventListTile extends ConsumerWidget {
  final Practice practice;
  final List<Attendance> attendances;

  const AdminEventListTile({
    required this.practice,
    required this.attendances,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter the attendances relevant to the current practice
    final attendanceList = attendances
        .where((attendance) => attendance.id == practice.id)
        .toList();

    final int fencerComments = attendanceList.expand((a) => a.comments).length;

    // Calculate the total number of fencers
    final totalFencers = ref
            .watch(thisSeasonFencersProvider)
            .asData
            ?.value
            .where((f) =>
                (practice.team == Team.both || f.team == practice.team) &&
                f.active)
            .length ??
        1;

    // Ensure total fencers is at least 1 to avoid division by zero
    final fencers = totalFencers > 0 ? totalFencers : 1;

    // Count attendance categories
    final attended = attendanceList.where((a) => a.attended).length;
    final excused = attendanceList.where((a) => a.excusedAbsense).length;
    final unexcused = attendanceList.where((a) => a.unexcusedAbsense).length;
    final noReason = fencers - (attended + excused + unexcused);

    // Define data for the pie chart
    final showingSections = [
      PieChartSectionData(
        value: attended / fencers,
        title: "$attended",
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      PieChartSectionData(
        value: excused / fencers,
        title: "$excused",
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      PieChartSectionData(
        value: unexcused / fencers,
        title: "$unexcused",
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      PieChartSectionData(
        value: noReason / fencers,
        title: "$noReason",
        color: Theme.of(context).disabledColor,
      ),
    ];

    return ListTile(
      leading: SizedBox(
        width: MediaQuery.of(context).size.width / 2.5,
        child: PieChart(
          key: ValueKey(showingSections), // Ensures proper rebuild
          PieChartData(
            borderData: FlBorderData(show: false), // No border for the chart
            sectionsSpace: 2, // Space between sections
            centerSpaceRadius: 40, // Radius for the inner circle
            sections: showingSections, // Data for the pie chart
            startDegreeOffset: 180, // Offset for better alignment
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge showing the practice team
          TextBadge(text: practice.team.type),
          // Practice type and timeframe
          Text("${practice.type.type} | ${practice.timeframe}"),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the practice run time
          Text(practice.runTime),
          if (fencerComments != 0)
            Text(
              "Comments: $fencerComments",
            ),
          // Generate indicators for each section of the pie chart
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(showingSections.length, (index) {
              final percentage =
                  (showingSections[index].value * 100).toStringAsFixed(2);
              return Column(
                children: [
                  Indicator(
                    isTouched: false,
                    size: 12,
                    color: showingSections[index].color,
                    text:
                        "${PracticeShowState.values[index + 1].type}|$percentage%",
                    isSquare: true,
                  ),
                  const SizedBox(height: 4),
                ],
              );
            }),
          ),
        ],
      ),
      // Navigate to detailed practice view on tap
      onTap: () => context.router.push(PracticeRoute(practiceID: practice.id)),
    );
  }
}
