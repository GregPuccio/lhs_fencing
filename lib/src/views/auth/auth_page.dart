import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/google_keys.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isNewUser = true;
  bool obscurePass = false;
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController newPassword;
  late TextEditingController repeatNewPassword;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    newPassword = TextEditingController();
    repeatNewPassword = TextEditingController();
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    newPassword.dispose();
    repeatNewPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  "Welcome to the Livingston Fencing Team's Attendance App!",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                title: Row(children: [
                  Icon(Icons.check, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text("Attendance:"),
                ]),
                subtitle: const Text(
                  "This site will be used to keep track of all attendances.\nIf you encounter any issues be sure to reach out to a coach immediately.",
                ),
              ),
              const Divider(),
              ListTile(
                title: Row(children: [
                  Icon(Icons.calendar_month,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text("Schedule:"),
                ]),
                subtitle: const Text(
                  "This site is updated frequently to keep you informed about practices and team related events.",
                ),
              ),
              const Divider(),
              ListTile(
                title: Row(children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text("Information:"),
                ]),
                subtitle: const Text(
                  "This site countains a list of links that can be used to help you grow as a fencer and to find more tournament related info.",
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              OAuthProviderButton(
                provider: GoogleProvider(clientId: googleClientID),
              ),
              Text(
                "Be sure to sign in using your school email address.",
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
