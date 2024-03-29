// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lhs_fencing/src/models/attendance.dart';
// import 'package:lhs_fencing/src/models/attendance_month.dart';
// import 'package:lhs_fencing/src/models/practice.dart';
// import 'package:lhs_fencing/src/models/user_data.dart';
// import 'package:lhs_fencing/src/services/providers/providers.dart';
// import 'package:lhs_fencing/src/services/router/router.dart';
// import 'package:lhs_fencing/src/widgets/error.dart';
// import 'package:lhs_fencing/src/widgets/loading.dart';

// class PastPractices extends ConsumerWidget {
//   const PastPractices({
//     Key? key,
//     required this.practices,
//   }) : super(key: key);

//   final List<Practice> practices;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     practices.sort((a, b) => -a.startTime.compareTo(b.startTime));

//     List<UserData> fencers = [];
//     Widget whenData(List<AttendanceMonth> attendanceMonths) {
//       return CustomScrollView(
//         key: const PageStorageKey<String>("past"),
//         slivers: <Widget>[
//           SliverOverlapInjector(
//             handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.only(bottom: 60),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   Practice practice = practices[index];
//                   List<Attendance> attendances = [];
//                   for (var month in attendanceMonths) {
//                     for (var attendance in month.attendances) {
//                       if (attendance.id == practice.id) {
//                         attendances.add(attendance);
//                       }
//                     }
//                   }
//                   int presentFencers = fencers
//                       .where((fencer) => attendances.any((attendance) =>
//                           attendance.userData.id == fencer.id &&
//                           attendance.attended))
//                       .length;
//                   int absentFencers = fencers
//                       .where((fencer) => !attendances.any((attendance) =>
//                           attendance.userData.id == fencer.id &&
//                           attendance.attended))
//                       .length;
//                   return Column(
//                     children: [
//                       ListTile(
//                         title: Text(practice.startString),
//                         subtitle: Text(
//                           "${practice.type.type} | $presentFencers Checked In • $absentFencers Absent",
//                         ),
//                         onTap: () => context.router
//                             .push(PracticeRoute(practiceID: practice.id)),
//                       ),
//                       if (index != practices.length - 1) const Divider(),
//                     ],
//                   );
//                 },
//                 childCount: practices.length,
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     Widget whenFencerData(List<UserData> data) {
//       fencers = data;
//       return ref.watch(allAttendancesProvider).when(
//           data: whenData,
//           error: (error, stackTrace) => const ErrorPage(),
//           loading: () => const LoadingPage());
//     }

//     return ref.watch(fencersProvider).when(
//           data: whenFencerData,
//           error: (error, stackTrace) => const ErrorPage(),
//           loading: () => const LoadingPage(),
//         );
//   }
// }
