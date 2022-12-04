import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text(
      "You are now logged in!\nThis page will soon have the ability to allow you to sign in to practice.",
    );
  }
}
