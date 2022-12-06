import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/services/router/router.dart';

class TodaysPractice extends StatelessWidget {
  const TodaysPractice({
    Key? key,
    required this.formattedDate,
    required this.currentPractice,
  }) : super(key: key);

  final String formattedDate;
  final Practice currentPractice;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Today's Practice",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              title: Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.router.push(
                PracticeRoute(practice: currentPractice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
