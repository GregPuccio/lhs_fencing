import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/views/admin/fencer_details_page.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_schedule.dart';
import 'package:lhs_fencing/src/widgets/indicator.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';

class HomePage extends StatelessWidget {
  final Attendance todaysAttendance;
  final Practice upcomingPractice;
  final List<Practice> practices;
  final List<Attendance> attendances;
  final UserData userData;
  const HomePage({
    super.key,
    required this.todaysAttendance,
    required this.upcomingPractice,
    required this.practices,
    required this.attendances,
    required this.userData,
  });
  @override
  Widget build(BuildContext context) {
    List<Practice> pracs = practices.toList();
    pracs.sort((a, b) => -a.startTime.compareTo(b.startTime));
    pracs.retainWhere((p) => p.endTime.isBefore(DateTime.now()));

    List<PieChartSectionData> showingSections = [
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              attendances,
              PracticeShowState.attended,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          attendances,
          PracticeShowState.attended,
        ).length}",
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              attendances,
              PracticeShowState.excused,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          attendances,
          PracticeShowState.excused,
        ).length}",
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              attendances,
              PracticeShowState.unexcused,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          attendances,
          PracticeShowState.unexcused,
        ).length}",
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(pracs, attendances, PracticeShowState.noReason)
                .length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          attendances,
          PracticeShowState.noReason,
        ).length}",
        color: Theme.of(context).colorScheme.tertiaryContainer,
      ),
    ];

    return ListView(
      children: [
        const WelcomeHeader(),
        const Divider(),

        Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 2,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections,
                  ),
                ),
              ),
            ),
            IntrinsicWidth(
              child: Column(
                children: [
                  Text(
                    "${pracs.length} Total Attendances",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(showingSections.length, (index) {
                      String percentage = (showingSections[index].value * 100)
                          .toStringAsFixed(2);
                      return Column(
                        children: [
                          Indicator(
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
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
        TodaysAttendance(
          todaysAttendance: todaysAttendance,
          practice: upcomingPractice,
        ),
        // const Divider(),
        TodaysSchedule(practice: upcomingPractice),
      ],
    );
  }
}
