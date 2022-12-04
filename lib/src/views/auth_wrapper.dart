import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
import 'package:lhs_fencing/src/views/auth/auth_page.dart';
import 'package:lhs_fencing/src/views/home/home_page.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class AuthWrapperPage extends ConsumerWidget {
  const AuthWrapperPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenUserData(UserData? userData) {
      return const HomePage();
    }

    Widget whenData(User? user) {
      if (user != null) {
        return ref.watch(userDataProvider).when(
              data: whenUserData,
              error: (obj, stkTrce) => AccountSetupPage(user: user),
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
