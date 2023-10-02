import 'package:flutter/material.dart';
import 'package:lhs_fencing/src/models/link.dart';
import 'package:lhs_fencing/src/views/useful_links/useful_link_tile.dart';

class UsefulLinks extends StatelessWidget {
  const UsefulLinks({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 6;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: usefulLinks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "If you are unsure what you are looking for or have any questions about the below links, ask one of the coaches.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          index--;
          Link link = usefulLinks[index];
          return UsefulLinkTile(link: link, leadingWidth: width);
        }
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
