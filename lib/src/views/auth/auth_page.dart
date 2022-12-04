import 'package:auto_route/auto_route.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lhs_fencing/google_keys.dart';
import 'package:lhs_fencing/src/constants/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/router/router.dart';

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

  void tryCompleteForm() async {
    if (isNewUser) {
      dynamic result =
          await AuthService().register(email.text, newPassword.text);
      if (result.runtimeType == String) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result as String)),
          );
        }
      }
    } else {
      dynamic result = await AuthService().signIn(email.text, password.text);
      if (result.runtimeType == String) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result as String)),
          );
        }
      }
    }
    TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    return AuthStateListener(
      listener: (oldState, newState, controller) {
        if (newState is SignedIn) {
          context.router.push(const HomeRoute());
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: defaultAppBar,
        body: SizedBox(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Welcome to the Livingston Highschool Fencing Team's Attendance App.",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "This will give you access to your past attendance as well as the ability to sign in when you are at practice.",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OAuthProviderButton(
                  provider: GoogleProvider(clientId: googleClientID),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
