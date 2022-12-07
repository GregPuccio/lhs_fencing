import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class FuturePractices extends StatelessWidget {
  const FuturePractices({
    Key? key,
    required this.practices,
  }) : super(key: key);

  final List<Practice> practices;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    List<Practice> futurePractices = practices
        .where((p) => p.startTime.isAfter(today.add(const Duration(hours: 24))))
        .toList();
    futurePractices.sort((a, b) => a.startTime.compareTo(b.startTime));
    return CustomScrollView(
      key: const PageStorageKey<String>("future"),
      slivers: <Widget>[
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              Practice practice = futurePractices[index];

              return Column(
                children: [
                  ListTile(
                    title: Text(practice.startString),
                  ),
                  if (index != futurePractices.length - 1) const Divider(),
                ],
              );
            },
            childCount: futurePractices.length,
          ),
        ),
      ],
    );
  }
}
