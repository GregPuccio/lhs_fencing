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
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

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
      try {
        final url = Uri.https('member.usafencing.org', '/search/members', {
          'first': userData.firstName,
          'last': userData.lastName,
          'division': '',
          'inactive': 'true',
          'country': '',
          'id': '',
        });
        final response = await http.get(
          url,
          headers: {
            "Origin": "https://lhsfencing.web.app",
            "Referer": "https://lhsfencing.web.app",
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36",
            "Access-Control-Request-Headers": "Content-Type, Authorization",
            "Access-Control-Request-Method": "GET",
            "X-Requested-With": "XMLHttpRequest",
            "Access-Control-Allow-Origin": "https://lhsfencing.web.app",
            "Content-Type": "text/plain",
          },
        );
        dom.Document html = dom.Document.html(response.body);
        final titles = html
            .querySelectorAll('tr[itemprop]="member"')
            .map((e) => e.innerHtml.trim())
            .toList();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Count: ${titles.length}')));
        for (final title in titles) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(title)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
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
        const Divider(),
        ListTile(
          title: Text(userData.rating),
          subtitle: const Text("USA Fencing Rating"),
        ),
        ListTile(
          title: Text(
              "${userData.startDate.difference(DateTime.now()).inDays / 365} Years"),
          subtitle: const Text("Years of Experience"),
        ),
        ListTile(
          title: Text(userData.club),
          subtitle: const Text("Club Affiliation"),
        ),
        ListTile(
          title: Text(userData.clubDays.isEmpty
              ? "None"
              : userData.clubDays.join(", ")),
          subtitle: const Text("Days At Club"),
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
