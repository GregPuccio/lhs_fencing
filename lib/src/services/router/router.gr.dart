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
    AuthRoute.name: (routeData) {
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: const AuthPage(),
      );
    }
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(
          AuthRoute.name,
          path: '/',
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
/// [AuthPage]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute()
      : super(
          AuthRoute.name,
          path: '/',
        );

  static const String name = 'AuthRoute';
}
