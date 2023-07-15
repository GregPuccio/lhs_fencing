import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class UsefulLinks extends StatelessWidget {
  const UsefulLinks({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 6;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "If you are unsure what you are looking for or have any questions about the below links, ask one of the coaches.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Image.asset("assets/NJHSSportsLogo.png", width: width),
          title: Text(
            "NJ High School Sports - Girls",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "Official site for the most up to date results for all NJ high school girls fencing teams."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "highschoolsports.nj.com",
                "/school/livingston-livingston/girlsfencing/",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Image.asset("assets/NJHSSportsLogo.png", width: width),
          title: Text(
            "NJ High School Sports - Boys",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "Official site for the most up to date results for all NJ high school boys fencing teams."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "highschoolsports.nj.com",
                "/school/livingston-livingston/boysfencing/",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Image.asset("assets/ftlogo.png", width: width),
          title: Text(
            "Fencing Time Live - Tournament Results",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "Site where the majority of tournament results in the US are hosted including our highschool tournaments."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "www.fencingtimelive.com",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Image.asset("assets/USAFencingLogo.png", width: width),
          title: Text(
            "USA Fencing - Regional/National Tournaments",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "Best resource to find regional and national events to compete in as well as news about fencing in the US."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "www.usafencing.org",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Image.asset("assets/askfredlogo.png", width: width),
          title: Text(
            "AskFRED - Local Tournaments",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle:
              const Text("Best resource to find local events to compete in."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "www.askfred.net",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: SvgPicture.asset("assets/YouTubeLogo.svg", width: width),
          title: Text(
            "YouTube: USA Fencing",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "YouTube Channel for the USA Fencing Federation. You can find fencing videos, behind the scenes, and interviews with fencers here."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "youtube.com",
                "/user/USAFencing",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: SvgPicture.asset("assets/YouTubeLogo.svg", width: width),
          title: Text(
            "YouTube: FIE Fencing",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "YouTube Channel for the International Fencing Federation. You can find live competitions, fencing videos, and interviews with fencers here."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "youtube.com",
                "/user/FIEvideo",
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: SvgPicture.asset("assets/YouTubeLogo.svg", width: width),
          title: Text(
            "YouTube: CyrusOfChaos",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
              "YouTube Channel for fencing at all levels. You can find lots of great competition videos here along with some analysis videos."),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrl(
              Uri.https(
                "youtube.com",
                "/user/CyrusofChaos",
              ),
            );
          },
        ),
      ],
    );
  }
}
