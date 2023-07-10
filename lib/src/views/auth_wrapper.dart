import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/home_structure.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
import 'package:lhs_fencing/src/views/auth/auth_page.dart';
import 'package:lhs_fencing/src/views/admin/admin_home_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class AuthWrapperPage extends ConsumerWidget {
  const AuthWrapperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenUserData(UserData? userData, User user) {
      if (userData != null) {
        if (userData.admin) {
          return const AdminHomePage();
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
