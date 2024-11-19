import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/constants/enums.dart';

class TextBadge extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Weapon? weapon;
  final bool title;
  const TextBadge(
      {required this.text,
      this.style,
      this.title = false,
      this.weapon,
      super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    Color color = title
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.tertiaryContainer;
    if (weapon != null) {
      switch (weapon) {
        case Weapon.epee:
          color = Theme.of(context).colorScheme.primaryContainer;
        case Weapon.saber:
          color = Theme.of(context).colorScheme.secondaryContainer;
        case Weapon.foil:
          color = Theme.of(context).colorScheme.errorContainer;
        case Weapon.unsure:
        case Weapon.manager:
        case null:
          color = Theme.of(context).colorScheme.surface;
      }
    }
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
