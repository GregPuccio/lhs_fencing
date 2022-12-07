import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/attendance_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

class EditFencerStatusPage extends ConsumerStatefulWidget {
  final UserData fencer;
  final Practice practice;
  const EditFencerStatusPage(this.fencer, this.practice, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditFencerStatusPageState();
}

class _EditFencerStatusPageState extends ConsumerState<EditFencerStatusPage> {
  late TimeOfDay startTime;
  bool selectCheckOutTime = false;
  late TimeOfDay endTime;
  late TextEditingController lateReason;
  late TextEditingController earlyLeaveReason;

  @override
  void dispose() {
    lateReason.dispose();
    earlyLeaveReason.dispose();
    super.dispose();
  }

  @override
  void initState() {
    lateReason = TextEditingController();
    earlyLeaveReason = TextEditingController();
    startTime = TimeOfDay(
        hour: widget.practice.startTime.hour,
        minute: widget.practice.startTime.minute);
    endTime = TimeOfDay(
        hour: widget.practice.endTime.hour,
        minute: widget.practice.endTime.minute);
    super.initState();
  }

  Future<void> checkIn() async {
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

    return await addAttendance(
      widget.fencer.id,
      fencerMonths,
      Attendance.create(widget.practice, widget.fencer).copyWith(
        checkIn: checkIn,
        lateReason: lateReason.text,
        checkOut: selectCheckOutTime ? checkOut : null,
        earlyLeaveReason: earlyLeaveReason.text,
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Fencer Status"),
      ),
      body: SingleChildScrollView(
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
            ListTile(
              title: const Text("Check In Time"),
              subtitle: Text(startTime.format(context)),
              trailing: const Icon(Icons.av_timer),
              onTap: () => setTime(startTime),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lateReason,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text("Include Check Out Time"),
              value: selectCheckOutTime,
              onChanged: (value) => selectCheckOutTime = value ?? true,
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
            if (selectCheckOutTime) ...[
              TextField(
                controller: earlyLeaveReason,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                await checkIn();
                if (mounted) {
                  context.popRoute();
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Fencer Status"),
            ),
          ],
        ),
      ),
    );
  }
}
