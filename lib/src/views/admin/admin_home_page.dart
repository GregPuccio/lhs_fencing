import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_upcoming_events.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  final void Function(int) updateIndexFn;
  const AdminHomePage({super.key, required this.updateIndexFn});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int currentIndex = 0;

  void updateIndex(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 75),
        children: [
          const WelcomeHeader(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 4 - 10,
                child: Card(
                  child: InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text("Fencers"),
                      ],
                    ),

                    // subtitle:
                    //     const Text("View fencers and their participation info"),
                    // trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.router.push(const FencerListRoute()),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 4 - 10,
                child: Card(
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.accessibility_new,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Gear",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // subtitle: const Text(
                    //     "View and edit the equipment fencers have borrowed"),
                    // trailing: const Icon(Icons.arrow_forward),
                    onTap: () =>
                        context.router.push(const EquipmentListRoute()),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 4 - 10,
                child: Card(
                  child: InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text("Bouts"),
                      ],
                    ),

                    // subtitle:
                    //     const Text("View fencers and their participation info"),
                    // trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.router.push(const BoutHistoryRoute()),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 4 - 10,
                child: Card(
                  child: InkWell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text("Drills"),
                      ],
                    ),
                    // subtitle: const Text(
                    //     "View and edit the equipment fencers have borrowed"),
                    // trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.router.push(const DrillsListRoute()),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width / 4 - 25,
            width: MediaQuery.of(context).size.width / 4 - 10,
            child: Card(
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text("Lineup"),
                  ],
                ),

                // subtitle:
                //     const Text("View fencers and their participation info"),
                // trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.router.push(const LineupRoute()),
              ),
            ),
          ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.event),
          //   title: const Text("Meets and Tournaments List"),
          //   subtitle: const Text("View all upcoming meets and tournaments"),
          //   trailing: const Icon(Icons.arrow_forward),
          //   onTap: () => context.router.push(EventsListRoute()),
          // ),
          // ListTile(
          //   title: const Text("Tap Here"),
          //   onTap: () => getCurrentBoysStats(context),
          // ),
          const Divider(),
          AdminUpcomingEvents(updateIndexFn: widget.updateIndexFn),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "HomeFAB",
        onPressed: () => context.pushRoute(AddPracticesRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
