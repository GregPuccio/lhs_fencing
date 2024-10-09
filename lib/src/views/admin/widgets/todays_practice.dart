// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:lhs_fencing/src/constants/date_utils.dart';
// import 'package:lhs_fencing/src/models/attendance.dart';
// import 'package:lhs_fencing/src/models/attendance_month.dart';
// import 'package:lhs_fencing/src/models/practice.dart';
// import 'package:lhs_fencing/src/models/user_data.dart';
// import 'package:lhs_fencing/src/services/providers/providers.dart';
// import 'package:lhs_fencing/src/services/router/router.dart';
// import 'package:lhs_fencing/src/views/admin/widgets/practice_status.dart';
// import 'package:lhs_fencing/src/widgets/error.dart';
// import 'package:lhs_fencing/src/widgets/loading.dart';

// class TodaysPractice extends ConsumerWidget {
//   const TodaysPractice({Key? key, required this.currentPractices})
//       : super(key: key);

//   final List<Practice> currentPractices;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     List<UserData> fencers = [];
//     Widget whenData(List<AttendanceMonth> attendanceMonths) {
//       List<Attendance> attendances = [];
//       int comments = 0;
//       for (var month in attendanceMonths) {
//         for (var attendance in month.attendances) {
//           if (attendance.id == currentPractices.id) {
//             attendances.add(attendance);
//             comments += attendance.comments.length;
//           }
//         }
//       }
//       int presentFencers = fencers
//           .where((fencer) => attendances.any((attendance) =>
//               attendance.userData.id == fencer.id && attendance.attended))
//           .length;
//       int absentFencers = fencers
//           .where((fencer) => !attendances.any((attendance) =>
//               attendance.userData.id == fencer.id && attendance.attended))
//           .length;
//       return Card(
//         color: Theme.of(context).colorScheme.primaryContainer,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Text(
//                 currentPractices.startTime.isToday
//                     ? "Today's ${currentPractices.type.type} @ ${DateFormat("h:mm aa").format(currentPractices.startTime)}"
//                     : "Next: ${currentPractices.timeframe} - ${currentPractices.type.type}",
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const Divider(),
//               ListTile(
//                 title: Text(currentPractices.runTime),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(currentPractices.location),
//                     PracticeInfo(currentPractices, presentFencers, absentFencers,
//                         comments),
//                   ],
//                 ),
//                 trailing: const Icon(Icons.arrow_forward),
//                 onTap: () => context.router.push(
//                   PracticeRoute(practiceID: currentPractices.id),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     Widget whenFencerData(List<UserData> data) {
//       fencers = data.toList();
//       fencers.retainWhere((fencer) => fencer.active);
//       return ref.watch(allAttendancesProvider).when(
//           data: whenData,
//           error: (error, stackTrace) => const ErrorTile(),
//           loading: () => const LoadingTile());
//     }

//     return ref.watch(fencersProvider).when(
//           data: whenFencerData,
//           error: (error, stackTrace) => const ErrorTile(),
//           loading: () => const LoadingTile(),
//         );
//   }
// }
