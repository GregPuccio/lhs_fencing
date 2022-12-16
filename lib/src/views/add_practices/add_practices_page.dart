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
import 'package:uuid/uuid.dart';

class AddPracticesPage extends ConsumerStatefulWidget {
  const AddPracticesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPracticesPageState();
}

class _AddPracticesPageState extends ConsumerState<AddPracticesPage> {
  late DateTimeRange dateRange;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  TypePractice typePractice = TypePractice.practice;
  List<DayOfWeek> daysOfWeek = [];
  List<Practice> practices = [];

  @override
  void initState() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    daysOfWeek.add(DayOfWeek.values
        .firstWhere((element) => now.weekday == element.weekday));
    dateRange = DateTimeRange(start: today, end: today);
    startTime = const TimeOfDay(hour: 18, minute: 0);
    endTime = const TimeOfDay(hour: 20, minute: 0);
    super.initState();
  }

  void setDateRange() async {
    DateTimeRange? value = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: dateRange.start,
        end: dateRange.end,
      ),
      currentDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (value != null) {
      setState(() {
        dateRange = DateTimeRange(start: value.start, end: value.end);
      });
    }
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
        title: const Text("Add Practices"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text("Type"),
              trailing: DropdownButton<TypePractice>(
                  value: typePractice,
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
                      typePractice = value;
                    });
                  }),
            ),
            const Divider(),
            ListTile(
              title: const Text("Date Range"),
              subtitle: Text(
                "${DateFormat.yMd().format(dateRange.start)} - ${DateFormat.yMd().format(dateRange.end)}",
              ),
              trailing: const Icon(Icons.date_range),
              onTap: setDateRange,
            ),
            const Divider(),
            ListTile(
              title: const Text(
                "Days of the Week",
              ),
              trailing: ToggleButtons(
                isSelected: List.generate(DayOfWeek.values.length,
                    (index) => daysOfWeek.contains(DayOfWeek.values[index])),
                children: List.generate(
                  DayOfWeek.values.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(DayOfWeek.values[index].abbreviation),
                  ),
                ),
                onPressed: (index) {
                  setState(() {
                    if (daysOfWeek.contains(DayOfWeek.values[index])) {
                      daysOfWeek.remove(DayOfWeek.values[index]);
                    } else {
                      daysOfWeek.add(DayOfWeek.values[index]);
                    }
                  });
                },
              ),
            ),
            const Divider(),
            Row(
              children: [
                Flexible(
                  child: ListTile(
                    title: const Text("Practice Start Time"),
                    subtitle: Text(startTime.format(context)),
                    trailing: const Icon(Icons.av_timer),
                    onTap: () => setTime(startTime),
                  ),
                ),
                Flexible(
                  child: ListTile(
                    title: const Text("Practice End Time"),
                    subtitle: Text(endTime.format(context)),
                    trailing: const Icon(Icons.time_to_leave),
                    onTap: () => setTime(endTime, start: false),
                  ),
                ),
              ],
            ),
            const Divider(),
            OutlinedButton.icon(
              onPressed: () async {
                final daysToGenerate =
                    dateRange.end.difference(dateRange.start).inDays;
                List<Practice> days = List.generate(
                  daysToGenerate + 1,
                  (i) => Practice(
                    id: const Uuid().v4(),
                    location: "Auxillary Gym",
                    startTime: DateTime(
                        dateRange.start.year,
                        dateRange.start.month,
                        dateRange.start.day + (i),
                        startTime.hour,
                        startTime.minute),
                    endTime: DateTime(
                        dateRange.start.year,
                        dateRange.start.month,
                        dateRange.start.day + (i),
                        endTime.hour,
                        endTime.minute),
                    type: typePractice,
                  ),
                );
                List<PracticeMonth> months =
                    ref.read(practicesProvider).asData!.value;
                for (var day in days) {
                  if (daysOfWeek
                      .any((dow) => dow.weekday == day.startTime.weekday)) {
                    DateTime month =
                        DateTime(day.startTime.year, day.startTime.month);
                    int index = months
                        .indexWhere((m) => m.month.isAtSameMomentAs(month));
                    if (index == -1) {
                      months.add(PracticeMonth(
                          id: "", practices: [day], month: month));
                    } else {
                      months[index].practices.add(day);
                    }
                  }
                }
                for (var month in months) {
                  if (month.id.isEmpty) {
                    await FirestoreService.instance.addData(
                        path: FirestorePath.practices(), data: month.toMap());
                  } else {
                    await FirestoreService.instance.updateData(
                        path: FirestorePath.practice(month.id),
                        data: month.toMap());
                  }
                }
                if (mounted) {
                  context.popRoute();
                }
              },
              icon: const Text("Add Practices"),
              label: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
