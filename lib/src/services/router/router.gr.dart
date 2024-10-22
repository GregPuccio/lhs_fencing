// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AddBoutPage]
class AddBoutRoute extends PageRouteInfo<AddBoutRouteArgs> {
  AddBoutRoute({
    UserData? fencer,
    UserData? opponent,
    DateTime? selectedDate,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AddBoutRoute.name,
          args: AddBoutRouteArgs(
            fencer: fencer,
            opponent: opponent,
            selectedDate: selectedDate,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AddBoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args =
          data.argsAs<AddBoutRouteArgs>(orElse: () => const AddBoutRouteArgs());
      return AddBoutPage(
        fencer: args.fencer,
        opponent: args.opponent,
        selectedDate: args.selectedDate,
        key: args.key,
      );
    },
  );
}

class AddBoutRouteArgs {
  const AddBoutRouteArgs({
    this.fencer,
    this.opponent,
    this.selectedDate,
    this.key,
  });

  final UserData? fencer;

  final UserData? opponent;

  final DateTime? selectedDate;

  final Key? key;

  @override
  String toString() {
    return 'AddBoutRouteArgs{fencer: $fencer, opponent: $opponent, selectedDate: $selectedDate, key: $key}';
  }
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddDrillsPage();
    },
  );
}

/// generated route for
/// [AddPracticesPage]
class AddPracticesRoute extends PageRouteInfo<AddPracticesRouteArgs> {
  AddPracticesRoute({
    DateTime? practiceDate,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AddPracticesRoute.name,
          args: AddPracticesRouteArgs(
            practiceDate: practiceDate,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AddPracticesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddPracticesRouteArgs>(
          orElse: () => const AddPracticesRouteArgs());
      return AddPracticesPage(
        practiceDate: args.practiceDate,
        key: args.key,
      );
    },
  );
}

class AddPracticesRouteArgs {
  const AddPracticesRouteArgs({
    this.practiceDate,
    this.key,
  });

  final DateTime? practiceDate;

  final Key? key;

  @override
  String toString() {
    return 'AddPracticesRouteArgs{practiceDate: $practiceDate, key: $key}';
  }
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AttendanceRouteArgs>(
          orElse: () => AttendanceRouteArgs(
              practiceID: pathParams.getString('practiceID')));
      return AttendancePage(
        practiceID: args.practiceID,
        key: args.key,
      );
    },
  );
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
/// [AuthWrapperPage]
class AuthWrapperRoute extends PageRouteInfo<void> {
  const AuthWrapperRoute({List<PageRouteInfo>? children})
      : super(
          AuthWrapperRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthWrapperPage();
    },
  );
}

/// generated route for
/// [BoutHistoryPage]
class BoutHistoryRoute extends PageRouteInfo<void> {
  const BoutHistoryRoute({List<PageRouteInfo>? children})
      : super(
          BoutHistoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'BoutHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BoutHistoryPage();
    },
  );
}

/// generated route for
/// [CreateLineupPage]
class CreateLineupRoute extends PageRouteInfo<CreateLineupRouteArgs> {
  CreateLineupRoute({
    Team? teamFilter,
    Weapon? weaponFilter,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          CreateLineupRoute.name,
          args: CreateLineupRouteArgs(
            teamFilter: teamFilter,
            weaponFilter: weaponFilter,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'CreateLineupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateLineupRouteArgs>(
          orElse: () => const CreateLineupRouteArgs());
      return CreateLineupPage(
        teamFilter: args.teamFilter,
        weaponFilter: args.weaponFilter,
        key: args.key,
      );
    },
  );
}

class CreateLineupRouteArgs {
  const CreateLineupRouteArgs({
    this.teamFilter,
    this.weaponFilter,
    this.key,
  });

  final Team? teamFilter;

  final Weapon? weaponFilter;

  final Key? key;

  @override
  String toString() {
    return 'CreateLineupRouteArgs{teamFilter: $teamFilter, weaponFilter: $weaponFilter, key: $key}';
  }
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DrillsListPage();
    },
  );
}

/// generated route for
/// [EditBoutPage]
class EditBoutRoute extends PageRouteInfo<EditBoutRouteArgs> {
  EditBoutRoute({
    required Bout bout,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          EditBoutRoute.name,
          args: EditBoutRouteArgs(
            bout: bout,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'EditBoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditBoutRouteArgs>();
      return EditBoutPage(
        bout: args.bout,
        key: args.key,
      );
    },
  );
}

class EditBoutRouteArgs {
  const EditBoutRouteArgs({
    required this.bout,
    this.key,
  });

  final Bout bout;

  final Key? key;

  @override
  String toString() {
    return 'EditBoutRouteArgs{bout: $bout, key: $key}';
  }
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditDrillsRouteArgs>();
      return EditDrillsPage(
        drill: args.drill,
        key: args.key,
      );
    },
  );
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
/// [EditFencerStatusPage]
class EditFencerStatusRoute extends PageRouteInfo<EditFencerStatusRouteArgs> {
  EditFencerStatusRoute({
    required UserData fencer,
    required Practice practice,
    required Attendance attendance,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditFencerStatusRouteArgs>();
      return EditFencerStatusPage(
        args.fencer,
        args.practice,
        args.attendance,
        key: args.key,
      );
    },
  );
}

class EditFencerStatusRouteArgs {
  const EditFencerStatusRouteArgs({
    required this.fencer,
    required this.practice,
    required this.attendance,
    this.key,
  });

  final UserData fencer;

  final Practice practice;

  final Attendance attendance;

  final Key? key;

  @override
  String toString() {
    return 'EditFencerStatusRouteArgs{fencer: $fencer, practice: $practice, attendance: $attendance, key: $key}';
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditPracticeRouteArgs>();
      return EditPracticePage(
        practice: args.practice,
        key: args.key,
      );
    },
  );
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
/// [EquipmentListPage]
class EquipmentListRoute extends PageRouteInfo<void> {
  const EquipmentListRoute({List<PageRouteInfo>? children})
      : super(
          EquipmentListRoute.name,
          initialChildren: children,
        );

  static const String name = 'EquipmentListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EquipmentListPage();
    },
  );
}

/// generated route for
/// [EventsListPage]
class EventsListRoute extends PageRouteInfo<void> {
  const EventsListRoute({List<PageRouteInfo>? children})
      : super(
          EventsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'EventsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EventsListPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FencerDetailsRouteArgs>();
      return FencerDetailsPage(
        fencerID: args.fencerID,
        key: args.key,
      );
    },
  );
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
/// [FencerListPage]
class FencerListRoute extends PageRouteInfo<void> {
  const FencerListRoute({List<PageRouteInfo>? children})
      : super(
          FencerListRoute.name,
          initialChildren: children,
        );

  static const String name = 'FencerListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FencerListPage();
    },
  );
}

/// generated route for
/// [LineupPage]
class LineupRoute extends PageRouteInfo<void> {
  const LineupRoute({List<PageRouteInfo>? children})
      : super(
          LineupRoute.name,
          initialChildren: children,
        );

  static const String name = 'LineupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LineupPage();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PracticeRouteArgs>();
      return PracticePage(
        practiceID: args.practiceID,
        key: args.key,
      );
    },
  );
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
