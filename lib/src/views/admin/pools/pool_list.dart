import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/services/router/router.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class PoolListPage extends ConsumerStatefulWidget {
  const PoolListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PoolListPageState();
}

class _PoolListPageState extends ConsumerState<PoolListPage> {
  Team? teamFilter;
  Weapon? weaponFilter;

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<Pool> pools) {
      List<Pool> filteredPools = pools.toList();

      if (teamFilter != null) {
        filteredPools.retainWhere((pool) => pool.team == teamFilter);
      }
      if (weaponFilter != null) {
        filteredPools.retainWhere((pool) => pool.weapon == weaponFilter);
      }

      return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => context.pushRoute(CreatePoolRoute()),
          ),
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Round Robin List"),
                const SizedBox(width: 8),
                TextBadge(text: "${filteredPools.length}/${pools.length}"),
              ],
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 15),
                      child: SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            if (teamFilter == null)
                              PopupMenuButton<Team>(
                                initialValue: teamFilter,
                                offset: const Offset(0, 30),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemBuilder: (context) =>
                                    List<PopupMenuItem<Team>>.generate(
                                  Team.values.length - 1,
                                  (index) => PopupMenuItem(
                                    value: Team.values[index],
                                    child: Text(Team.values[index].type),
                                  ),
                                ).toList(),
                                icon: const Row(
                                  children: [
                                    Text("Team"),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (Team value) => setState(() {
                                  teamFilter = value;
                                }),
                              )
                            else
                              Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: IconButton(
                                  iconSize: 16,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  onPressed: () => setState(() {
                                    teamFilter = null;
                                  }),
                                  icon: Row(children: [
                                    Text(teamFilter!.type),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.cancel)
                                  ]),
                                ),
                              ),
                            if (weaponFilter == null)
                              PopupMenuButton<Weapon>(
                                initialValue: weaponFilter,
                                offset: const Offset(0, 30),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemBuilder: (context) =>
                                    List<PopupMenuItem<Weapon>>.generate(
                                  Weapon.values.length,
                                  (index) => PopupMenuItem(
                                    value: Weapon.values[index],
                                    child: Text(Weapon.values[index].type),
                                  ),
                                ).toList(),
                                icon: const Row(
                                  children: [
                                    Text("Weapon"),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (Weapon value) => setState(() {
                                  weaponFilter = value;
                                }),
                              )
                            else
                              Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: IconButton(
                                  iconSize: 16,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  onPressed: () => setState(() {
                                    weaponFilter = null;
                                  }),
                                  icon: Row(children: [
                                    Text(weaponFilter!.type),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.cancel)
                                  ]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.only(bottom: 60),
            itemCount: filteredPools.length,
            itemBuilder: (context, index) {
              Pool pool = filteredPools[index];
              return ListTile(
                leading: const Icon(Icons.grid_4x4),
                title: Text(
                    "${pool.fencers.length} Fencer Pool | ${pool.team.type} | ${pool.weapon.type}"),
                subtitle: Text("${pool.bouts.length / 2} bouts"),
                onTap: () => context.router.push(
                  EditPoolRoute(poolID: pool.id),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
    }

    return ref.watch(poolsProvider).when(
          data: whenData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
