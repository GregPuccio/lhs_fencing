import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/admin_home_structure.dart';
import 'package:lhs_fencing/src/home_structure.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/firestore/functions/get_fencing_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
import 'package:lhs_fencing/src/views/auth/auth_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class AuthWrapperPage extends ConsumerWidget {
  const AuthWrapperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool refreshedUser = false;
    Widget whenUserData(UserData? userData, User user) {
      if (userData != null) {
        if (!refreshedUser) {
          Future.delayed(Duration.zero, () async {
            UserData? newUserData = await getFencingData(userData, context);
            if (newUserData != null &&
                (newUserData.club != userData.club ||
                    newUserData.rating != userData.rating)) {
              if (context.mounted) {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Fencing Information Update"),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                                "The following USA Fencing information has been updated:"),
                            if (newUserData.club != userData.club) ...[
                              Text(
                                "New Club: ${newUserData.club}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text("Old Club: ${userData.club}"),
                            ],
                            if (newUserData.club != userData.club &&
                                newUserData.rating != userData.rating)
                              const SizedBox(height: 8),
                            if (newUserData.rating != userData.rating) ...[
                              Text(
                                "New ${newUserData.weapon.type} Rating: ${newUserData.rating}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text("Old Rating: ${userData.rating}"),
                              const Text("\nCongrats on the new rating!")
                            ],
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              FirestoreService.instance
                                  .setData(
                                    path: FirestorePath.user(newUserData.id),
                                    data: newUserData.toMap(),
                                  )
                                  .then(
                                    (value) => context.popRoute().then(
                                          (value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                            const SnackBar(
                                              content: Text("Profile updated!"),
                                            ),
                                          ),
                                        ),
                                  );
                            },
                            child: const Text("Update my profile!"),
                          ),
                          TextButton(
                            onPressed: () {
                              context.popRoute();
                            },
                            child: const Text("Don't update"),
                          ),
                        ],
                      );
                    });
              }
            }
          });
        }
        if (userData.admin) {
          return const AdminHomeStructure();
        }
        return const HomeStructure();
      } else {
        return AccountSetupPage(user: user);
      }
    }

    Widget whenData(User? user) {
      if (user != null) {
        return ref.watch(userDataProvider).when(
              data: (userData) => whenUserData(userData, user),
              error: (obj, stkTrce) => const ErrorPage(),
              loading: () => const LoadingPage(),
            );
      } else {
        return const AuthPage();
      }
    }

    return ref.watch(authStateChangesProvider).when(
          data: whenData,
          error: (obj, stkTrce) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
