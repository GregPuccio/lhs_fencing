import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link {
  String image;
  String title;
  String? subtitle;
  IconData? trailing;
  VoidCallback onTap;
  Link({
    required this.image,
    required this.title,
    this.subtitle,
    this.trailing = Icons.open_in_new,
    required this.onTap,
  });

  Link copyWith({
    String? image,
    String? title,
    ValueGetter<String?>? subtitle,
    ValueGetter<IconData?>? trailing,
    VoidCallback? onTap,
  }) {
    return Link(
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle != null ? subtitle() : this.subtitle,
      trailing: trailing != null ? trailing() : this.trailing,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  String toString() {
    return 'Link(image: $image, title: $title, subtitle: $subtitle, trailing: $trailing, onTap: $onTap)';
  }
}

List<Link> usefulLinks = [
  Link(
    image: "assets/NJHSSportsLogo.png",
    title: "NJ High School Sports - Girls",
    subtitle:
        "Official site for the most up to date results for all NJ high school girls fencing teams.",
    onTap: () {
      launchUrl(
        Uri.https(
          "highschoolsports.nj.com",
          "/school/livingston-livingston/girlsfencing/",
        ),
      );
    },
  ),
  Link(
    image: "assets/NJHSSportsLogo.png",
    title: "NJ High School Sports - Boys",
    subtitle:
        "Official site for the most up to date results for all NJ high school boys fencing teams.",
    onTap: () {
      launchUrl(
        Uri.https(
          "highschoolsports.nj.com",
          "/school/livingston-livingston/boysfencing/",
        ),
      );
    },
  ),
  Link(
    image: "assets/ftlogo.png",
    title: "Fencing Time Live - Tournament Results",
    subtitle:
        "Site where the majority of tournament results in the US are hosted including our highschool tournaments.",
    onTap: () {
      launchUrl(
        Uri.https("www.fencingtimelive.com"),
      );
    },
  ),
  Link(
    image: "assets/USAFencingLogo.png",
    title: "USA Fencing - Regional/National Tournaments",
    subtitle:
        "Best resource to find regional and national events to compete in as well as news about fencing in the US.",
    onTap: () {
      launchUrl(
        Uri.https("www.usafencing.org"),
      );
    },
  ),
  Link(
    image: "assets/askfredlogo.png",
    title: "AskFRED - Local Tournaments",
    subtitle: "Best resource to find local events to compete in.",
    onTap: () {
      launchUrl(
        Uri.https("www.askfred.net"),
      );
    },
  ),
  Link(
    image: "assets/YouTubeLogo.svg",
    title: "YouTube: USA Fencing",
    subtitle:
        "YouTube Channel for the USA Fencing Federation. You can find fencing videos, behind the scenes, and interviews with fencers here.",
    onTap: () {
      launchUrl(
        Uri.https(
          "youtube.com",
          "/user/USAFencing",
        ),
      );
    },
  ),
  Link(
    image: "assets/YouTubeLogo.svg",
    title: "YouTube: FIE Fencing",
    subtitle:
        "YouTube Channel for the International Fencing Federation. You can find live competitions, fencing videos, and interviews with fencers here.",
    onTap: () {
      launchUrl(
        Uri.https(
          "youtube.com",
          "/user/FIEvideo",
        ),
      );
    },
  ),
  Link(
    image: "assets/YouTubeLogo.svg",
    title: "YouTube: CyrusOfChaos",
    subtitle:
        "YouTube Channel for fencing at all levels. You can find lots of great competition videos here along with some analysis videos.",
    onTap: () {
      launchUrl(
        Uri.https(
          "youtube.com",
          "/user/CyrusofChaos",
        ),
      );
    },
  ),
];
