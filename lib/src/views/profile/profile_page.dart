import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';

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
              onPressed: () => context.maybePop(),
              child: const Text("No, cancel"),
            ),
            TextButton(
              onPressed: () async {
                AuthService().signOut();
                context.router.maybePop();
              },
              child: const Text("Yes, sign out"),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        ListTile(
          title: Text(
            userData.fullName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "${userData.admin ? "Coach" : userData.schoolYear.type} | ${userData.weapon == Weapon.manager ? "Manager" : "${userData.weapon.type} Fencer"} | ${userData.admin ? Team.both.type : userData.team == Team.both ? userData.team.type : "${userData.team.type} Team"}",
            textAlign: TextAlign.center,
          ),
        ),
        TextButton.icon(
          label: const Text("Update Profile"),
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AccountSetupPage(
                user: ref.watch(authStateChangesProvider).value!,
                userData: userData,
              ),
            ),
          ),
        ),
        ListTile(
          title: Text(userData.rating),
          subtitle: const Text("USA Fencing Rating"),
        ),
        ListTile(
          title: Text(
              "${(DateTime.now().difference(userData.startDate).inDays / 365).toStringAsFixed(1)} Years"),
          subtitle: const Text("Years of Experience"),
        ),
        ListTile(
          title: Text(userData.club.isEmpty ? "None" : userData.club),
          subtitle: const Text("Club Affiliation"),
        ),
        ListTile(
          title: Text(userData.clubDays.isEmpty
              ? "None"
              : userData.clubDays.map((e) => e.abbreviation).join(", ")),
          subtitle: const Text("Days At Club"),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text("Automatic Theme (Device Settings)"),
          trailing: Switch.adaptive(
              value: controller.themeMode == ThemeMode.system,
              onChanged: (val) {
                controller
                    .setThemeMode(val ? ThemeMode.system : ThemeMode.light);
              }),
        ),
        if (controller.themeMode != ThemeMode.system)
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Switch.adaptive(
                value: controller.themeMode == ThemeMode.dark,
                onChanged: (val) {
                  controller
                      .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                }),
          ),
        const Divider(),
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
