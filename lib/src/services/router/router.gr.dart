// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    AuthWrapperRoute.name: (routeData) {
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: const AuthWrapperPage(),
      );
    },
    AddPracticesRoute.name: (routeData) {
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: const AddPracticesPage(),
      );
    },
    PracticeRoute.name: (routeData) {
      final args = routeData.argsAs<PracticeRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: PracticePage(
          practice: args.practice,
          key: args.key,
        ),
      );
    },
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(
          AuthWrapperRoute.name,
          path: '/',
        ),
        RouteConfig(
          AddPracticesRoute.name,
          path: 'addPractices',
        ),
        RouteConfig(
          PracticeRoute.name,
          path: 'practice',
        ),
        RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: '/',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [AuthWrapperPage]
class AuthWrapperRoute extends PageRouteInfo<void> {
  const AuthWrapperRoute()
      : super(
          AuthWrapperRoute.name,
          path: '/',
        );

  static const String name = 'AuthWrapperRoute';
}

/// generated route for
/// [AddPracticesPage]
class AddPracticesRoute extends PageRouteInfo<void> {
  const AddPracticesRoute()
      : super(
          AddPracticesRoute.name,
          path: 'addPractices',
        );

  static const String name = 'AddPracticesRoute';
}

/// generated route for
/// [PracticePage]
class PracticeRoute extends PageRouteInfo<PracticeRouteArgs> {
  PracticeRoute({
    required Practice practice,
    Key? key,
  }) : super(
          PracticeRoute.name,
          path: 'practice',
          args: PracticeRouteArgs(
            practice: practice,
            key: key,
          ),
        );

  static const String name = 'PracticeRoute';
}

class PracticeRouteArgs {
  const PracticeRouteArgs({
    required this.practice,
    this.key,
  });

  final Practice practice;

  final Key? key;

  @override
  String toString() {
    return 'PracticeRouteArgs{practice: $practice, key: $key}';
  }
}
