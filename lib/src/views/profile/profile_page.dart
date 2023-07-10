import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';

class ProfilePage extends ConsumerWidget {
  final UserData userData;
  final List<Practice> practices;
  final List<Attendance> attendances;
  const ProfilePage(
      {required this.practices,
      required this.attendances,
      required this.userData,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeController controller = ref.watch(themeControllerProvider);

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

    return ListView(
      children: [
        const ListTile(
          title: Text("A2016"),
          subtitle: Text("USA Fencing Rating"),
        ),
        const ListTile(
          title: Text("11 Years"),
          subtitle: Text("Years of Experience"),
        ),
        const ListTile(
          title: Text("Forward Fencing Academy"),
          subtitle: Text("Club Affiliation"),
        ),
        const ListTile(
          title: Text("Mon, Wed, Fri"),
          subtitle: Text("Days At Club"),
        ),
        const ListTile(
          title: Text("None"),
          subtitle: Text("Food Allergies"),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text("Dark Mode"),
          trailing: Switch.adaptive(
              value: controller.themeMode == ThemeMode.dark,
              onChanged: (val) {
                controller.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
              }),
        ),
        ListTile(
          title: const Text("Need to leave?"),
          trailing: OutlinedButton.icon(
            onPressed: logOff,
            icon: const Text("Sign Out"),
            label: const Icon(Icons.logout),
          ),
        )
      ],
    );
  }
}
