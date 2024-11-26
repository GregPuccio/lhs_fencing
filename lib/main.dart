import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/firebase_options.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';
import 'package:lhs_fencing/src/settings/theme_service.dart';
import 'package:lhs_fencing/src/settings/theme_service_hive.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';

void main() async {
  setPathUrlStrategy();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final ThemeService themeService = ThemeServiceHive('lhs_fencing_theme');
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  ThemeController themeController = ThemeController(themeService);
  // Load all the preferred theme settings, while the app is loading, before
  // MaterialApp is created. This prevents a sudden theme change when the app
  // is first displayed.
  await themeController.loadAll();
  // Run the app and pass in the ThemeController. The app listens to the
  // ThemeController for changes.

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before the app has begun as well
  // This uses the defaults for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final fcmToken = await FirebaseMessaging.instance.getToken(
  //     vapidKey:
  //         "BDhaN8AsL56jL5bUFY15FYDvbE6yaGRmtsLdg3RCgAD_a7TVYg6DbnOGCdB-DqqSlplIkTw2SBRyuIZXWXlVkj4");

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(ProviderScope(overrides: [
    themeControllerProvider.overrideWith((ref) => themeController),
  ], child: MyApp(themeController: themeController)));
}
