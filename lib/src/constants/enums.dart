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

enum TypePractice {
  practice,
  meet,
  quad,
  tournament,
  fundraiser;

  String get type {
    switch (this) {
      case TypePractice.practice:
        return "Practice";
      case TypePractice.meet:
        return "Dual Meet";
      case TypePractice.quad:
        return "Quad Meet";
      case TypePractice.tournament:
        return "Tournament";
      case TypePractice.fundraiser:
        return "Fundraiser";
    }
  }

  String toMap() => name;
  static TypePractice fromMap(String map) =>
      values.byName(map.isEmpty ? "practice" : map);
}

enum PracticeShowState {
  all,
  attended,
  excused,
  absent;

  const PracticeShowState();

  String get type {
    switch (this) {
      case PracticeShowState.all:
        return "All Practices";
      case PracticeShowState.attended:
        return "Attended";
      case PracticeShowState.excused:
        return "Excused";
      case PracticeShowState.absent:
        return "Absent";
    }
  }
}
