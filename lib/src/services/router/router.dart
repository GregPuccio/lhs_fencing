import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/drill.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/views/admin/drills/add_drills_page.dart';
import 'package:lhs_fencing/src/views/admin/drills/edit_drills_page.dart';
import 'package:lhs_fencing/src/views/admin/equipment/equipment_list_page.dart';
import 'package:lhs_fencing/src/views/admin/events/event_list.dart';
import 'package:lhs_fencing/src/views/admin/practices/add_practices_page.dart';
import 'package:lhs_fencing/src/views/admin/practices/edit_practice.dart';
import 'package:lhs_fencing/src/views/admin/drills/drills_list_page.dart';
import 'package:lhs_fencing/src/views/admin/edit_fencer_status_page.dart';
import 'package:lhs_fencing/src/views/admin/fencer_details_page.dart';
import 'package:lhs_fencing/src/views/admin/fencer_list_page.dart';
import 'package:lhs_fencing/src/views/admin/practices/practice_page.dart';
import 'package:lhs_fencing/src/views/auth_wrapper.dart';
import 'package:lhs_fencing/src/views/home/attendance_page.dart';

part 'router.gr.dart';

//dart run build_runner build

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();

  @override
  final List<AutoRoute> routes = <AutoRoute>[
    AutoRoute(
      page: AuthWrapperRoute.page,
      path: '/',
      initial: true,
    ),
    AutoRoute(page: AddPracticesRoute.page, path: "/addPractices"),
    AutoRoute(page: EditPracticeRoute.page, path: "/editPractice"),
    AutoRoute(page: PracticeRoute.page, path: "/practice"),
    AutoRoute(page: FencerListRoute.page, path: "/fencerList"),
    AutoRoute(page: DrillsListRoute.page, path: "/drillsList"),
    AutoRoute(page: AddDrillsRoute.page, path: "/addDrills"),
    AutoRoute(page: EditDrillsRoute.page, path: "/editDrills"),
    AutoRoute(page: FencerDetailsRoute.page, path: "/fencerDetails"),
    AutoRoute(page: EditFencerStatusRoute.page, path: "/editFencerStatus"),
    AutoRoute(page: EventsListRoute.page, path: "/eventList"),
    AutoRoute(page: EquipmentListRoute.page, path: "/equipmentList"),
    AutoRoute(
      page: AttendanceRoute.page,
      path: "/attendance/:practiceID",
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
