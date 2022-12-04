import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/lists.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/home/welcome_header.dart';
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
        DateTime now = DateTime.now();
        final closetsDateTimeToNow = possibleAttendances.reduce((a, b) =>
            a.difference(now).abs() < b.difference(now).abs() ? a : b);
        String formattedDate =
            DateFormat('EEEE, MMMM d @ h:mm aa').format(closetsDateTimeToNow);
        List<DateTime> attendances = possibleAttendances.where((date) {
          return date.isBefore(DateTime.now());
        }).toList();
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: StreamBuilder<List<Attendance>>(
              stream: null,
              builder: (context, snapshot) {
                return ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: attendances.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const WelcomeHeader(),
                          const Divider(),
                          const ListTile(
                            title: Text("Instructions:"),
                            subtitle: Text(
                                "1) Check in when you arrive at practice\n2) Check out if you leave early\n3) If you are late to practice or leave early, provide a reason\n4) Any issues? Contact one of the coaches ASAP"),
                          ),
                          const Divider(),
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Today's Attendance",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const Divider(),
                                  ListTile(
                                    title: Text(formattedDate),
                                    trailing: ElevatedButton.icon(
                                      onPressed: () {
                                        DateTime now = DateTime.now();
                                        final closetsDateTimeToNow =
                                            possibleAttendances.reduce((a, b) =>
                                                a.difference(now).abs() <
                                                        b.difference(now).abs()
                                                    ? a
                                                    : b);

                                        if (now.isBefore(closetsDateTimeToNow
                                                .add(const Duration(
                                                    hours: 2))) &&
                                            now.isAfter(closetsDateTimeToNow
                                                .subtract(const Duration(
                                                    minutes: 15)))) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Check In To Practice"),
                                              content: const Text(
                                                  "Please only check in when you have arrived at the gym. Have you arrived at the fencing gym?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      context.popRoute(),
                                                  child:
                                                      const Text("No, cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {},
                                                  child: const Text(
                                                      "Yes, check in"),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (now.isBefore(
                                            closetsDateTimeToNow.subtract(
                                                const Duration(minutes: 15)))) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Too Early For Check In"),
                                              content: const Text(
                                                  "You cannot check in for attendance before practice has started. Make sure it is time for practice before you try checking in again."),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        context.popRoute(),
                                                    child: const Text(
                                                      "Understood",
                                                    ))
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.check),
                                      label: const Text("Check In"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Text(
                            "Previous Attendance",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      );
                    } else if (index == attendances.length + 1) {
                      return OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Text("Sign Out"),
                        label: const Icon(Icons.logout),
                      );
                    } else {
                      index--;
                      DateTime date = attendances.reversed.toList()[index];
                      String formattedDate =
                          DateFormat('EEEE, MMMM d @ h:mm aa').format(date);
                      return ListTile(
                        title: Text(formattedDate),
                        subtitle: const Text("Checked in: 6:03 PM"),
                      );
                    }
                  },
                  separatorBuilder: (context, index) =>
                      index == 0 ? Container() : const Divider(),
                );
              }),
          floatingActionButton: userData.admin
              ? FloatingActionButton(
                  onPressed: () => context.pushRoute(const AddPracticesRoute()),
                  child: const Icon(Icons.add),
                )
              : null,
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
