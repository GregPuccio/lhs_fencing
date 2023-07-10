import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/widgets/livingston_logo.dart';

class DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showInstructions;
  const DefaultAppBar({this.showInstructions = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: livingstonLogo,
      title: const Text("LHS Fencing Attendance"),
      actions: [
        if (showInstructions)
          IconButton(
            onPressed: () => showDialog(
                context: context, builder: (context) => const Instructions()),
            icon: const Icon(Icons.help),
          )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
