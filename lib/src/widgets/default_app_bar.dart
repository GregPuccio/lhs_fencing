import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';
import 'package:lhs_fencing/src/widgets/livingston_logo.dart';

class DefaultAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeController controller = ref.watch(themeControllerProvider);
    return AppBar(
      leading: livingstonLogo,
      title: const Text("LHS Fencing Attendance"),
      actions: [
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            controller.setThemeMode(controller.themeMode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
