// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AttendanceRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<AttendanceRouteArgs>(
          orElse: () => AttendanceRouteArgs(
              practiceID: pathParams.getString('practiceID')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AttendancePage(
          practiceID: args.practiceID,
          key: args.key,
        ),
      );
    },
    EditFencerStatusRoute.name: (routeData) {
      final args = routeData.argsAs<EditFencerStatusRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditFencerStatusPage(
          args.fencer,
          args.practice,
          attendance: args.attendance,
          key: args.key,
        ),
      );
    },
    FencerListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FencerListPage(),
      );
    },
    FencerDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<FencerDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FencerDetailsPage(
          fencerID: args.fencerID,
          key: args.key,
        ),
      );
    },
    AuthWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AuthWrapperPage(),
      );
    },
    AddDrillsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddDrillsPage(),
      );
    },
    DrillsListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DrillsListPage(),
      );
    },
    EditDrillsRoute.name: (routeData) {
      final args = routeData.argsAs<EditDrillsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditDrillsPage(
          drill: args.drill,
          key: args.key,
        ),
      );
    },
    AddPracticesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddPracticesPage(),
      );
    },
    PracticeRoute.name: (routeData) {
      final args = routeData.argsAs<PracticeRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PracticePage(
          practiceID: args.practiceID,
          key: args.key,
        ),
      );
    },
    EditPracticeRoute.name: (routeData) {
      final args = routeData.argsAs<EditPracticeRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditPracticePage(
          practice: args.practice,
          key: args.key,
        ),
      );
    },
  };
}

/// generated route for
/// [AttendancePage]
class AttendanceRoute extends PageRouteInfo<AttendanceRouteArgs> {
  AttendanceRoute({
    required String practiceID,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AttendanceRoute.name,
          args: AttendanceRouteArgs(
            practiceID: practiceID,
            key: key,
          ),
          rawPathParams: {'practiceID': practiceID},
          initialChildren: children,
        );

  static const String name = 'AttendanceRoute';

  static const PageInfo<AttendanceRouteArgs> page =
      PageInfo<AttendanceRouteArgs>(name);
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

/// generated route for
/// [EditFencerStatusPage]
class EditFencerStatusRoute extends PageRouteInfo<EditFencerStatusRouteArgs> {
  EditFencerStatusRoute({
    required UserData fencer,
    required Practice practice,
    Attendance? attendance,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          EditFencerStatusRoute.name,
          args: EditFencerStatusRouteArgs(
            fencer: fencer,
            practice: practice,
            attendance: attendance,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'EditFencerStatusRoute';

  static const PageInfo<EditFencerStatusRouteArgs> page =
      PageInfo<EditFencerStatusRouteArgs>(name);
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
/// [FencerListPage]
class FencerListRoute extends PageRouteInfo<void> {
  const FencerListRoute({List<PageRouteInfo>? children})
      : super(
          FencerListRoute.name,
          initialChildren: children,
        );

  static const String name = 'FencerListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FencerDetailsPage]
class FencerDetailsRoute extends PageRouteInfo<FencerDetailsRouteArgs> {
  FencerDetailsRoute({
    required String fencerID,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          FencerDetailsRoute.name,
          args: FencerDetailsRouteArgs(
            fencerID: fencerID,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FencerDetailsRoute';

  static const PageInfo<FencerDetailsRouteArgs> page =
      PageInfo<FencerDetailsRouteArgs>(name);
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
/// [AuthWrapperPage]
class AuthWrapperRoute extends PageRouteInfo<void> {
  const AuthWrapperRoute({List<PageRouteInfo>? children})
      : super(
          AuthWrapperRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthWrapperRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AddDrillsPage]
class AddDrillsRoute extends PageRouteInfo<void> {
  const AddDrillsRoute({List<PageRouteInfo>? children})
      : super(
          AddDrillsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddDrillsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DrillsListPage]
class DrillsListRoute extends PageRouteInfo<void> {
  const DrillsListRoute({List<PageRouteInfo>? children})
      : super(
          DrillsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'DrillsListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EditDrillsPage]
class EditDrillsRoute extends PageRouteInfo<EditDrillsRouteArgs> {
  EditDrillsRoute({
    required Drill drill,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          EditDrillsRoute.name,
          args: EditDrillsRouteArgs(
            drill: drill,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'EditDrillsRoute';

  static const PageInfo<EditDrillsRouteArgs> page =
      PageInfo<EditDrillsRouteArgs>(name);
}

class EditDrillsRouteArgs {
  const EditDrillsRouteArgs({
    required this.drill,
    this.key,
  });

  final Drill drill;

  final Key? key;

  @override
  String toString() {
    return 'EditDrillsRouteArgs{drill: $drill, key: $key}';
  }
}

/// generated route for
/// [AddPracticesPage]
class AddPracticesRoute extends PageRouteInfo<void> {
  const AddPracticesRoute({List<PageRouteInfo>? children})
      : super(
          AddPracticesRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddPracticesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PracticePage]
class PracticeRoute extends PageRouteInfo<PracticeRouteArgs> {
  PracticeRoute({
    required String practiceID,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          PracticeRoute.name,
          args: PracticeRouteArgs(
            practiceID: practiceID,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'PracticeRoute';

  static const PageInfo<PracticeRouteArgs> page =
      PageInfo<PracticeRouteArgs>(name);
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
/// [EditPracticePage]
class EditPracticeRoute extends PageRouteInfo<EditPracticeRouteArgs> {
  EditPracticeRoute({
    required Practice practice,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          EditPracticeRoute.name,
          args: EditPracticeRouteArgs(
            practice: practice,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'EditPracticeRoute';

  static const PageInfo<EditPracticeRouteArgs> page =
      PageInfo<EditPracticeRouteArgs>(name);
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
