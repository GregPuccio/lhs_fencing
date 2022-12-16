import 'package:flutter/material.dart';

class BoxedInfo extends StatelessWidget {
  final String value;
  final String title;
  final bool isSelected;
  final Color? backgroundColor;
  final VoidCallback onTap;
  const BoxedInfo({
    super.key,
    required this.value,
    required this.title,
    required this.isSelected,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: kTextTabBarHeight,
      width: MediaQuery.of(context).size.width / 5,
      decoration: BoxDecoration(
        color: backgroundColor?.withAlpha(isSelected ? 255 : 125),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: isSelected ? FontWeight.bold : null),
            ),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  ?.copyWith(fontWeight: isSelected ? FontWeight.bold : null),
            ),
          ],
        ),
      ),
    );
  }
}
