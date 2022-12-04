import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "We seem to have found an error!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 10),
            const Text(
              "Please report what you did to get here to your system admin so we can get this fixed asap",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
