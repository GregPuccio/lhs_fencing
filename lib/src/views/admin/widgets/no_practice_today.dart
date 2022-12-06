import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/services/router/router.dart';

class NoPracticeToday extends StatelessWidget {
  const NoPracticeToday({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "No Practice Today",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            ListTile(
              title: Text(
                "Is this a mistake?",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              trailing: const Icon(Icons.add),
              onTap: () => context.router.push(const AddPracticesRoute()),
            ),
          ],
        ),
      ),
    );
  }
}
