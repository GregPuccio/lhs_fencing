import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/google_keys.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

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
              Text(
                "Welcome to the LHS Fencing Team's Attendance App",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Please use this app to check in at all practices and team related events.",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OAuthProviderButton(
                provider: GoogleProvider(clientId: googleClientID),
              ),
              Text(
                "Make sure to use your school email when signing in!",
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
