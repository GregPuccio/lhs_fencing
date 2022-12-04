import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/services/auth/auth_service.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  const AccountSetupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountSetupState();
}

class _AccountSetupState extends ConsumerState<AccountSetupPage> {
  late TextEditingController memberID;
  int currentStep = 0;
  List? list;

  @override
  void initState() {
    memberID = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Step> steps = [
      Step(
        title: const Text('Account Lookup'),
        subtitle: const Text(
            'Please enter your USA Fencing member ID below so we can look up your account'),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: memberID,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Member ID"),
                validator: (value) => value?.length == 9
                    ? null
                    : "Your ID should be 9 digits long",
              ),
            ),
          ],
        ),
      ),
      // Step(
      //   title: const Text('Account Type'),
      //   subtitle: const Text(
      //       'Please choose the account type you are setting up. You can choose more than 1!'),
      //   content: Column(
      //     children: List.generate(
      //       AccountType.values.length,
      //       (index) => CheckboxListTile(
      //         title: Text(AccountType.values[index].type),
      //         subtitle: Text(AccountType.values[index].description),
      //         value: accountTypes.contains(AccountType.values[index]),
      //         onChanged: (val) {
      //           setState(() {
      //             if (val == true) {
      //               accountTypes.add(AccountType.values[index]);
      //             } else {
      //               accountTypes.remove(AccountType.values[index]);
      //             }
      //           });
      //         },
      //       ),
      //     ),
      //   ),
      // ),
    ];
    return Scaffold(
      body: SizedBox(
        width: 800,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(top: 60),
          children: [
            const Text(
              'Welcome to Tournado!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            const Text(
              'Please complete your account set up below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            Stepper(
              physics: const NeverScrollableScrollPhysics(),
              steps: steps,
              currentStep: currentStep,
              controlsBuilder: (context, controlDetails) {
                return Row(
                  children: <Widget>[
                    if (currentStep > 0)
                      TextButton(
                        onPressed: controlDetails.onStepCancel,
                        child: const Text('Go Back'),
                      ),
                    TextButton(
                      onPressed: controlDetails.onStepContinue,
                      child: Text(currentStep > 0 ? 'Complete' : 'Search'),
                    ),
                  ],
                );
              },
              onStepCancel: () {
                if (currentStep > 0) {
                  setState(() {
                    currentStep--;
                  });
                }
              },
              onStepContinue: () {},
              onStepTapped: list != null
                  ? (val) => setState(() => currentStep = val)
                  : null,
            ),
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
