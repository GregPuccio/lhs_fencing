import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class Activities {
  final Practice practice;

  Activities(this.practice);

  Map<DateTime, String> practiceActivities() {
    return {
      practice.startTime: "Warm Up",
      practice.startTime.add(const Duration(minutes: 20)): "Footwork",
      practice.startTime.add(const Duration(minutes: 50)): "Drills",
      practice.startTime.add(const Duration(minutes: 80)): "Fencing",
      practice.endTime: "End"
    };
  }

  Map<DateTime, String> homeMeetActivities() {
    return {practice.startTime: "Meet Begins", practice.endTime: "Meet Ends"};
  }

  Map<DateTime, String> awayMeetActivities() {
    return {practice.startTime: "Meet Begins", practice.endTime: "Meet Ends"};
  }

  Map<DateTime, String> quadActivities() {
    return {practice.startTime: "Warm Up", practice.endTime: "End"};
  }

  Map<DateTime, String> tournamentActivities() {
    return {
      practice.startTime: "Warm Up",
      practice.startTime.add(const Duration(minutes: 20)): "Footwork",
      practice.startTime.add(const Duration(minutes: 50)): "Drills",
      practice.startTime.add(const Duration(minutes: 80)): "Fencing",
      practice.endTime: "End"
    };
  }

  Map<DateTime, String> fundraiserActivities() {
    return {
      practice.startTime: "Fundraiser Begins",
      practice.endTime: "Fundraiser Ends"
    };
  }

  Map<DateTime, String> get activities {
    switch (practice.type) {
      case TypePractice.practice:
        return practiceActivities();
      case TypePractice.meet:
        return homeMeetActivities();
      case TypePractice.awayMeet:
        return awayMeetActivities();
      case TypePractice.quad:
        return quadActivities();
      case TypePractice.tournament:
        return tournamentActivities();
      case TypePractice.fundraiser:
        return fundraiserActivities();
    }
  }
}
