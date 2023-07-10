import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    required this.isTouched,
    this.size = 16,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final bool isTouched;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
            color: isTouched ? Theme.of(context).indicatorColor : null,
          ),
        )
      ],
    );
  }
}
