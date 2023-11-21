import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/admin/equipment/equipment_widget.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';
import 'package:lhs_fencing/src/widgets/search_bar_widget.dart';
import 'package:lhs_fencing/src/widgets/text_badge.dart';

@RoutePage()
class EquipmentListPage extends ConsumerStatefulWidget {
  const EquipmentListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EquipmentListPageState();
}

class _EquipmentListPageState extends ConsumerState<EquipmentListPage> {
  late TextEditingController controller;
  List<Attendance> attendances = [];
  Team? teamFilter;
  Weapon? weaponFilter;
  SchoolYear? yearFilter;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> fencers = [];
    Widget whenFencerData(List<UserData> data) {
      fencers = data;
      List<UserData> filteredFencers = fencers.toList();
      if (controller.text.isNotEmpty) {
        filteredFencers = fencers
            .where(
              (f) => f.fullName.toLowerCase().contains(
                    controller.text.toLowerCase(),
                  ),
            )
            .toList();
      }
      if (teamFilter != null) {
        filteredFencers.retainWhere((fencer) => fencer.team == teamFilter);
      }
      if (yearFilter != null) {
        filteredFencers
            .retainWhere((fencer) => fencer.schoolYear == yearFilter);
      }
      if (weaponFilter != null) {
        filteredFencers.retainWhere((fencer) => fencer.weapon == weaponFilter);
      }
      return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Borrowed Equipment List"),
                const SizedBox(width: 8),
                TextBadge(text: "${fencers.length}"),
              ],
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SearchBarWidget(controller),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 15),
                      child: SizedBox(
                        height: 30,
                        child: Row(
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
                            if (yearFilter == null)
                              PopupMenuButton<SchoolYear>(
                                initialValue: yearFilter,
                                offset: const Offset(0, 30),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemBuilder: (context) =>
                                    List<PopupMenuItem<SchoolYear>>.generate(
                                  SchoolYear.values.length,
                                  (index) => PopupMenuItem(
                                    value: SchoolYear.values[index],
                                    child: Text(SchoolYear.values[index].type),
                                  ),
                                ).toList(),
                                icon: const Row(
                                  children: [
                                    Text("School Year"),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (SchoolYear value) => setState(() {
                                  yearFilter = value;
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
                                    yearFilter = null;
                                  }),
                                  icon: Row(children: [
                                    Text(yearFilter!.type),
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
            itemCount: filteredFencers.length,
            itemBuilder: (context, index) {
              UserData fencer = filteredFencers[index];

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      fencer.fullName,
                    ),
                    subtitle: Text(
                        "${fencer.team.type} | ${fencer.schoolYear.type} | ${fencer.weapon.type} Fencer"),
                    trailing: TextButton.icon(
                        onPressed: () async {
                          setState(() {
                            fencer.equipment.giveEquipment(fencer.weapon);
                          });
                          await FirestoreService.instance.updateData(
                            path: FirestorePath.user(fencer.id),
                            data: fencer.toMap(),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Kit")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EquipmentWidget(fencer, key: ObjectKey(fencer)),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ));
    }

    return ref.watch(fencersProvider).when(
          data: whenFencerData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
