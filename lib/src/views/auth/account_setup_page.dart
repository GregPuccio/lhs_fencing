import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  final User user;
  const AccountSetupPage({required this.user, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetupPage> {
  late UserData userData;

  @override
  void initState() {
    userData = UserData.create(widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(User? user) {
      if (user == null) {
        return const LoadingPage();
      } else {
        return Scaffold(
          appBar: const DefaultAppBar(),
          body: SizedBox(
            width: 600,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
              children: [
                const Text(
                  'Welcome to LHS Fencing!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),
                const Text(
                  'Please confirm the information for your account below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "First Name"),
                        initialValue: userData.firstName,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
                        initialValue: userData.lastName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Email Address"),
                  initialValue: user.email,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // if (user.email != null &&
                    //     (user.email!.contains("livingston") ||
                    //         user.email!.contains("lps"))) {
                    FirestoreService.instance.setData(
                      path: FirestorePath.user(user.uid),
                      data: userData.toMap(),
                    );
                    // } else {
                    //   showDialog(
                    //     context: context,
                    //     builder: (context) => AlertDialog(
                    //       title: const Text("Unrecognized Email"),
                    //       content: const Text(
                    //           "Only use your Livingston email address to log in. No other addresses can be recognized at this time."),
                    //       actions: [
                    //         TextButton(
                    //           onPressed: () => context.popRoute(),
                    //           child: const Text(
                    //             "Understood",
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Confirm My Information"),
                ),
                const SizedBox(height: 60),
                const Divider(),
                ListTile(
                  title: const Text("Need to come back later?"),
                  trailing: OutlinedButton.icon(
                    onPressed: () => AuthService().signOut(),
                    icon: const Text("Sign Out"),
                    label: const Icon(Icons.logout),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return ref.watch(authStateChangesProvider).when(
          data: whenData,
          error: (obj, stkTrce) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
