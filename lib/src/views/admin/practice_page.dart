import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/attendance_info.dart';
import 'package:lhs_fencing/src/widgets/attendance_status_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class PracticePage extends ConsumerWidget {
  final Practice practice;
  const PracticePage({required this.practice, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<UserData> fencers = [];
    Widget whenData(List<AttendanceMonth> attendanceMonths) {
      List<Attendance> attendances = [];
      for (var month in attendanceMonths) {
        for (var attendance in month.attendances) {
          if (attendance.id == practice.id) {
            attendances.add(attendance);
          }
        }
      }
      List<Attendance> presentFencers =
          attendances.where((attendance) => attendance.attended).toList();
      presentFencers
          .sort((a, b) => a.userData.lastName.compareTo(b.userData.lastName));
      List<UserData> absentFencers = fencers
          .where((fencer) => !attendances.any((attendance) =>
              attendance.userData.id == fencer.id && attendance.attended))
          .toList();
      absentFencers.sort((a, b) => a.lastName.compareTo(b.lastName));

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(practice.startString),
            actions: const [],
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Present"),
                      const SizedBox(width: 8),
                      TextBadge(text: "${presentFencers.length}"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not Present"),
                      const SizedBox(width: 8),
                      TextBadge(text: "${absentFencers.length}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ListView.separated(
                itemCount: presentFencers.length,
                itemBuilder: (context, index) {
                  Attendance attendance = presentFencers[index];

                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AttendanceStatusBar(attendance),
                        Text(attendance.userData.fullName),
                      ],
                    ),
                    onTap: () => context.router.push(
                      EditFencerStatusRoute(
                        fencer: attendance.userData,
                        practice: practice,
                        attendance: attendance,
                      ),
                    ),
                    subtitle: AttendanceInfo(attendance),
                    trailing: const Icon(Icons.edit),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
              ListView.separated(
                itemCount: absentFencers.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container();
                    // return Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       showDialog(
                    //         context: context,
                    //         builder: (context) => AlertDialog(
                    //           title: const Text("Send An Email"),
                    //           content: const Text(
                    //               "Do you want to send an email to all of the students not present for this practice?"),
                    //           actions: [
                    //             TextButton(
                    //               onPressed: () => context.router.pop(),
                    //               child: const Text("No, cancel"),
                    //             ),
                    //             TextButton(
                    //               onPressed: () async {
                    //                 UserData coach = ref
                    //                     .read(userDataProvider)
                    //                     .asData!
                    //                     .value!;
                    //                 Uri url = Uri(
                    //                     scheme: "mailto",
                    //                     path: coach.email,
                    //                     query:
                    //                         "bcc=${List.generate(absentFencers.length, (index) => absentFencers[index].email).join(",")}&subject=Absent from practice ${practice.startString}&body=Hello,\nOur records are showing that you were not at practice ${practice.startString}.\nIf you have not already provided a reason, please add a comment on the attendance site ASAP.\nThank you,\nCoach ${coach.firstName}");
                    //                 try {
                    //                   if (await canLaunchUrl(url)) {
                    //                     launchUrl(
                    //                       url,
                    //                     ).then((value) => context.popRoute());
                    //                   } else {
                    //                     ScaffoldMessenger.of(context)
                    //                         .showSnackBar(const SnackBar(
                    //                             content:
                    //                                 Text("Cannot launch URL")));
                    //                   }
                    //                 } catch (e) {
                    //                   ScaffoldMessenger.of(context)
                    //                       .showSnackBar(SnackBar(
                    //                           content: Text(e.toString())));
                    //                 }
                    //               },
                    //               child: const Text("Yes, please"),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     },
                    //     icon: const Text("Email Absent Fencers"),
                    //     label: const Icon(Icons.email),
                    //   ),
                    // );
                  } else {
                    index--;

                    UserData fencer = absentFencers[index];
                    int attendanceIndex = attendances.indexWhere(
                        (attendance) => attendance.userData.id == fencer.id);
                    Attendance? attendance;
                    if (attendanceIndex != -1) {
                      attendance = attendances[attendanceIndex];
                    }

                    return ListTile(
                      title: Text(fencer.fullName),
                      onTap: () => context.router.push(
                        EditFencerStatusRoute(
                          fencer: fencer,
                          practice: practice,
                          attendance: attendance,
                        ),
                      ),
                      subtitle: attendance != null
                          ? Text(
                              "View ${attendance.comments.length} comment${attendance.comments.length == 1 ? "" : "s"}",
                            )
                          : null,
                      trailing: const Icon(Icons.edit),
                    );
                  }
                },
                separatorBuilder: (context, index) =>
                    index != 0 ? const Divider() : Container(),
              ),
            ],
          ),
        ),
      );
    }

    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      return ref.watch(allAttendancesProvider).when(
          data: whenData,
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
