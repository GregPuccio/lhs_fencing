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
  awayMeet,
  quad,
  tournament,
  fundraiser;

  String get type {
    switch (this) {
      case TypePractice.practice:
        return "Practice";
      case TypePractice.meet:
        return "Dual Meet (Home)";
      case TypePractice.awayMeet:
        return "Dual Meet (Away)";
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
  unexcused,
  noReason;

  const PracticeShowState();

  String get type {
    switch (this) {
      case PracticeShowState.all:
        return "All Practices";
      case PracticeShowState.attended:
        return "Attended";
      case PracticeShowState.excused:
        return "Excused";
      case PracticeShowState.unexcused:
        return "Unexcused";
      case PracticeShowState.noReason:
        return "Uncategorized";
    }
  }

  String get fencerType {
    switch (this) {
      case PracticeShowState.all:
        return "All Fencers";
      case PracticeShowState.attended:
        return "Attendees";
      case PracticeShowState.excused:
        return "Excused";
      case PracticeShowState.unexcused:
        return "Unexcused";
      case PracticeShowState.noReason:
        return "Uncategorized";
    }
  }
}

enum Team {
  boys,
  girls,
  both;

  const Team();

  String get type {
    switch (this) {
      case boys:
        return "Boys Fencing";
      case girls:
        return "Girls Fencing";
      case both:
        return "Both Teams";
    }
  }

  String toMap() => name;
  static Team fromMap(String map) => values.byName(map.isEmpty ? "both" : map);
}

enum Weapon {
  saber,
  foil,
  epee,
  unsure;

  const Weapon();

  String get type {
    switch (this) {
      case saber:
        return "Saber";
      case foil:
        return "Foil";
      case epee:
        return "Epee";
      case unsure:
        return "Unsure";
    }
  }

  String toMap() => name;
  static Weapon fromMap(String map) =>
      values.byName(map.isEmpty ? "foil" : map);
}

enum SchoolYear {
  freshman,
  sophomore,
  junior,
  senior;

  const SchoolYear();

  String get type {
    switch (this) {
      case SchoolYear.freshman:
        return "Freshman";
      case SchoolYear.sophomore:
        return "Sophomore";
      case SchoolYear.junior:
        return "Junior";
      case SchoolYear.senior:
        return "Senior";
    }
  }

  String toMap() => name;
  static SchoolYear fromMap(String map) =>
      values.byName(map.isEmpty ? "freshman" : map);
}

enum TypeDrill {
  footwork,
  bladework,
  whites,
  fencing,
  situationalBouting;

  String get type {
    switch (this) {
      case TypeDrill.footwork:
        return "Footwork";
      case TypeDrill.bladework:
        return "Bladework";
      case TypeDrill.whites:
        return "Whites";
      case TypeDrill.fencing:
        return "Fencing";
      case TypeDrill.situationalBouting:
        return "Situational Bouting";
    }
  }

  String toMap() => name;
  static TypeDrill fromMap(String map) =>
      values.byName(map.isEmpty ? "freshman" : map);
}

enum EquipmentWeapon {
  saber,
  foil,
  epee;

  const EquipmentWeapon();

  String get type {
    switch (this) {
      case saber:
        return "Saber";
      case foil:
        return "Foil";
      case epee:
        return "Epee";
    }
  }

  String toMap() => name;
  static EquipmentWeapon fromMap(String map) =>
      values.byName(map.isEmpty ? "foil" : map);
}
