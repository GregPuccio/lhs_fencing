import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';

@RoutePage()
class EditPracticePage extends ConsumerStatefulWidget {
  final Practice practice;
  const EditPracticePage({required this.practice, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPracticePageState();
}

class _EditPracticePageState extends ConsumerState<EditPracticePage> {
  late Practice practice;

  @override
  void initState() {
    practice = widget.practice;
    super.initState();
  }

  void setDate() async {
    DateTime? value = await showDatePicker(
      context: context,
      initialDate: practice.startTime,
      currentDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (value != null) {
      DateTime startTime = DateTime(value.year, value.month, value.day,
          practice.startTime.hour, practice.startTime.minute);
      DateTime endTime = DateTime(value.year, value.month, value.day,
          practice.endTime.hour, practice.endTime.minute);
      setState(() {
        practice.startTime = startTime;
        practice.endTime = endTime;
      });
    }
  }

  void setTime({bool start = true}) async {
    TimeOfDay timeOfDay =
        TimeOfDay.fromDateTime(start ? practice.startTime : practice.endTime);
    TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (value != null) {
      setState(() {
        if (start) {
          practice.startTime = DateTime(
            practice.startTime.year,
            practice.startTime.month,
            practice.startTime.day,
            value.hour,
            value.minute,
          );
        } else {
          practice.endTime = DateTime(
            practice.endTime.year,
            practice.endTime.month,
            practice.endTime.day,
            value.hour,
            value.minute,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Practice"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text("Type"),
              trailing: DropdownButton<TypePractice>(
                  value: practice.type,
                  items: List.generate(
                    TypePractice.values.length,
                    (index) => DropdownMenuItem(
                      value: TypePractice.values[index],
                      child: Text(TypePractice.values[index].type),
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      practice.type = value;
                    });
                  }),
            ),
            const Divider(),
            ListTile(
              title: const Text("Date"),
              subtitle: Text(DateFormat.yMd().format(practice.startTime)),
              trailing: const Icon(Icons.date_range),
              onTap: setDate,
            ),
            const Divider(),
            Row(
              children: [
                Flexible(
                  child: ListTile(
                    title: const Text("Practice Start Time"),
                    subtitle: Text(TimeOfDay.fromDateTime(practice.startTime)
                        .format(context)),
                    trailing: const Icon(Icons.av_timer),
                    onTap: () => setTime(),
                  ),
                ),
                Flexible(
                  child: ListTile(
                    title: const Text("Practice End Time"),
                    subtitle: Text(TimeOfDay.fromDateTime(practice.endTime)
                        .format(context)),
                    trailing: const Icon(Icons.time_to_leave),
                    onTap: () => setTime(start: false),
                  ),
                ),
              ],
            ),
            const Divider(),
            OutlinedButton.icon(
              onPressed: () async {
                List<PracticeMonth> months =
                    ref.read(practicesProvider).asData!.value;

                DateTime date =
                    DateTime(practice.startTime.year, practice.startTime.month);
                int index =
                    months.indexWhere((m) => m.month.isAtSameMomentAs(date));
                if (index == -1) {
                  months.add(PracticeMonth(
                      id: "", practices: [practice], month: date));
                } else {
                  int pIndex = months[index]
                      .practices
                      .indexWhere((p) => p.id == practice.id);
                  if (pIndex == -1) {
                    months[index].practices.add(practice);
                  } else {
                    months[index].practices.replaceRange(
                      pIndex,
                      pIndex + 1,
                      [practice],
                    );
                  }
                }
                await FirestoreService.instance.updateData(
                  path: FirestorePath.practice(months[index].id),
                  data: months[index].toMap(),
                );
                if (mounted) {
                  context.popRoute();
                }
              },
              icon: const Text("Save Changes"),
              label: const Icon(Icons.save),
            )
          ],
        ),
      ),
    );
  }
}
