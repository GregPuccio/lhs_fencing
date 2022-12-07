import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/views/admin/widgets/no_practice_today.dart';
import 'package:lhs_fencing/src/views/admin/widgets/todays_practice.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';

class PracticeTypeTabBar extends SliverPersistentHeaderDelegate {
  Practice? currentPractice;
  PracticeTypeTabBar(this.currentPractice);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (currentPractice != null)
            TodaysPractice(currentPractice: currentPractice!)
          else
            const NoPracticeToday(),
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
  double get maxExtent => 184;

  @override
  double get minExtent => 184;

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
