import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/firestore/functions/get_fencing_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/default_app_bar.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/image_assets.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  final User? user;
  final UserData? userData;
  const AccountSetupPage({required this.user, this.userData, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetupPage> {
  late UserData userData;
  late TextEditingController usaFencingIDController;
  late TextEditingController clubController;
  late TextEditingController ratingController;
  bool loadingData = false;

  @override
  void initState() {
    userData = widget.userData != null
        ? UserData.fromJson(widget.userData!.toJson())
        : widget.user != null
            ? UserData.create(widget.user!)
            : UserData.noUserCreate();
    usaFencingIDController = TextEditingController(text: userData.usaFencingID);
    clubController = TextEditingController(text: userData.club);
    ratingController = TextEditingController(text: userData.rating);
    super.initState();
  }

  void updateWithLastYearsInfo(UserData lastYearUser) {
    setState(() {
      userData.firstName = lastYearUser.firstName;
      userData.lastName = lastYearUser.lastName;
      userData.schoolYear = SchoolYear.values[lastYearUser.schoolYear.index -
          1 +
          (lastYearUser.schoolYear.index > SchoolYear.values.length ? 0 : 1)];
      userData.team = lastYearUser.team;
      userData.weapon = lastYearUser.weapon;
      usaFencingIDController.text = lastYearUser.usaFencingID;
      userData.usaFencingID = lastYearUser.usaFencingID;
      clubController.text = lastYearUser.club;
      userData.club = lastYearUser.club;
      ratingController.text = lastYearUser.rating;
      userData.rating = lastYearUser.rating;
      userData.clubDays = lastYearUser.clubDays;
      userData.startDate = lastYearUser.startDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(User? user) {
      if (user == null) {
        return const LoadingPage();
      } else {
        UserData? lastYearUser =
            ref.watch(lastSeasonUserDataProvider).asData?.value;
        bool adminEditor = ref.watch(userDataProvider).value?.admin ?? false;
        return WillPopScope(
          onWillPop: () async {
            if (widget.userData == userData || widget.user == null) {
              return true;
            } else {
              return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("Unsaved Changes"),
                        content: const Text(
                            "Please note that you have unsaved changes, please choose an option below."),
                        actions: [
                          TextButton(
                            onPressed: () => context.maybePop(true),
                            child: const Text("Discard Changes"),
                          ),
                          TextButton(
                            onPressed: () => FirestoreService.instance
                                .updateData(
                                  path: FirestorePath.user(userData.id),
                                  data: userData.toMap(),
                                )
                                .then(
                                  (value) => context.mounted
                                      ? context.maybePop(true).then(
                                            (value) => context.mounted
                                                ? ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Profile Updated Successfully!"),
                                                    ),
                                                  )
                                                : 0,
                                          )
                                      : 0,
                                ),
                            child: const Text("Save Changes"),
                          ),
                        ],
                      )).then((value) => value ?? false);
            }
          },
          child: Scaffold(
            appBar: DefaultAppBar(
                editUser: widget.userData != null || widget.user == null),
            body: SizedBox(
              width: 600,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.userData == null && widget.user != null) ...[
                    const Text(
                      "Welcome to the 2024-25 Season!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25),
                    ),
                    const Text(
                      'Please fill out the fields below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    if (lastYearUser != null && widget.userData == null) ...[
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.info_outline,
                            color: Theme.of(context).primaryColor),
                        title: const Text("Returning Fencer?"),
                        subtitle: const Text(
                            "Welcome back! Tap here to pull last year's account info."),
                        trailing: Icon(Icons.refresh,
                            color: Theme.of(context).primaryColor),
                        onTap: () => updateWithLastYearsInfo(lastYearUser),
                      ),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
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
                    enabled: widget.user == null,
                    decoration:
                        const InputDecoration(labelText: "Email Address"),
                    initialValue: userData.email,
                    onChanged: (value) => setState(() {
                      userData.email = value;
                    }),
                  ),
                  const SizedBox(height: 8),
                  if (adminEditor) ...[
                    const Divider(),
                    CheckboxListTile.adaptive(
                        title: const Text("Active"),
                        value: userData.active,
                        onChanged: (value) {
                          setState(() {
                            userData.active = value ?? false;
                          });
                        }),
                    const SizedBox(height: 8),
                  ],
                  if (user.email!.contains("lps") ||
                      (widget.user?.email?.contains("livingston") ??
                          false)) ...[
                    const Divider(),
                    ListTile(
                      title: const Text("School Year"),
                      trailing: DropdownButton(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                  ],
                  ListTile(
                    title: const Text("Weapon"),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          isSelected: List.generate(
                              Weapon.values.length -
                                  (adminEditor ||
                                          widget.userData?.weapon ==
                                              Weapon.manager
                                      ? 0
                                      : 1),
                              (index) =>
                                  userData.weapon.type ==
                                  Weapon.values[index].type),
                          children: List.generate(
                            Weapon.values.length -
                                (adminEditor ||
                                        widget.userData?.weapon ==
                                            Weapon.manager
                                    ? 0
                                    : 1),
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(Weapon.values[index].type),
                            ),
                          ),
                          onPressed: (index) => setState(() {
                            userData.weapon = Weapon.values[index];
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: usaFencingIDController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "USA Fencing ID",
                        hintText: "(not required)"),
                    onChanged: (value) => setState(() {
                      userData.usaFencingID = value;
                    }),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: usaFencingLogo,
                    title: const Text("USA Fencing Member?"),
                    subtitle: Text(
                        "Tap here to pull your USA Fencing info.\nWe will search using your ${userData.usaFencingID.length == 9 ? "USA Fencing ID" : "first and last name, if you dont provide your ID,"} and selected weapon."),
                    trailing: loadingData
                        ? const CircularProgressIndicator.adaptive()
                        : Icon(Icons.download,
                            color: Theme.of(context).primaryColor),
                    onTap: !loadingData
                        ? () {
                            if (userData.weapon == Weapon.unsure ||
                                userData.weapon == Weapon.manager) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Weapon Not Set"),
                                        content: const Text(
                                            "Please select a weapon from the buttons above.\nWithout your weapon information, we will not be able to retrieve your membership information correctly."),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Close"),
                                          )
                                        ],
                                      ));
                              return;
                            }
                            setState(() {
                              loadingData = true;
                            });

                            getFencingData(userData, context,
                                    settingUp: widget.userData == null)
                                .then((value) {
                              if (value == null && context.mounted) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text(
                                              "No Membership Data Found"),
                                          content: Text(
                                              "${widget.userData == null ? "Make sure that your first and last names are the spelt the same way as your registered name on USA Fencing or try using your USA Fencing ID." : "Make sure you are using a valid USA Fencing ID"}\n\nIf you do not have USA Fencing Membership you can leave these fields blank."),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Close"),
                                            )
                                          ],
                                        ));
                                setState(() {
                                  loadingData = false;
                                });
                              } else {
                                if (userData.usaFencingID.isEmpty &&
                                        value?.club != userData.club ||
                                    value?.rating != userData.rating) {
                                  if (context.mounted) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Membership Data Found!"),
                                              content: Text(
                                                  "Member ID: ${value?.usaFencingID}\nClub: ${value?.club}\n${userData.weapon.type} Rating: ${value?.rating}\n\nIf this is not you, please enter and use your USA Fencing ID to update your data."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Close"),
                                                )
                                              ],
                                            ));
                                  }
                                }
                                setState(() {
                                  usaFencingIDController.text = userData
                                      .usaFencingID = value!.usaFencingID;
                                  clubController.text =
                                      userData.club = value.club;
                                  ratingController.text =
                                      userData.rating = value.rating;
                                  loadingData = false;
                                });
                              }
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: TextFormField(
                          controller: clubController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              labelText: "Club Affiliation",
                              hintText: "V Fencing, Lilov, Wanglei etc."),
                          onChanged: (value) => setState(() {
                            userData.club = value;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextFormField(
                          controller: ratingController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                              labelText: "Rating",
                              hintText: "U, C22, A23, etc."),
                          onChanged: (value) => setState(() {
                            userData.rating = value;
                          }),
                        ),
                      ),
                    ],
                  ),
                  if (userData.club.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text("Typical Days At Club"),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                child:
                                    Text(DayOfWeek.values[index].abbreviation),
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
                    const SizedBox(height: 8),
                    ListTile(
                        title: const Text("When Did You Start Fencing?"),
                        subtitle: const Text("Tap here to change"),
                        trailing: Text(
                          DateFormat('MM/dd/yyyy').format(userData.startDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onTap: () async {
                          DateTime now = DateTime.now();
                          DateTime? retVal = await showDatePicker(
                            initialEntryMode: DatePickerEntryMode.input,
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(now.year - 18),
                            lastDate: now,
                          );
                          if (retVal != null) {
                            setState(() {
                              userData.startDate = retVal;
                            });
                          }
                        }),
                  ],
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (user.email != null &&
                          (user.email!.contains("livingston") ||
                              user.email!.contains("lps"))) {
                        userData.clubDays
                            .sort((a, b) => a.weekday.compareTo(b.weekday));
                        if (lastYearUser != null) {
                          userData.equipment = lastYearUser.equipment;
                        }
                        if (widget.userData != null) {
                          FirestoreService.instance
                              .updateData(
                            path: FirestorePath.user(widget.userData!.id),
                            data: userData.toMap(),
                          )
                              .then((value) {
                            userData = widget.userData!;
                            return context.mounted
                                ? context.maybePop().then(
                                      (value) => context.mounted
                                          ? ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Profile Updated Successfully!"),
                                              ),
                                            )
                                          : 0,
                                    )
                                : 0;
                          });
                        } else if (widget.user != null) {
                          FirestoreService.instance.setData(
                            path: FirestorePath.user(user.uid),
                            data: userData.toMap(),
                          );
                        } else {
                          FirestoreService.instance
                              .setData(
                            path: FirestorePath.user(userData.id),
                            data: userData.toMap(),
                          )
                              .then((value) {
                            return context.mounted
                                ? context.maybePop().then(
                                      (value) => context.mounted
                                          ? ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Fencer Profile Created Successfully!"),
                                              ),
                                            )
                                          : 0,
                                    )
                                : 0;
                          });
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Unrecognized Email"),
                            content: const Text(
                                "Only use your Livingston email address to log in. No other addresses can be recognized at this time."),
                            actions: [
                              TextButton(
                                onPressed: () => context.maybePop(),
                                child: const Text(
                                  "Understood",
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: Text(
                        "${widget.userData == null ? "Save" : "Update"} My Information"),
                  ),
                  // if (adminEditor) ...[
                  //   const Divider(),
                  //   ListTile(
                  //     title: const Text("No Longer On Our Team?"),
                  //     trailing: OutlinedButton.icon(
                  //       style: OutlinedButton.styleFrom(
                  //           side: BorderSide(
                  //               color: Theme.of(context).colorScheme.error),
                  //           foregroundColor:
                  //               Theme.of(context).colorScheme.error),
                  //       onPressed: () => showDialog(
                  //           context: context,
                  //           builder: (context) {
                  //             return AlertDialog(
                  //               title: const Text("Delete Account?"),
                  //               content: const Text(
                  //                   "Please note this CAN NOT be undone!\nThe student will need to create a new profile for this season and will not be able to link into bouts or attendances that previously existed.\nThis will NOT delete the bouts of other students who have fenced with this student."),
                  //               actions: [
                  //                 TextButton(
                  //                   onPressed: () =>
                  //                       AuthService().deleteAccount(),
                  //                   child: const Text("Delete Account"),
                  //                 ),
                  //                 TextButton(
                  //                   onPressed: () => context.maybePop(),
                  //                   child: const Text("Cancel"),
                  //                 ),
                  //               ],
                  //             );
                  //           }),
                  //       icon: const Text("Delete Account"),
                  //       label: const Icon(Icons.delete_forever),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(height: 32),
                  if (widget.userData == null && widget.user != null) ...[
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
                ],
              ),
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
