import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/models/activities.dart';
import 'package:lhs_fencing/src/models/practice.dart';

class EventSchedule extends StatelessWidget {
  final Practice practice;
  const EventSchedule({required this.practice, super.key});

  @override
  Widget build(BuildContext context) {
    Map<DateTime, String> activities = Activities(practice).activities;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${practice.type.type} Schedule",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        DataTable(
          // decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.primaryContainer),
          border:
              TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
          headingTextStyle: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(
              label: Expanded(
                child: Text(
                  "Time",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                  child: Text(
                "Activity",
                textAlign: TextAlign.center,
              )),
            ),
          ],
          rows: List.generate(
            activities.length,
            (index) => DataRow(cells: [
              DataCell(
                Text(
                  DateFormat("hh:mm aa").format(
                    activities.keys.elementAt(index),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    activities.values.elementAt(index),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
