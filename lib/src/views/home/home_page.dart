import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/views/home/attendance_view.dart';
import 'package:lhs_fencing/src/views/home/home_view.dart';
import 'package:lhs_fencing/src/views/home/profile_view.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeView(),
          AttendanceView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) => setState(() => currentIndex = value),
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: "Practice"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Past Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
