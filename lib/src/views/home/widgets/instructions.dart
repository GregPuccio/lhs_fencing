import 'package:flutter/material.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Instructions:"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("1) Check in when you arrive at practice"),
          Text("2) Check out if you leave early"),
          Text(
              "3) If you are late to practice or leave early, provide a reason"),
          Text("4) Any issues? Contact one of the coaches ASAP")
        ],
      ),
    );
  }
}
