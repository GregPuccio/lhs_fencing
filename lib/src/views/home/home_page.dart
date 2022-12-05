import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/firestore/streams.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/views/home/widgets/todays_attendance.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: StreamBuilder<List<Attendance>>(
            stream: FirestoreStreams().previousAttendances(userData.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Attendance> attendances = snapshot.data!;
                attendances.sort((a, b) => a.checkIn.compareTo(b.checkIn));
                List<Attendance> previousAttendances = attendances.where((e) {
                  DateTime practiceDay = DateTime(e.practiceStart.year,
                      e.practiceStart.month, e.practiceStart.day);
                  DateTime now = DateTime.now();
                  DateTime today = DateTime(now.year, now.month, now.day);
                  return !practiceDay.isAtSameMomentAs(today);
                }).toList();

                return ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: previousAttendances.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const WelcomeHeader(),
                          const Divider(),
                          const Instructions(),
                          const Divider(),
                          TodaysAttendance(attendances: attendances),
                          const Divider(),
                          Text(
                            "Previous Attendances",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (previousAttendances.isEmpty)
                            Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "No Practices Attended",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Divider(),
                              ],
                            ),
                        ],
                      );
                    } else if (index == previousAttendances.length + 1) {
                      return OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Text("Sign Out"),
                        label: const Icon(Icons.logout),
                      );
                    } else {
                      index--;
                      Attendance attendance = previousAttendances[index];
                      String practiceStart =
                          DateFormat('EEEE, MMMM d @ h:mm aa')
                              .format(attendance.practiceStart);
                      String checkedIn =
                          DateFormat('h:mm aa').format(attendance.checkIn);
                      return ListTile(
                        title: Text(practiceStart),
                        subtitle: Text("Checked in: $checkedIn"),
                      );
                    }
                  },
                  separatorBuilder: (context, index) =>
                      index == 0 ? Container() : const Divider(),
                );
              } else {
                return const LoadingPage();
              }
            },
          ),
        );
      } else {
        return const LoadingPage();
      }
    }

    return ref.watch(userDataProvider).when(
        data: whenData,
        error: (error, stackTrace) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}
