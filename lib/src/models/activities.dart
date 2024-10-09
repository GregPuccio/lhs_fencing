import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class Activities {
  final Practice practice;

  Activities(this.practice);

  Map<String, DateTime> practiceActivities() {
    return {
      "Warm Up": practice.startTime,
      "Footwork": practice.startTime.add(const Duration(minutes: 20)),
      "Drills": practice.startTime.add(const Duration(minutes: 50)),
      "Fencing": practice.startTime.add(const Duration(minutes: 80)),
      "End": practice.endTime,
    };
  }

  Map<String, DateTime> homeMeetActivities() {
    return {
      "Meet Begins": practice.startTime,
      "Meet Ends": practice.endTime,
    };
  }

  Map<String, DateTime> awayMeetActivities() {
    return {
      "Arrive at Gym": practice.busTime!.subtract(const Duration(minutes: 30)),
      "Be Ready to Leave":
          practice.busTime!.subtract(const Duration(minutes: 5)),
      "Bus Leaves": practice.busTime!,
      "Meet Begins": practice.startTime,
      "Meet Ends": practice.endTime,
      "Arrive Back to LHS (Typical)":
          practice.busTime!.add(const Duration(minutes: 30)),
    };
  }

  Map<String, DateTime> spectatingHomeActivities() {
    return {
      "Arrive at Gym": practice.startTime.subtract(const Duration(minutes: 15)),
      "Meet Begins": practice.startTime,
      "Meet Ends": practice.endTime,
    };
  }

  Map<String, DateTime> spectatingAwayActivities() {
    return {
      "Arrive at Gym": practice.busTime!.subtract(const Duration(minutes: 15)),
      "Be Ready to Leave":
          practice.busTime!.subtract(const Duration(minutes: 5)),
      "Bus Leaves": practice.busTime!,
      "Meet Begins": practice.startTime,
      "Meet Ends": practice.endTime,
      "Arrive Back to LHS (Typical)":
          practice.busTime!.add(const Duration(minutes: 30)),
    };
  }

  Map<String, DateTime> quadActivities() {
    return {
      "Warm Up": practice.startTime,
      "End": practice.endTime,
    };
  }

  Map<String, DateTime> tournamentActivities() {
    return {
      "Warm Up": practice.startTime,
      "Footwork": practice.startTime.add(const Duration(minutes: 20)),
      "Drills": practice.startTime.add(const Duration(minutes: 50)),
      "Fencing": practice.startTime.add(const Duration(minutes: 80)),
      "End": practice.endTime,
    };
  }

  Map<String, DateTime> fundraiserActivities() {
    return {
      "Fundraiser Begins": practice.startTime,
      "Fundraiser Ends": practice.endTime,
    };
  }

  Map<String, DateTime> get activities {
    switch (practice.type) {
      case TypePractice.practice:
        return practiceActivities();
      case TypePractice.meet:
        return homeMeetActivities();
      case TypePractice.awayMeet:
        return awayMeetActivities();
      case TypePractice.spectatingHome:
        return spectatingHomeActivities();
      case TypePractice.spectatingAway:
        return spectatingAwayActivities();
      case TypePractice.quad:
        return quadActivities();
      case TypePractice.tournament:
        return tournamentActivities();
      case TypePractice.fundraiser:
        return fundraiserActivities();
    }
  }
}
