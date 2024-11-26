import 'package:auto_route/auto_route.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/theming/app_color.dart';
import 'package:lhs_fencing/src/constants/theming/app_data.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required this.themeController,
  });

  final ThemeController themeController;
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, Widget? child) {
        return ProviderScope(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: _appRouter.config(
              deepLinkBuilder: (deepLink) {
                return DeepLink.defaultPath;
              },
            ),
            // routerDelegate: _appRouter.delegate(),
            // routeInformationParser: _appRouter.defaultRouteParser(),
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) => "Livingston Fencing",

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: FlexThemeData.light(
              useMaterial3: true,
              useMaterial3ErrorColors: true,
              // We moved the definition of the list of color schemes to use into
              // a separate static class and list. We use the theme controller
              // to change the index of used color scheme from the list.
              colors: AppColor.schemes[14].light,
              // Here we use another surface blend mode, where the scaffold
              // background gets a strong blend. This type is commonly used
              // on web/desktop when you wrap content on the scaffold in a
              // card that has a lighter background.
              surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
              // Our content is not all wrapped in cards in this demo, so
              // we keep the blend level fairly low for good contrast.
              blendLevel: 5,
              appBarElevation: 0.5,
              subThemesData: const FlexSubThemesData(),
              // In this example we use the values for visual density and font
              // from a single static source, so we can change it easily there.
              visualDensity: AppData.visualDensity,
              fontFamily: AppData.font,
            ),
            darkTheme: FlexThemeData.dark(
              useMaterial3: true,
              useMaterial3ErrorColors: true,
              // We moved the definition of the list of color schemes to use into
              // a separate static class and list. We use the theme controller
              // to change the index of used color scheme from the list.
              colors: AppColor.schemes[14].dark,
              // Here we use another surface blend mode, where the scaffold
              // background gets a strong blend. This type is commonly used
              // on web/desktop when you wrap content on the scaffold in a
              // card that has a lighter background.
              surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
              // Our content is not all wrapped in cards in this demo, so
              // we keep the blend level fairly low for good contrast.
              blendLevel: 5,
              appBarElevation: 0.5,
              subThemesData: const FlexSubThemesData(),
              // In this example we use the values for visual density and font
              // from a single static source, so we can change it easily there.
              visualDensity: AppData.visualDensity,
              fontFamily: AppData.font,
            ),
            themeMode: themeController.themeMode,
          ),
        );
      },
    );
  }
}
