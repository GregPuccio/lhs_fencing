import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_upcoming_events.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';
import 'package:material_symbols_icons/symbols.dart';

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
                          Symbols.swords,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text("Bouts"),
                      ],
                    ),
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
                    onTap: () => context.router.push(const DrillsListRoute()),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 2 - 10,
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
                    onTap: () => context.router.push(const LineupRoute()),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 4 - 25,
                width: MediaQuery.of(context).size.width / 2 - 10,
                child: Card(
                  child: InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_4x4,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        const Text("Round Robin"),
                      ],
                    ),
                    onTap: () => context.router.push(const PoolListRoute()),
                  ),
                ),
              ),
            ],
          ),
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
