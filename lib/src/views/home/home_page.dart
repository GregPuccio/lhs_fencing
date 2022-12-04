import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/home/welcome_header.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: StreamBuilder<List<Attendance>>(
              stream: null,
              builder: (context, snapshot) {
                return ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: 10,
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
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: const TextBadge(text: "Today"),
                          ),
                          ListTile(
                            title: Text("Attendance: $formattedDate"),
                            trailing: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check),
                              label: const Text("Check In"),
                            ),
                          ),
                          const Divider(),
                          Text(
                            "Past Attendance",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      );
                    } else if (index == 10 - 1) {
                      return OutlinedButton.icon(
                        onPressed: () => AuthService().signOut(),
                        icon: const Text("Sign Out"),
                        label: const Icon(Icons.logout),
                      );
                    } else {
                      index--;
                      return ListTile(
                        title: Text("Attendance: $formattedDate"),
                        subtitle: const Text("Checked in: 6:03 PM"),
                      );
                    }
                  },
                  separatorBuilder: (context, index) =>
                      index == 0 ? Container() : const Divider(),
                );
              }),
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
