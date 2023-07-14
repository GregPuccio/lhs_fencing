import 'package:flutter/material.dart';

class NoEventsFound extends StatelessWidget {
  const NoEventsFound({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "No Events Found",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const ListTile(
                title: Text(
                  "Looks like the season schedule is not set up yet.",
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  "If you think this is an error, please let Coach Greg know.",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
