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
    EditPracticeRoute.name: (routeData) {
      final args = routeData.argsAs<EditPracticeRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: EditPracticePage(
          practice: args.practice,
          key: args.key,
        ),
      );
    },
    PracticeRoute.name: (routeData) {
      final args = routeData.argsAs<PracticeRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: PracticePage(
          practiceID: args.practiceID,
          key: args.key,
        ),
      );
    },
    FencerListRoute.name: (routeData) {
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: const FencerListPage(),
      );
    },
    FencerDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<FencerDetailsRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: FencerDetailsPage(
          fencerID: args.fencerID,
          key: args.key,
        ),
      );
    },
    EditFencerStatusRoute.name: (routeData) {
      final args = routeData.argsAs<EditFencerStatusRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: EditFencerStatusPage(
          args.fencer,
          args.practice,
          attendance: args.attendance,
          key: args.key,
        ),
      );
    },
    AttendanceRoute.name: (routeData) {
      final args = routeData.argsAs<AttendanceRouteArgs>();
      return AdaptivePage<dynamic>(
        routeData: routeData,
        child: AttendancePage(
          practiceID: args.practiceID,
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
          EditPracticeRoute.name,
          path: 'editPractice',
        ),
        RouteConfig(
          PracticeRoute.name,
          path: 'practice',
        ),
        RouteConfig(
          FencerListRoute.name,
          path: 'fencerList',
        ),
        RouteConfig(
          FencerDetailsRoute.name,
          path: 'fencerDetails',
        ),
        RouteConfig(
          EditFencerStatusRoute.name,
          path: 'editFencerStatus',
        ),
        RouteConfig(
          AttendanceRoute.name,
          path: 'attendance',
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
/// [EditPracticePage]
class EditPracticeRoute extends PageRouteInfo<EditPracticeRouteArgs> {
  EditPracticeRoute({
    required Practice practice,
    Key? key,
  }) : super(
          EditPracticeRoute.name,
          path: 'editPractice',
          args: EditPracticeRouteArgs(
            practice: practice,
            key: key,
          ),
        );

  static const String name = 'EditPracticeRoute';
}

class EditPracticeRouteArgs {
  const EditPracticeRouteArgs({
    required this.practice,
    this.key,
  });

  final Practice practice;

  final Key? key;

  @override
  String toString() {
    return 'EditPracticeRouteArgs{practice: $practice, key: $key}';
  }
}

/// generated route for
/// [PracticePage]
class PracticeRoute extends PageRouteInfo<PracticeRouteArgs> {
  PracticeRoute({
    required String practiceID,
    Key? key,
  }) : super(
          PracticeRoute.name,
          path: 'practice',
          args: PracticeRouteArgs(
            practiceID: practiceID,
            key: key,
          ),
        );

  static const String name = 'PracticeRoute';
}

class PracticeRouteArgs {
  const PracticeRouteArgs({
    required this.practiceID,
    this.key,
  });

  final String practiceID;

  final Key? key;

  @override
  String toString() {
    return 'PracticeRouteArgs{practiceID: $practiceID, key: $key}';
  }
}

/// generated route for
/// [FencerListPage]
class FencerListRoute extends PageRouteInfo<void> {
  const FencerListRoute()
      : super(
          FencerListRoute.name,
          path: 'fencerList',
        );

  static const String name = 'FencerListRoute';
}

/// generated route for
/// [FencerDetailsPage]
class FencerDetailsRoute extends PageRouteInfo<FencerDetailsRouteArgs> {
  FencerDetailsRoute({
    required String fencerID,
    Key? key,
  }) : super(
          FencerDetailsRoute.name,
          path: 'fencerDetails',
          args: FencerDetailsRouteArgs(
            fencerID: fencerID,
            key: key,
          ),
        );

  static const String name = 'FencerDetailsRoute';
}

class FencerDetailsRouteArgs {
  const FencerDetailsRouteArgs({
    required this.fencerID,
    this.key,
  });

  final String fencerID;

  final Key? key;

  @override
  String toString() {
    return 'FencerDetailsRouteArgs{fencerID: $fencerID, key: $key}';
  }
}

/// generated route for
/// [EditFencerStatusPage]
class EditFencerStatusRoute extends PageRouteInfo<EditFencerStatusRouteArgs> {
  EditFencerStatusRoute({
    required UserData fencer,
    required Practice practice,
    Attendance? attendance,
    Key? key,
  }) : super(
          EditFencerStatusRoute.name,
          path: 'editFencerStatus',
          args: EditFencerStatusRouteArgs(
            fencer: fencer,
            practice: practice,
            attendance: attendance,
            key: key,
          ),
        );

  static const String name = 'EditFencerStatusRoute';
}

class EditFencerStatusRouteArgs {
  const EditFencerStatusRouteArgs({
    required this.fencer,
    required this.practice,
    this.attendance,
    this.key,
  });

  final UserData fencer;

  final Practice practice;

  final Attendance? attendance;

  final Key? key;

  @override
  String toString() {
    return 'EditFencerStatusRouteArgs{fencer: $fencer, practice: $practice, attendance: $attendance, key: $key}';
  }
}

/// generated route for
/// [AttendancePage]
class AttendanceRoute extends PageRouteInfo<AttendanceRouteArgs> {
  AttendanceRoute({
    required String practiceID,
    Key? key,
  }) : super(
          AttendanceRoute.name,
          path: 'attendance',
          args: AttendanceRouteArgs(
            practiceID: practiceID,
            key: key,
          ),
        );

  static const String name = 'AttendanceRoute';
}

class AttendanceRouteArgs {
  const AttendanceRouteArgs({
    required this.practiceID,
    this.key,
  });

  final String practiceID;

  final Key? key;

  @override
  String toString() {
    return 'AttendanceRouteArgs{practiceID: $practiceID, key: $key}';
  }
}
