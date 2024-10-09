import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/activities.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class AddPracticesPage extends ConsumerStatefulWidget {
  final DateTime? practiceDate;
  const AddPracticesPage({this.practiceDate, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPracticesPageState();
}

class _AddPracticesPageState extends ConsumerState<AddPracticesPage> {
  late DateTimeRange dateRange;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late TimeOfDay busTime;
  TypePractice typePractice = TypePractice.practice;
  Team team = Team.both;
  String location = "Livingston Aux Gym";
  List<DayOfWeek> daysOfWeek = [];
  List<Practice> practices = [];

  @override
  void initState() {
    DateTime now = DateTime.now();
    DateTime today =
        widget.practiceDate ?? DateTime(now.year, now.month, now.day);
    if (widget.practiceDate != null) {
      daysOfWeek.add(DayOfWeek.values.firstWhere(
          (element) => widget.practiceDate!.weekday == element.weekday));
    }
    dateRange = DateTimeRange(start: today, end: today);
    busTime = const TimeOfDay(hour: 16, minute: 30);
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
        if (!dateRange.days.any(
          (day) => daysOfWeek.any((dow) => day.weekday == dow.weekday),
        )) {
          daysOfWeek.clear();
          for (var day in dateRange.days) {
            int dowIndex = day.weekday == 7 ? 0 : day.weekday;
            if (!daysOfWeek.contains(DayOfWeek.values[dowIndex])) {
              daysOfWeek.add(DayOfWeek.values[dowIndex]);
            }
          }
        }
      });
    }
  }

  void setTime(TimeOfDay timeOfDay,
      {bool start = false, bool bus = false}) async {
    TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: timeOfDay,
    );
    if (value != null) {
      setState(() {
        if (start) {
          startTime = value;
        } else if (bus) {
          busTime = value;
        } else {
          endTime = value;
        }
      });
    }
  }

  List<Practice> get eventsToGenerate {
    List<Practice> list = [];
    final daysToGenerate = dateRange.end.difference(dateRange.start).inDays;
    List<Practice> days = List.generate(daysToGenerate + 1, (i) {
      Practice practice = Practice(
          id: const Uuid().v4(),
          location: location.isEmpty ? "Livingston Aux Gym" : location,
          busTime: typePractice.usesBus
              ? DateTime(dateRange.start.year, dateRange.start.month,
                  dateRange.start.day + (i), busTime.hour, busTime.minute)
              : null,
          startTime: DateTime(dateRange.start.year, dateRange.start.month,
              dateRange.start.day + (i), startTime.hour, startTime.minute),
          endTime: DateTime(dateRange.start.year, dateRange.start.month,
              dateRange.start.day + (i), endTime.hour, endTime.minute),
          type: typePractice,
          team: team,
          activities: {},
          busCoaches: []);
      practice.activities = Activities(practice).activities;
      return practice;
    });
    for (var day in days) {
      if (daysOfWeek.any((dow) => dow.weekday == day.startTime.weekday)) {
        list.add(day);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Events"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.group,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text("Team"),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<Team>(
                            value: team,
                            items: List.generate(
                              Team.values.length,
                              (index) => DropdownMenuItem(
                                value: Team.values[index],
                                child: Text(Team.values[index].type),
                              ),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                team = value;
                              });
                            }),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                Flexible(
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text("Type"),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<TypePractice>(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.pin_drop,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text("Location"),
                  ],
                ),
              ),
              subtitle: TextFormField(
                initialValue: location,
                onChanged: (value) => location = value,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.date_range,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text("Date Range"),
              subtitle: Text(
                "${DateFormat.yMd().format(dateRange.start)} - ${DateFormat.yMd().format(dateRange.end)}",
              ),
              trailing: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onTap: setDateRange,
            ),
            const Divider(),
            ListTile(
                leading: Icon(
                  Icons.edit_calendar,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text("Days of Each Week"),
                subtitle: const Text(
                    "Which days of the week will this event to occur on?")),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    isSelected: List.generate(
                        DayOfWeek.values.length,
                        (index) =>
                            daysOfWeek.contains(DayOfWeek.values[index])),
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
                ],
              ),
            ),
            const Divider(),
            if (typePractice.usesBus) ...[
              ListTile(
                leading: Icon(
                  Icons.bus_alert,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text("Bus Time"),
                subtitle: Text(busTime.format(context)),
                onTap: () => setTime(busTime, bus: true),
              ),
              const Divider(),
            ],
            Row(
              children: [
                Flexible(
                  child: ListTile(
                    leading: Icon(
                      Icons.av_timer,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text("Start Time"),
                    subtitle: Text(startTime.format(context)),
                    onTap: () => setTime(startTime, start: true),
                  ),
                ),
                const VerticalDivider(),
                Flexible(
                  child: ListTile(
                    leading: Icon(
                      Icons.keyboard_return,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text("End Time"),
                    subtitle: Text(endTime.format(context)),
                    onTap: () => setTime(endTime),
                  ),
                ),
              ],
            ),
            const Divider(),
            ExpansionTile(
              leading: Icon(
                Icons.summarize,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text("Summary Of Events To Be Added:"),
              subtitle: const Text("Tap here to show/hide"),
              children: List.generate(
                eventsToGenerate.length,
                (i) {
                  Practice event = eventsToGenerate[i];
                  return ListTile(
                    leading: Text(
                      "${i + 1})",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    title: Text(event.type.type),
                    subtitle:
                        Text("${DateFormat("EEEE, MM/d/yyy hh:mm aa").format(
                      event.startTime,
                    )} - ${DateFormat("hh:mm aa").format(event.endTime)}"),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final daysToGenerate =
                    dateRange.end.difference(dateRange.start).inDays;
                List<Practice> days = List.generate(daysToGenerate + 1, (i) {
                  Practice practice = Practice(
                      id: const Uuid().v4(),
                      location:
                          location.isEmpty ? "Livingston Aux Gym" : location,
                      busTime: typePractice.usesBus
                          ? DateTime(
                              dateRange.start.year,
                              dateRange.start.month,
                              dateRange.start.day + (i),
                              busTime.hour,
                              busTime.minute)
                          : null,
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
                      team: team,
                      activities: {},
                      busCoaches: []);
                  practice.activities = Activities(practice).activities;
                  return practice;
                });
                List<PracticeMonth> months = ref.read(practicesProvider).value!;
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
                if (context.mounted) {
                  context.maybePop();
                }
              },
              icon: const Text("Add These Events"),
              label: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
