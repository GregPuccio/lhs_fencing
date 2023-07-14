import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/widgets/livingston_logo.dart';

class DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showInstructions;
  final bool editUser;
  const DefaultAppBar(
      {this.showInstructions = false, this.editUser = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: editUser ? null : livingstonLogo,
      title: Text(editUser ? "Edit Profile Info" : "LHS Fencing Attendance"),
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
