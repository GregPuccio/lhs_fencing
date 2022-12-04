import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/widgets/default_app_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: defaultAppBar,
      body: const Text(
        "You are now logged in!\nThis page will soon have the ability to allow you to sign in to practice as well as track your previous attendance.",
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.key), label: "Practice"),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: "Past Attendance"),
      ]),
    );
  }
}
