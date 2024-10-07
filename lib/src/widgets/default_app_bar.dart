import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/views/home/widgets/instructions.dart';
import 'package:lhs_fencing/src/widgets/image_assets.dart';

class DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int currentIndex;
  final bool showInstructions;
  final bool editUser;
  const DefaultAppBar(
      {this.currentIndex = -1,
      this.showInstructions = false,
      this.editUser = false,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: editUser
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
              child: livingstonLogo,
            ),
      title: Column(
        children: [
          Text(editUser
              ? "Edit Profile Info"
              : currentIndex == 1
                  ? "2024-25 Fencing Calendar"
                  : currentIndex == 2
                      ? "Useful Fencing Links"
                      : currentIndex == 3
                          ? "Livingston Profile"
                          : "Livingston Fencing"),
        ],
      ),
      actions: (currentIndex == 0 && showInstructions)
          ? [
              IconButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const Instructions()),
                icon: const Icon(Icons.help),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
