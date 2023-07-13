import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/views/add_practices/add_practices_page.dart';
import 'package:lhs_fencing/src/views/add_practices/edit_practice.dart';
import 'package:lhs_fencing/src/views/admin/edit_fencer_status_page.dart';
import 'package:lhs_fencing/src/views/admin/fencer_details_page.dart';
import 'package:lhs_fencing/src/views/admin/fencer_list_page.dart';
import 'package:lhs_fencing/src/views/admin/practice_page.dart';
import 'package:lhs_fencing/src/views/auth_wrapper.dart';
import 'package:lhs_fencing/src/views/home/attendance_page.dart';

part 'router.gr.dart';

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
    AutoRoute(page: FencerDetailsRoute.page, path: "/fencerDetails"),
    AutoRoute(page: EditFencerStatusRoute.page, path: "/editFencerStatus"),
    AutoRoute(
      page: AttendanceRoute.page,
      path: "/attendance/:practiceID",
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
