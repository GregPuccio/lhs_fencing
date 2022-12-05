// @CupertinoAutoRouter
// @AdaptiveAutoRouter
// @CustomAutoRouter
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/views/add_practices/add_practices_page.dart';
import 'package:lhs_fencing/src/views/admin/practice_page.dart';
import 'package:lhs_fencing/src/views/auth_wrapper.dart';

part 'router.gr.dart';

@AdaptiveAutoRouter(
  // Name Shortener - HomePage → HomeRoute instead of HomePageRoute
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: AuthWrapperPage, initial: true),
    AutoRoute(page: AddPracticesPage, path: "addPractices"),
    AutoRoute(page: PracticePage, path: "practice"),
    RedirectRoute(path: '*', redirectTo: '/'),
  ],
)
class AppRouter extends _$AppRouter {}
