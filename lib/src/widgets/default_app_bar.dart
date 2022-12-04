import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/widgets/livingston_logo.dart';

AppBar defaultAppBar = AppBar(
  title: ListTile(
    leading: livingstonLogo,
    title: const Text(
      "LHS Fencing Team Attendance",
      textAlign: TextAlign.center,
    ),
  ),
);
