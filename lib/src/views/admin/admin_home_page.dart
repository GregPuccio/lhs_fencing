import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_symbols_icons/symbols.dart';

// Import necessary route and widget files
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/views/admin/widgets/admin_upcoming_events.dart';
import 'package:lhs_fencing/src/widgets/welcome_header.dart';

/// Admin home page providing quick access to various management sections
class AdminHomePage extends ConsumerStatefulWidget {
  /// Callback function to update the bottom navigation index
  final void Function(int) updateIndexFn;

  /// Constructor for AdminHomePage
  const AdminHomePage({
    super.key,
    required this.updateIndexFn,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  /// Current selected index for navigation
  int currentIndex = 0;

  /// Updates the current index when a new index is selected
  void updateIndex(int newIndex) {
    setState(() {
      currentIndex = newIndex;
    });
  }

  /// Builds a custom card for navigation with an icon and text
  Widget _buildNavigationCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int numberOfTiles = 4,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 4 - 25,
      width: MediaQuery.of(context).size.width / numberOfTiles - 10,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main body with scrollable list of sections
      body: ListView(
        padding: const EdgeInsets.only(bottom: 75),
        children: [
          // Welcome header at the top of the page
          const WelcomeHeader(),

          // Divider to separate sections
          const Divider(),

          // First row of navigation cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Fencers navigation card
              _buildNavigationCard(
                icon: Icons.people,
                label: "Fencers",
                onTap: () => context.router.push(const FencerListRoute()),
              ),

              // Gear navigation card
              _buildNavigationCard(
                icon: Icons.accessibility_new,
                label: "Gear",
                onTap: () => context.router.push(const EquipmentListRoute()),
              ),

              // Bouts navigation card
              _buildNavigationCard(
                icon: Symbols.swords,
                label: "Bouts",
                onTap: () => context.router.push(const BoutHistoryRoute()),
              ),

              // Drills navigation card
              _buildNavigationCard(
                icon: Icons.fitness_center,
                label: "Drills",
                onTap: () => context.router.push(const DrillsListRoute()),
              ),
            ],
          ),

          // Second row of navigation cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Lineup navigation card
              _buildNavigationCard(
                icon: Icons.list,
                label: "Lineup",
                numberOfTiles: 2,
                onTap: () => context.router.push(const LineupRoute()),
              ),

              // Round Robin navigation card
              _buildNavigationCard(
                icon: Icons.grid_4x4,
                label: "Round Robin",
                numberOfTiles: 2,
                onTap: () => context.router.push(const PoolListRoute()),
              ),
            ],
          ),

          // Divider to separate navigation from upcoming events
          const Divider(),

          // Upcoming events section
          AdminUpcomingEvents(updateIndexFn: widget.updateIndexFn),
        ],
      ),

      // Floating action button to add new practices
      floatingActionButton: FloatingActionButton(
        heroTag: "HomeFAB",
        onPressed: () => context.pushRoute(AddPracticesRoute()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
