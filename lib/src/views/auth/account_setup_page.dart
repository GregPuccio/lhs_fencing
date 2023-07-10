import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
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
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Welcome to the '23-'24 Season!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),
                const Text(
                  'Please fill out all fields below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: "First Name"),
                        initialValue: userData.firstName,
                        onChanged: (value) => setState(() {
                          userData.firstName = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
                        initialValue: userData.lastName,
                        onChanged: (value) => setState(() {
                          userData.lastName = value;
                        }),
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
                const Divider(),
                ListTile(
                  title: const Text("School Year"),
                  trailing: DropdownButton(
                    value: userData.schoolYear,
                    items: List.generate(
                      SchoolYear.values.length,
                      (index) => DropdownMenuItem(
                        value: SchoolYear.values[index],
                        child: Text(SchoolYear.values[index].type),
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      if (value != null) {
                        userData.schoolYear = value;
                      }
                    }),
                  ),
                ),
                ListTile(
                  title: const Text("Team"),
                  trailing: ToggleButtons(
                    isSelected: List.generate(
                        Team.values.length - 1,
                        (index) =>
                            userData.team.type == Team.values[index].type),
                    children: List.generate(
                      Team.values.length - 1,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(Team.values[index].type),
                      ),
                    ),
                    onPressed: (index) => setState(() {
                      userData.team = Team.values[index];
                    }),
                  ),
                ),
                ListTile(
                  title: const Text("Weapon"),
                  trailing: ToggleButtons(
                    isSelected: List.generate(
                        Weapon.values.length,
                        (index) =>
                            userData.weapon.type == Weapon.values[index].type),
                    children: List.generate(
                      Weapon.values.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(Weapon.values[index].type),
                      ),
                    ),
                    onPressed: (index) => setState(() {
                      userData.weapon = Weapon.values[index];
                    }),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            labelText: "Club Affiliation",
                            hintText: "V Fencing, Lilov, Wanglei etc."),
                        initialValue: userData.club,
                        onChanged: (value) => setState(() {
                          userData.club = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                            labelText: "Rating", hintText: "U, C22, A23, etc."),
                        initialValue: userData.club,
                        onChanged: (value) => setState(() {
                          userData.club = value;
                        }),
                      ),
                    )
                  ],
                ),
                if (userData.club.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text("Club Days"),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ToggleButtons(
                          isSelected: List.generate(
                              DayOfWeek.values.length,
                              (index) => userData.clubDays
                                  .contains(DayOfWeek.values[index])),
                          children: List.generate(
                            DayOfWeek.values.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(DayOfWeek.values[index].abbreviation),
                            ),
                          ),
                          onPressed: (index) => setState(() {
                            DayOfWeek dow = DayOfWeek.values[index];
                            if (userData.clubDays.contains(dow)) {
                              userData.clubDays.remove(dow);
                            } else {
                              userData.clubDays.add(dow);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
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
                  label: const Text("Save My Information"),
                ),
                const SizedBox(height: 32),
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
