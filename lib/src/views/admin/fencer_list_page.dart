import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/fencer_details_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/indicator.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar_widget.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class FencerListPage extends ConsumerStatefulWidget {
  const FencerListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FencerListPageState();
}

class _FencerListPageState extends ConsumerState<FencerListPage> {
  late TextEditingController controller;
  List<Attendance> attendances = [];

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
    List<UserData> fencers = [];
    Widget whenData(List<PracticeMonth> practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      List<UserData> filteredFencers = fencers.toList();
      if (controller.text.isNotEmpty) {
        filteredFencers = fencers
            .where(
              (f) => f.fullName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
            )
            .toList();
      }
      return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Fencer List"),
                const SizedBox(width: 8),
                TextBadge(text: "${fencers.length}"),
              ],
            ),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.bug_report),
            //     onPressed: () {
            //       for (var fencer in fencers) {
            //         List<AttendanceMonth> months = attendanceMonths
            //             .where((element) =>
            //                 element.attendances.first.userData.id == fencer.id)
            //             .toList();
            //         for (int index = 0; index < months.length; index++) {
            //           FirestoreService.instance.updateData(
            //             path: FirestorePath.attendance(
            //                 fencer.id, months[index].id),
            //             data: months[index].toMap(),
            //           );
            //         }
            //       }
            //     },
            //   )
            // ],
            bottom: SearchBarWidget(controller),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.only(bottom: 60),
            itemCount: filteredFencers.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  height: 30,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    scrollDirection: Axis.horizontal,
                    children: [
                      PopupMenuButton(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context) => List<PopupMenuItem>.generate(
                          Team.values.length - 1,
                          (index) => PopupMenuItem(
                            child: Text(Team.values[index].type),
                          ),
                        ).toList(),
                        icon: const Row(
                          children: [
                            Text("Team"),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context) => List<PopupMenuItem>.generate(
                          SchoolYear.values.length,
                          (index) => PopupMenuItem(
                            child: Text(SchoolYear.values[index].type),
                          ),
                        ).toList(),
                        icon: const Row(
                          children: [
                            Text("School Year"),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        offset: const Offset(0, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context) => List<PopupMenuItem>.generate(
                          SchoolYear.values.length,
                          (index) => PopupMenuItem(
                            child: Text(Weapon.values[index].type),
                          ),
                        ).toList(),
                        icon: const Row(
                          children: [
                            Text("Weapon"),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                UserData fencer = filteredFencers[index - 1];

                List<Attendance> fencerAttendances = attendances
                    .where((att) => att.userData.id == fencer.id)
                    .toList();
                int attendedPractices = getShownPractices(
                  practices,
                  fencerAttendances,
                  PracticeShowState.attended,
                ).length;
                int excusedPractices = getShownPractices(
                  practices,
                  fencerAttendances,
                  PracticeShowState.excused,
                ).length;
                int unexcusedPractices = getShownPractices(
                  practices,
                  fencerAttendances,
                  PracticeShowState.unexcused,
                ).length;
                int noReasonPractices = getShownPractices(
                  practices,
                  fencerAttendances,
                  PracticeShowState.noReason,
                ).length;

                List<PieChartSectionData> showingSections = [
                  PieChartSectionData(
                    value: attendedPractices / practices.length,
                    title: "$attendedPractices",
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  PieChartSectionData(
                    value: excusedPractices / practices.length,
                    title: "$excusedPractices",
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  PieChartSectionData(
                    value: unexcusedPractices / practices.length,
                    title: "$unexcusedPractices",
                    color: Theme.of(context).colorScheme.errorContainer,
                  ),
                  PieChartSectionData(
                    value: noReasonPractices / practices.length,
                    title: "$noReasonPractices",
                    color: Theme.of(context).disabledColor,
                  ),
                ];

                return ListTile(
                  leading: SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: PieChart(
                      PieChartData(
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: showingSections,
                        startDegreeOffset: 180,
                      ),
                    ),
                  ),
                  title: Text(
                    fencer.fullName,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${fencer.team.type} | ${fencer.schoolYear.type}\n${fencer.weapon.type} Fencer"),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(showingSections.length, (index) {
                          String percentage =
                              (showingSections[index].value * 100)
                                  .toStringAsFixed(2);
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
                  onTap: () => context.router.push(
                    FencerDetailsRoute(fencerID: fencer.id),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                );
              }
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
    }

    Widget whenAttendanceData(List<AttendanceMonth> attendanceMonths) {
      attendances.clear();
      for (var month in attendanceMonths) {
        attendances.addAll(month.attendances);
      }
      return ref.watch(practicesProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenAttendanceData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
