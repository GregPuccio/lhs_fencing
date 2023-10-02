// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:lhs_fencing/src/models/practice.dart';
// import 'package:lhs_fencing/src/services/router/router.dart';

// class FuturePractices extends StatelessWidget {
//   const FuturePractices({
//     Key? key,
//     required this.practices,
//   }) : super(key: key);

//   final List<Practice> practices;

//   @override
//   Widget build(BuildContext context) {
//     practices.sort((a, b) => a.startTime.compareTo(b.startTime));

//     return CustomScrollView(
//       key: const PageStorageKey<String>("future"),
//       slivers: <Widget>[
//         SliverOverlapInjector(
//           handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.only(bottom: 60),
//           sliver: SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 Practice practice = practices[index];

//                 return Column(
//                   children: [
//                     ListTile(
//                       title: Text(practice.startString),
//                       subtitle: Text(practice.type.type),
//                       onTap: () => context.router.push(
//                         PracticeRoute(practiceID: practice.id),
//                       ),
//                     ),
//                     if (index != practices.length - 1) const Divider(),
//                   ],
//                 );
//               },
//               childCount: practices.length,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
