import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/drill.dart';
import 'package:lhs_fencing/src/models/drill_season.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar_widget.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class DrillsListPage extends ConsumerStatefulWidget {
  const DrillsListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DrillsListPageState();
}

class _DrillsListPageState extends ConsumerState<DrillsListPage> {
  late TextEditingController controller;
  List<Attendance> attendances = [];
  Team? teamFilter;
  Weapon? weaponFilter;
  SchoolYear? yearFilter;

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
    List<Drill> drills = [];
    Widget whenData(List<PracticeMonth> practiceMonths) {
      List<Practice> practices = [];
      for (var month in practiceMonths) {
        practices.addAll(month.practices);
      }
      List<Drill> filteredDrills = drills.toList();
      if (controller.text.isNotEmpty) {
        filteredDrills = drills
            .where((f) =>
                f.name.toLowerCase().contains(
                      controller.text.toLowerCase(),
                    ) ||
                f.description.toLowerCase().contains(
                      controller.text.toLowerCase(),
                    ))
            .toList();
      }

      return DefaultTabController(
        length: TypeDrill.values.length + 1,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Drills List"),
                const SizedBox(width: 8),
                TextBadge(
                  text: "${drills.length}",
                  title: true,
                ),
              ],
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SearchBarWidget(
                      controller,
                      text: "Search by name or description",
                    ),
                    TabBar(
                      tabs: List.generate(
                        TypeDrill.values.length + 1,
                        (index) => Tab(
                          child: Text(index == 0
                              ? "All Drills"
                              : TypeDrill.values[index - 1].type),
                        ),
                      ),
                      isScrollable: true,
                      onTap: (value) {},
                    ),
                  ],
                )),
          ),
          body: TabBarView(
            children: List.generate(
              TypeDrill.values.length + 1,
              (index) {
                List<Drill> drills = filteredDrills;
                if (index != 0) {
                  filteredDrills
                      .where((d) => d.type == TypeDrill.values[index - 1])
                      .toList();
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 60),
                  itemCount: drills.length,
                  itemBuilder: (context, i) {
                    Drill drill = drills[i];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            TextBadge(text: "${drill.type.type} Drill"),
                          Text(
                            drill.name,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(drill.description),
                          if (drill.lastUsed != null) ...[
                            Text(
                                "Last Used: ${DateFormat("EEE, MM/dd @hh:mm aa}").format(drill.lastUsed!)}"),
                            Text("Times Used: ${drill.timesUsed}"),
                          ],
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            context.router.push(EditDrillsRoute(drill: drill)),
                        child: const Icon(Icons.edit),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => context.router.push(const AddDrillsRoute()),
          ),
        ),
      );
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

    Widget whenDrillsData(List<DrillSeason> data) {
      drills.clear();
      for (var season in data) {
        drills.addAll(season.drills);
      }
      return ref.watch(allAttendancesProvider).when(
          data: whenAttendanceData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage());
    }

    return ref.watch(drillsProvider).when(
          data: whenDrillsData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
