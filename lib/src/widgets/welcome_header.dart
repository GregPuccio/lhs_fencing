import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class WelcomeHeader extends ConsumerStatefulWidget {
  const WelcomeHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends ConsumerState<WelcomeHeader> {
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
    void logOff() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sign Out"),
          content: const Text("Are you sure you would like to sign out?"),
          actions: [
            TextButton(
              onPressed: () => context.popRoute(),
              child: const Text("No, cancel"),
            ),
            TextButton(
              onPressed: () async {
                AuthService().signOut();
                context.router.pop();
              },
              child: const Text("Yes, sign out"),
            ),
          ],
        ),
      );
    }

    Widget whenData(UserData? userData) {
      if (userData != null) {
        int hour = DateTime.now().hour;
        String tod = hour < 12
            ? "Morning"
            : hour < 18
                ? "Afternoon"
                : "Evening";
        return ListTile(
          title: Text("Good $tod, ${userData.firstName}"),
          subtitle: Text("It is currently $formattedTime"),
          trailing: OutlinedButton.icon(
            onPressed: logOff,
            icon: const Text("Sign Out"),
            label: const Icon(Icons.logout),
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
