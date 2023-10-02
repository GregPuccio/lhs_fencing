import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/views/admin/fencer_details_page.dart';
import 'package:lhs_fencing/src/views/home/widgets/no_events_found.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';
import 'package:lhs_fencing/src/views/home/widgets/upcoming_events.dart';
import 'package:lhs_fencing/src/widgets/indicator.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';

class HomePage extends StatefulWidget {
  final Attendance? todaysAttendance;
  final Practice? upcomingPractice;
  final List<Practice> practices;
  final List<Attendance> attendances;
  final UserData userData;
  final void Function(int) updateIndexFn;
  const HomePage({
    super.key,
    required this.todaysAttendance,
    required this.upcomingPractice,
    required this.practices,
    required this.attendances,
    required this.userData,
    required this.updateIndexFn,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    List<Practice> pracs = widget.practices.toList();
    pracs.sort((a, b) => -a.startTime.compareTo(b.startTime));
    pracs.retainWhere((p) => p.endTime.isBefore(DateTime.now()));

    List<PieChartSectionData> showingSections = [
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              widget.attendances,
              PracticeShowState.attended,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          widget.attendances,
          PracticeShowState.attended,
        ).length}",
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              widget.attendances,
              PracticeShowState.excused,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          widget.attendances,
          PracticeShowState.excused,
        ).length}",
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(
              pracs,
              widget.attendances,
              PracticeShowState.unexcused,
            ).length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          widget.attendances,
          PracticeShowState.unexcused,
        ).length}",
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      PieChartSectionData(
        value: getShownPractices(
                    pracs, widget.attendances, PracticeShowState.noReason)
                .length /
            pracs.length,
        title: "${getShownPractices(
          pracs,
          widget.attendances,
          PracticeShowState.noReason,
        ).length}",
        color: Theme.of(context).disabledColor,
      ),
    ];

    List<Practice> upcomingPractices = widget.practices
        .where((prac) => prac.startTime.isAfter(DateTime.now()))
        .toList();
    upcomingPractices
        .removeWhere((prac) => prac.id == widget.upcomingPractice?.id);

    return ListView(
      children: [
        const WelcomeHeader(),
        const Divider(),
        if (pracs.isNotEmpty)
          Row(
            children: <Widget>[
              const SizedBox(
                height: 18,
              ),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: showingSections,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      startDegreeOffset: 180,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    Text(
                      "${pracs.length} Total Attendances",
                      style: const TextStyle(
                        fontSize: 14,
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
                              isTouched: touchedIndex == index,
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
              ),
              const SizedBox(
                width: 28,
              ),
            ],
          )
        else
          const ListTile(
            title: Text(
                "Attendance data will populate here after your first attendance."),
          ),
        const Divider(),
        if (widget.todaysAttendance != null &&
            widget.upcomingPractice != null) ...[
          TodaysAttendance(
            todaysAttendance: widget.todaysAttendance!,
            practice: widget.upcomingPractice!,
          ),
        ] else
          const NoEventsFound(),
        const Divider(),
        UpcomingEvents(
          practices: upcomingPractices,
          attendances: widget.attendances,
          updateIndexFn: widget.updateIndexFn,
        ),
      ],
    );
  }
}
