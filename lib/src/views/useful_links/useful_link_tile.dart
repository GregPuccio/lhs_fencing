import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lhs_fencing/src/models/link.dart';

class UsefulLinkTile extends StatelessWidget {
  final Link link;
  final double leadingWidth;
  const UsefulLinkTile(
      {required this.link, required this.leadingWidth, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: link.image.endsWith(".svg")
              ? SvgPicture.asset("assets/YouTubeLogo.svg", width: leadingWidth)
              : Image.asset(
                  link.image,
                  width: leadingWidth,
                ),
        ),
      ),
      title: Text(
        link.title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: link.subtitle != null ? Text(link.subtitle!) : null,
      trailing: Icon(link.trailing),
      onTap: link.onTap,
    );
  }
}
