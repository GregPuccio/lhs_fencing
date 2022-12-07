import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';

class PracticeTypeTabBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const TabBar(
        tabs: [
          Tab(text: "Past Practices"),
          Tab(text: "Future Practices"),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class FencerPracticeTypeTabBar extends SliverPersistentHeaderDelegate {
  List<Attendance> attendances;
  FencerPracticeTypeTabBar(this.attendances);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          TodaysAttendance(attendances: attendances),
          const TabBar(
            tabs: [
              Tab(text: "Past Practices"),
              Tab(text: "Future Practices"),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 168;

  @override
  double get minExtent => 168;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
