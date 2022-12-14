// @CupertinoAutoRouter
// @AdaptiveAutoRouter
// @CustomAutoRouter
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

@AdaptiveAutoRouter(
  // Name Shortener - HomePage → HomeRoute instead of HomePageRoute
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: AuthWrapperPage, initial: true),
    AutoRoute(page: AddPracticesPage, path: "addPractices"),
    AutoRoute(page: EditPracticePage, path: "editPractice"),
    AutoRoute(page: PracticePage, path: "practice"),
    AutoRoute(page: FencerListPage, path: "fencerList"),
    AutoRoute(page: FencerDetailsPage, path: "fencerDetails"),
    AutoRoute(page: EditFencerStatusPage, path: "editFencerStatus"),
    AutoRoute(page: AttendancePage, path: "attendance"),
    RedirectRoute(path: '*', redirectTo: '/'),
  ],
)
class AppRouter extends _$AppRouter {}
