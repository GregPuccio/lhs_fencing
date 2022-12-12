import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/comment.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

class EditFencerStatusPage extends ConsumerStatefulWidget {
  final UserData fencer;
  final Practice practice;
  final Attendance? attendance;
  const EditFencerStatusPage(this.fencer, this.practice,
      {this.attendance, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditFencerStatusPageState();
}

class _EditFencerStatusPageState extends ConsumerState<EditFencerStatusPage> {
  late bool selectCheckInTime;
  late TimeOfDay startTime;
  late bool selectCheckOutTime;
  late TimeOfDay endTime;
  late TextEditingController controller;
  List<Comment> comments = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
    startTime = TimeOfDay(
        hour:
            widget.attendance?.checkIn?.hour ?? widget.practice.startTime.hour,
        minute: widget.attendance?.checkIn?.minute ??
            widget.practice.startTime.minute);
    endTime = TimeOfDay(
      hour: widget.attendance?.checkOut?.hour ?? widget.practice.endTime.hour,
      minute:
          widget.attendance?.checkOut?.minute ?? widget.practice.endTime.minute,
    );
    selectCheckInTime = widget.attendance?.checkIn != null;
    selectCheckOutTime = widget.attendance?.checkOut != null;
    super.initState();
  }

  Future<void> saveStatus() async {
    List<AttendanceMonth> months =
        ref.read(allAttendancesProvider).asData!.value;
    List<AttendanceMonth> fencerMonths = months
        .where(
            (month) => month.attendances.first.userData.id == widget.fencer.id)
        .toList();
    DateTime checkIn = DateTime(
      widget.practice.startTime.year,
      widget.practice.startTime.month,
      widget.practice.startTime.day,
      startTime.hour,
      startTime.minute,
    );
    DateTime checkOut = DateTime(
      widget.practice.startTime.year,
      widget.practice.startTime.month,
      widget.practice.startTime.day,
      endTime.hour,
      endTime.minute,
    );
    Attendance newAttendance =
        widget.attendance ?? Attendance.create(widget.practice, widget.fencer);
    newAttendance.copyWith(comments: comments);
    newAttendance.checkIn = selectCheckInTime ? checkIn : null;
    newAttendance.checkOut = selectCheckOutTime ? checkOut : null;

    return await addAttendance(
      widget.fencer.id,
      fencerMonths,
      newAttendance,
    );
  }

  Future deleteAttendance() async {
    List<AttendanceMonth> months =
        ref.read(allAttendancesProvider).asData!.value;
    List<AttendanceMonth> fencerMonths = months
        .where(
            (month) => month.attendances.first.userData.id == widget.fencer.id)
        .toList();
    return await removeAttendance(
      widget.fencer.id,
      fencerMonths,
      widget.attendance!,
    );
  }

  void setTime(TimeOfDay timeOfDay, {bool start = true}) async {
    TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (value != null) {
      setState(() {
        if (start) {
          startTime = value;
        } else {
          endTime = value;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData userData = ref.watch(userDataProvider).asData!.value!;
    Widget whenData(List<AttendanceMonth> months) {
      List<Attendance> attendances = [];
      for (var month in months) {
        if (month.attendances.first.userData.id == widget.fencer.id) {
          attendances.addAll(month.attendances);
        }
      }
      Attendance attendance = attendances.firstWhere(
        (attendance) {
          return attendance.id == widget.attendance?.id;
        },
        orElse: () => Attendance.create(widget.practice, widget.fencer),
      );
      attendance.comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Fencer Status"),
          actions: [
            if (widget.attendance != null)
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Attendance"),
                    content: const Text(
                        "Are you sure you would like to delete this attendance entry?"),
                    actions: [
                      TextButton(
                        onPressed: () => context.router.pop(),
                        child: const Text("No, cancel"),
                      ),
                      TextButton(
                        onPressed: deleteAttendance,
                        child: const Text("Yes, delete"),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                "Fencer: ${widget.fencer.fullName}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                "Practice: ${widget.practice.startString}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text("Include Check In Time"),
                value: selectCheckInTime,
                onChanged: (value) =>
                    setState(() => selectCheckInTime = value ?? true),
              ),
              const SizedBox(height: 8),
              if (selectCheckInTime) ...[
                ListTile(
                  title: const Text("Check In Time"),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.av_timer),
                  onTap: () => setTime(startTime),
                ),
                const SizedBox(height: 8),
              ],
              CheckboxListTile(
                title: const Text("Include Check Out Time"),
                value: selectCheckOutTime,
                onChanged: (value) =>
                    setState(() => selectCheckOutTime = value ?? true),
              ),
              const SizedBox(height: 8),
              if (selectCheckOutTime) ...[
                ListTile(
                  title: const Text("Check Out Time"),
                  subtitle: Text(endTime.format(context)),
                  trailing: const Icon(Icons.time_to_leave),
                  onTap: () => setTime(endTime, start: false),
                ),
                const SizedBox(height: 8),
              ],
              OutlinedButton.icon(
                onPressed: () async {
                  await saveStatus();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fencer Status Updated!"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Fencer Status"),
              ),
              const Divider(),
              Column(
                children:
                    List.generate(attendance.comments.length + 1, (index) {
                  if (index == attendance.comments.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(userData.initials),
                        ),
                        title: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            label: const Text("Add Comment"),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: controller.text.isEmpty
                                  ? null
                                  : () {
                                      List<AttendanceMonth> months = ref
                                          .read(allAttendancesProvider)
                                          .asData!
                                          .value;
                                      List<AttendanceMonth> fencerMonths =
                                          months
                                              .where((month) =>
                                                  month.attendances.first
                                                      .userData.id ==
                                                  widget.fencer.id)
                                              .toList();
                                      Comment comment = Comment.create(userData)
                                          .copyWith(text: controller.text);
                                      attendance.comments.add(comment);

                                      addAttendance(
                                        widget.fencer.id,
                                        fencerMonths,
                                        attendance.copyWith(
                                            userData: widget.fencer),
                                      );
                                      controller.clear();
                                    },
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    Comment comment = attendance.comments[index];
                    bool coachComment = comment.user.id == userData.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: coachComment
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(attendance.userData.initials),
                      ),
                      title: Text(comment.text),
                      subtitle: Text(comment.createdAtString),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      );
    }

    return ref.watch(allAttendancesProvider).when(
        data: whenData,
        error: (error, stackTrace) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}
