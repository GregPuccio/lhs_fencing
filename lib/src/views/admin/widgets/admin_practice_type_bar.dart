import 'package:flutter/material.dart';

class PracticeTypeTabBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return const TabBar(
      tabs: [
        Tab(text: "Past Practices"),
        Tab(text: "Future Practices"),
      ],
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
