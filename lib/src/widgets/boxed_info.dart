import 'package:flutter/material.dart';

class BoxedInfo extends StatelessWidget {
  final String value;
  final String title;
  final Color? backgroundColor;
  const BoxedInfo(
      {super.key,
      required this.value,
      required this.title,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: kToolbarHeight,
      width: MediaQuery.of(context).size.width / 5,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
}
