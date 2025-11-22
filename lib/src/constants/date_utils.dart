import 'package:flutter/material.dart';

extension DateUtils on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  DateTime get today {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day + 1);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  bool isSameDayAs(DateTime? other) {
    if (other == null) {
      return false;
    }
    return other.day == day && other.month == month && other.year == year;
  }

  DateTime addTime() {
    DateTime now = DateTime.now();
    return add(Duration(
        hours: now.hour,
        minutes: now.minute,
        milliseconds: now.millisecond,
        microseconds: now.microsecond));
  }

  DateTime get monthOnly {
    return DateTime(year, month);
  }

  String getCurrentSchoolYear() {
    final now = DateTime.now();
    int startYear;

    // If month is July (7) or later, school year begins this calendar year
    if (now.month >= 7) {
      startYear = now.year;
    } else {
      startYear = now.year - 1;
    }

    final endYear = startYear + 1;
    return "$startYear-$endYear";
  }
}

extension DateRangeUtils on DateTimeRange {
  List<DateTime> get days {
    DateTime first = DateTime(start.year, start.month, start.day);
    DateTime last = DateTime(end.year, end.month, end.day, 1);
    List<DateTime> days = [];
    for (DateTime d = first;
        d.isBefore(last);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }
}
