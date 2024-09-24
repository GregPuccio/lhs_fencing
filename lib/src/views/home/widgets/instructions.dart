import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Instructions"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("1) Check in when you arrive at any events"),
          Text("2) Check out when you are leaving"),
          Text(
              "3) If you are late to any events or have to leave early, provide a reason"),
          Text("4) Any issues? Contact one of the coaches ASAP")
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.maybePop(),
          child: const Text("Got It!"),
        )
      ],
    );
  }
}
