import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/location/location.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

class CheckInButton extends ConsumerWidget {
  final Practice practice;

  const CheckInButton({
    Key? key,
    required this.practice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkIn(Practice practice, {String? lateReason}) async {
      UserData userData = ref.read(userDataProvider).value!;
      List<AttendanceMonth> months = ref.read(attendancesProvider).value!;

      return await addAttendance(
        userData.id,
        months,
        Attendance.create(practice, userData).copyWith(
          checkIn: DateTime.now(),
          comments: [
            if (lateReason != null)
              Comment.create(userData).copyWith(text: lateReason)
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: !practice.startTime.isToday
          ? null
          : () async {
              String practiceType = practice.type.type;
              String practiceTooEarlyTime = practice.type.tooEarlyTime;
              // if we are too late to check in (more than an hour after start)
              if (practice.isTooLate) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Too Late For Check In"),
                    content: Text(
                        "You cannot check in through the app this late after the $practiceType has begun. Ask one of the coaches to check you in."),
                    actions: [
                      TextButton(
                        onPressed: () => context.popRoute(),
                        child: const Text(
                          "Understood",
                        ),
                      ),
                    ],
                  ),
                );
              }
              // if we are too early to check in (more than 15 minutes before practice)
              else if (practice.tooSoonForCheckIn) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Too Early For Check In"),
                    content: Text(
                        "You cannot check in for attendance before the $practiceType has started. Make sure it is less than $practiceTooEarlyTime ahead of the $practiceType before you try checking in again."),
                    actions: [
                      TextButton(
                        onPressed: () => context.popRoute(),
                        child: const Text(
                          "Understood",
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                void tryCheckIn() {
                  // if the student is later than 15 minutes to practice
                  if (practice.isLate) {
                    TextEditingController controller = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Late $practiceType Check In"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  "Please note that you are late to the $practiceType and must provide a reason."),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller,
                                minLines: 3,
                                maxLines: 5,
                                validator: (value) => value!.isNotEmpty
                                    ? null
                                    : "Please provide a reason.",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  "Please only check in when you are at the $practiceType. Are you currently at the ${practice.type == TypePractice.meet ? "Home Meet " : ""}${practice.location}?"),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.popRoute(),
                            child: const Text("No, cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              checkIn(
                                practice,
                                lateReason: controller.text.isNotEmpty
                                    ? "Late: ${controller.text}"
                                    : null,
                              ).then((value) => context.router.pop());
                            },
                            child: const Text("Yes, check in"),
                          ),
                        ],
                      ),
                    );
                  }
                  // if they are on time for practice check in
                  else if (practice.canCheckIn) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Check In To $practiceType"),
                        content: Text(
                            "Check in ONLY when you have arrived at the $practiceType or at the location of the event! Are you currently at ${practice.location}?"),
                        actions: [
                          TextButton(
                            onPressed: () => context.popRoute(),
                            child: const Text("No, cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              checkIn(practice)
                                  .then((value) => context.router.pop());
                            },
                            child: const Text("Yes, check in"),
                          ),
                        ],
                      ),
                    );
                  }
                }

                if (practice.type.shouldGetLocation) {
                  LocationService.getLocation().then((locationData) {
                    if (locationData != null) {
                      if (locationData.latitude! < 40.7840 &&
                          locationData.latitude! > 40.7835 &&
                          locationData.longitude! < -74.3222 &&
                          locationData.longitude! > -74.3216) {
                        tryCheckIn();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Not At Practice"),
                            content: const Text(
                                "Your location is showing that you are not yet at the gym! Please do not check in unless you have already arrived.\nIf this is an error please report it to Coach Greg and check in with any coach."),
                            actions: [
                              TextButton(
                                onPressed: () => context.popRoute(),
                                child: const Text(
                                  "Sorry I tried to check in",
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Location Services Issue"),
                          content: const Text(
                              "Your location is taken from your phone to determine whether you are at the gym or not. This location is not saved. Please fix your location access (refresh the website to get the location pop-up again) or check in with a coach."),
                          actions: [
                            TextButton(
                                onPressed: () => context.popRoute(),
                                child: const Text("Close")),
                          ],
                        ),
                      );
                    }
                  });
                } else {
                  tryCheckIn();
                }
              }
            },
      icon: const Icon(Icons.check),
      label: const Text("Check In"),
    );
  }
}
