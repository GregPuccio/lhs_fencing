import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';

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
    return Scaffold(
      body: SizedBox(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: ListView(
                children: [
                  Image.asset(
                    "assets/images/tournado_logo2.png",
                    height: 300,
                  ),
                  TextFormField(
                    controller: email,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (isNewUser) ...[
                    TextFormField(
                      controller: newPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => newPassword.text.length > 6
                          ? null
                          : "Password needs to be 6 characters",
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      controller: repeatNewPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: const InputDecoration(
                        labelText: "Repeat New Password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          repeatNewPassword.text == newPassword.text
                              ? null
                              : "New passwords need to match",
                      onEditingComplete: tryCompleteForm,
                    ),
                  ] else ...[
                    TextFormField(
                      obscureText: obscurePass,
                      controller: password,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () => setState(() {
                                  obscurePass = !obscurePass;
                                }),
                            icon: Icon(obscurePass
                                ? Icons.visibility
                                : Icons.visibility_off)),
                      ),
                      onEditingComplete: tryCompleteForm,
                    ),
                  ],
                  const SizedBox(
                    height: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: Theme.of(context).colorScheme.primary,
                        child: Text(isNewUser ? "Register" : "Sign In"),
                        onPressed: () async {
                          if (formKey.currentState?.validate() == true) {
                            tryCompleteForm();
                          }
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isNewUser = !isNewUser;
                          });
                        },
                        child: Text(isNewUser
                            ? "Already have an account?"
                            : "No Account?"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
