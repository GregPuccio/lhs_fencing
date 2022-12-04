import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
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
  int currentIndex = 0;
  String formattedTime = DateFormat('hh:mm aa').format(DateTime.now());
  String formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());
  }

  void _update() {
    setState(() {
      formattedTime = DateFormat('hh:mm aa').format(DateTime.now());
      formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        int hour = DateTime.now().hour;
        String tod = hour < 12
            ? "Morning"
            : hour < 18
                ? "Afternoon"
                : "Evening";
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              ListTile(
                title: Text("Good $tod, ${userData.firstName}"),
                subtitle: Text("It is currently $formattedTime"),
              ),
              const Divider(),
              const ListTile(
                title: Text("Instructions:"),
                subtitle: Text(
                    "1) Please check in when you arrive at practice\n2) Check out if you leave early\n3) If you are late to practice or leave early, provide a reason\n4) Any issues contact one of the coaches immediately"),
              ),
              const Divider(),
              const TextBadge(text: "Today"),
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
              Column(
                children: List.generate(
                    10,
                    (index) => Column(
                          children: [
                            ListTile(
                              title: Text("Attendance: $formattedDate"),
                              trailing: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check),
                                label: const Text("Check In"),
                              ),
                            ),
                            const Divider(),
                          ],
                        )),
              ),
              const Divider(),
              const Divider(),
              OutlinedButton.icon(
                onPressed: () => AuthService().signOut(),
                icon: const Text("Sign Out"),
                label: const Icon(Icons.logout),
              ),
            ],
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
