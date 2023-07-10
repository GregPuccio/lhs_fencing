import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/views/home/widgets/calendar_date_info.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final LinkedHashMap<DateTime, List<Practice>> practicesByDay;
  final List<Attendance> attendances;
  const CalendarPage(
      {required this.practicesByDay, required this.attendances, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late final ValueNotifier<List<Practice>> _selectedEvents;
  DateTime seasonStart = DateTime(2022, 11, 20);
  DateTime seasonEnd = DateTime(2024, 3, 5);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay.isBefore(seasonStart) ? _focusedDay = seasonStart : null;
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Practice> _getEventsForDay(DateTime day) {
    return widget.practicesByDay[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Text(
                '2023-24 Season Schedule',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              TableCalendar<Practice>(
                firstDay: seasonStart,
                lastDay: seasonEnd,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                calendarBuilders: CalendarBuilders(
                  singleMarkerBuilder: (context, day, practice) {
                    Attendance attendance = widget.attendances.firstWhere(
                      (attendance) => attendance.id == practice.id,
                      orElse: () => Attendance.noUserCreate(practice),
                    );
                    IconData? icon;
                    if (attendance.attended) {
                      icon = Icons.check;
                    } else if (attendance.excusedAbsense) {
                      icon = Icons.shield;
                    } else if (attendance.unexcusedAbsense) {
                      icon = Icons.close;
                    }
                    return icon != null ? Icon(icon) : null;
                  },
                ),
                onDaySelected: _onDaySelected,
                availableCalendarFormats: const {CalendarFormat.month: "Month"},
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 8.0),
              ValueListenableBuilder(
                valueListenable: _selectedEvents,
                builder: (context, value, child) {
                  if (value.isNotEmpty) {
                    Attendance attendance = widget.attendances.firstWhere(
                      (attendance) => attendance.id == value.first.id,
                      orElse: () => Attendance.noUserCreate(value.first),
                    );
                    return CalendarDateInfo(
                      practice: value.first,
                      attendance: attendance,
                    );
                  } else {
                    return const ListTile(
                      title: Text(
                          "Select a day on the calendar above, with an event on it"),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
