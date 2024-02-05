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
  const AdminEventListTile(
      {required this.practice, required this.attendances, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Attendance> attendanceList = attendances
        .where((attendance) => attendance.id == practice.id)
        .toList();
    int fencers = ref
            .watch(fencersProvider)
            .asData
            ?.value
            .where((f) =>
                (practice.team == Team.both ? true : f.team == practice.team) &&
                f.active)
            .length ??
        1;
    if (fencers == 0) {
      fencers++;
    }
    int attended = attendanceList.where((a) => a.attended).length;
    int excused = attendanceList.where((a) => a.excusedAbsense).length;
    int unexcused = attendanceList.where((a) => a.unexcusedAbsense).length;
    int noReason = (fencers - (attended + excused + unexcused));
    List<PieChartSectionData> showingSections = [
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
        value: (fencers - (attended + excused + unexcused)) / fencers,
        title: "$noReason",
        color: Theme.of(context).disabledColor,
      ),
    ];
    return ListTile(
      leading: SizedBox(
        width: MediaQuery.of(context).size.width / 2.5,
        child: PieChart(
          key: ValueKey(showingSections),
          PieChartData(
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: showingSections,
            startDegreeOffset: 180,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextBadge(text: practice.team.type),
          Text("${practice.type.type} | ${practice.timeframe}"),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(practice.runTime),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(showingSections.length, (index) {
              String percentage =
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
                  const SizedBox(
                    height: 4,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      onTap: () => context.router.push(PracticeRoute(practiceID: practice.id)),
    );
  }
}
