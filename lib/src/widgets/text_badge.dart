import 'package:flutter/material.dart';

class TextBadge extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool title;
  const TextBadge(
      {required this.text, this.style, this.title = false, super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    Color color = title
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.tertiaryContainer;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle?.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
