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
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

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

    Future getWebsiteData() async {
      final url = Uri.parse(
          'https://member.usafencing.org/search/members?first=${userData.firstName}&last=${userData.lastName}&division=&inactive=true&country=&id=#find');
      final response = await http.get(
        url,
        headers: {"content-type": "html"},
      );
      dom.Document html = dom.Document.html(response.body);
      final titles = html
          .querySelectorAll(
              '#search > div > div > table > tbody > tr:nth-child(2) > td:nth-child(1)')
          .map((e) => e.innerHtml.trim())
          .toList();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Count: ${titles.length}')));
      for (final title in titles) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(title)));
      }
    }

    getWebsiteData();
    return ListView(
      children: [
        ListTile(
          title: Text(
            userData.fullName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "${userData.admin ? "Coach" : userData.schoolYear.type} | ${userData.weapon.type} Fencer | ${userData.team == Team.both ? userData.team.type : "${userData.team.type} Team"}",
            textAlign: TextAlign.center,
          ),
        ),
        const ListTile(
          title: Text("A2016"),
          subtitle: Text("USA Fencing Rating"),
        ),
        ListTile(
          title: Text("${userData.yoe} Year${userData.yoe == 1 ? "" : "s"}"),
          subtitle: const Text("Years of Experience"),
        ),
        const ListTile(
          title: Text("Forward Fencing Academy"),
          subtitle: Text("Club Affiliation"),
        ),
        ListTile(
          title: Text(userData.clubDays.join(", ")),
          subtitle: const Text("Days At Club"),
        ),
        ListTile(
          title: Text(userData.foodAllergies.join(", ")),
          subtitle: const Text("Food Allergies"),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text("Follow System Theming"),
          trailing: Switch.adaptive(
              value: controller.themeMode == ThemeMode.system,
              onChanged: (val) {
                controller
                    .setThemeMode(val ? ThemeMode.system : ThemeMode.light);
              }),
        ),
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
