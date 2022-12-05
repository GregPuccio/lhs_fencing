enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  String get abbreviation {
    switch (this) {
      case DayOfWeek.sunday:
        return "Sun";
      case DayOfWeek.monday:
        return "Mon";
      case DayOfWeek.tuesday:
        return "Tue";
      case DayOfWeek.wednesday:
        return "Wed";
      case DayOfWeek.thursday:
        return "Thu";
      case DayOfWeek.friday:
        return "Fri";
      case DayOfWeek.saturday:
        return "Sat";
    }
  }

  int get weekday {
    switch (this) {
      case DayOfWeek.sunday:
        return 7;
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
    }
  }
}