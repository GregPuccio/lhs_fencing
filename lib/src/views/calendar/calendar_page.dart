import 'dart:collection';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_event_list_tile.dart';
import 'package:lhs_fencing/src/views/home/widgets/attendance_tile.dart';
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
  DateTime seasonStart = DateTime(2025, 11, 1);
  DateTime seasonEnd = DateTime(2026, 3, 9);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay.isBefore(seasonStart)
        ? _focusedDay = seasonStart
        : _focusedDay.isAfter(seasonEnd)
            ? _focusedDay = seasonEnd
            : null;
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
    UserData userData = ref.watch(userDataProvider).value!;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar<Practice>(
              // rowHeight: 60,
              pageJumpingEnabled: true,
              firstDay: seasonStart,
              lastDay: seasonEnd,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: userData.admin
                    ? null
                    : (context, day, practice) {
                        Attendance attendance = widget.attendances.firstWhere(
                          (attendance) => attendance.id == practice.id,
                          orElse: () => Attendance.noUserCreate(practice),
                        );
                        Icon? icon;
                        if (attendance.attended) {
                          icon = const Icon(Icons.check,
                              size: 12, color: Colors.green);
                        } else if (attendance.excusedAbsense) {
                          icon = const Icon(Icons.shield,
                              size: 12, color: Colors.amber);
                        } else if (attendance.unexcusedAbsense) {
                          icon = const Icon(Icons.close,
                              size: 12, color: Colors.red);
                        }
                        return icon;
                      },
              ),
              onDaySelected: _onDaySelected,
              availableCalendarFormats: const {CalendarFormat.month: "Month"},
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Flexible(
            child: ValueListenableBuilder(
              valueListenable: _selectedEvents,
              builder: (context, value, child) {
                if (value.isNotEmpty) {
                  return ListView.separated(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      Practice practice = value[index];
                      if (userData.admin) {
                        return AdminEventListTile(
                          practice: practice,
                          attendances: widget.attendances,
                        );
                      } else {
                        Attendance attendance = widget.attendances.firstWhere(
                          (attendance) => attendance.id == practice.id,
                          orElse: () => Attendance.noUserCreate(practice),
                        );
                        return AttendanceTile(
                          practice: practice,
                          attendance: attendance,
                        );
                      }
                    },
                    separatorBuilder: (context, index) => Divider(),
                  );
                } else {
                  return const ListTile(
                    title: Text(
                        "Select a day on the calendar above, with an event on it"),
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton:
          ref.watch(userDataProvider).asData?.value?.admin == true
              ? FloatingActionButton(
                  heroTag: "CalendarFAB",
                  onPressed: () => context
                      .pushRoute(AddPracticesRoute(practiceDate: _focusedDay)),
                  child: const Icon(Icons.add),
                )
              : null,
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
