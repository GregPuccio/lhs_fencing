import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/functions/bout_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class CreatePoolPage extends ConsumerStatefulWidget {
  const CreatePoolPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CreatePoolPageState();
}

class CreatePoolPageState extends ConsumerState<CreatePoolPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Weapon _selectedWeapon = Weapon.saber;
  Team _selectedTeam = Team.both;
  List<UserData> _selectedFencers = [];

  void _onNextPage() {
    if (_currentPage < 1) {
      setState(() {
        _currentPage++;
        _pageController.jumpToPage(_currentPage);
      });
    }
  }

  void _onPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.jumpToPage(_currentPage);
      });
    }
  }

  Future<void> _showSaveConfirmation(
      BuildContext context, VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Creation"),
          content: Text(
              "Are you sure you want to create this ${_selectedWeapon.type.toLowerCase()} pool of ${_selectedFencers.length} fencers?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Create"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create A Pool'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          CombinedPoolStep(
            selectedWeapon: _selectedWeapon,
            selectedTeam: _selectedTeam,
            selectedFencers: _selectedFencers,
            onWeaponChanged: (weapon) {
              setState(() {
                _selectedWeapon = weapon;
              });
            },
            onTeamChanged: (team) {
              setState(() {
                _selectedTeam = team;
              });
            },
            onFencersSelected: (fencers) {
              setState(() {
                _selectedFencers = fencers;
              });
            },
          ),
          FinalPoolSummaryStep(
            selectedWeapon: _selectedWeapon,
            selectedTeam: _selectedTeam,
            selectedFencers: _selectedFencers,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (disabled on the first page)
                  Flexible(
                    child: ElevatedButton(
                      onPressed: _currentPage > 0 ? _onPreviousPage : null,
                      child: const Text('Back'),
                    ),
                  ),

                  // Next button (disabled on the last page)
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          // TODO add a way to toggle a showing that the pool is being built
                          List<BoutMonth> months =
                              ref.read(thisSeasonBoutsProvider).value!;
                          _showSaveConfirmation(context, () async {
                            (Pool, List<List<Bout>>) data = Pool.create(
                              _selectedWeapon,
                              _selectedTeam,
                              _selectedFencers,
                            );
                            for (var i = 0; i < data.$2.length; i++) {
                              List<Bout> bouts = data.$2[i];
                              await addBoutPair(months, bouts);
                            }
                            await addPool(data.$1);
                            // TODO turn off the toggle and wait a second before closing then replace with the new page
                            // Return to the previous page
                            if (context.mounted) {
                              context.maybePop();
                            }
                          });
                        } else {
                          _onNextPage();
                        }
                      },
                      child: Text(isLastPage ? 'Create' : 'View Summary'),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CombinedPoolStep extends ConsumerStatefulWidget {
  final Weapon selectedWeapon;
  final Team selectedTeam;
  final List<UserData> selectedFencers;
  final ValueChanged<Weapon> onWeaponChanged;
  final ValueChanged<Team> onTeamChanged;
  final ValueChanged<List<UserData>> onFencersSelected;

  const CombinedPoolStep({
    super.key,
    required this.selectedWeapon,
    required this.selectedTeam,
    required this.selectedFencers,
    required this.onWeaponChanged,
    required this.onTeamChanged,
    required this.onFencersSelected,
  });

  @override
  ConsumerState<CombinedPoolStep> createState() => CombinedPoolStepState();
}

class CombinedPoolStepState extends ConsumerState<CombinedPoolStep> {
  List<UserData> visibleFencers = [];
  Set<UserData> manuallyDeselectedFencers = {};

  void _updateSelectedFencers(List<UserData> newVisibleFencers) {
    final newSelectedFencers = List<UserData>.from(widget.selectedFencers);

    // Auto-select newly visible fencers unless they were manually deselected
    for (final fencer in newVisibleFencers) {
      if (!manuallyDeselectedFencers.contains(fencer) &&
          !newSelectedFencers.contains(fencer)) {
        newSelectedFencers.add(fencer);
      }
    }

    // Remove deselected fencers that are no longer visible
    newSelectedFencers
        .retainWhere((fencer) => newVisibleFencers.contains(fencer));

    widget.onFencersSelected(newSelectedFencers);
  }

  @override
  Widget build(BuildContext context) {
    final fencersAsyncValue = ref.watch(fencersProvider);

    return fencersAsyncValue.when(
      data: (fencers) {
        // Filter fencers based on dropdown selections
        visibleFencers = fencers
            .where((fencer) => fencer.weapon == widget.selectedWeapon)
            .where((fencer) =>
                fencer.team == widget.selectedTeam ||
                widget.selectedTeam == Team.both)
            .toList();

        // Update selected fencers based on visible fencers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateSelectedFencers(visibleFencers);
        });

        return Column(
          children: [
            // Dropdown filters
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: Icon(
                        Symbols.swords,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<Weapon>(
                          value: widget.selectedWeapon,
                          isExpanded: true,
                          items: Weapon.weapons.map((weapon) {
                            return DropdownMenuItem<Weapon>(
                              value: weapon,
                              child: Text(weapon.type),
                            );
                          }).toList(),
                          onChanged: (Weapon? newWeapon) {
                            if (newWeapon != null) {
                              widget.onWeaponChanged(newWeapon);
                              manuallyDeselectedFencers.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ListTile(
                      leading: Icon(
                        Icons.groups,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<Team>(
                          value: widget.selectedTeam,
                          isExpanded: true,
                          items: Team.values.map((team) {
                            return DropdownMenuItem<Team>(
                              value: team,
                              child: Text(team.type),
                            );
                          }).toList(),
                          onChanged: (Team? newTeam) {
                            if (newTeam != null) {
                              widget.onTeamChanged(newTeam);
                              manuallyDeselectedFencers.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Fencer list with selection
            Expanded(
              child: ListView.separated(
                itemCount: visibleFencers.length,
                itemBuilder: (context, index) {
                  final fencer = visibleFencers[index];
                  final isSelected = widget.selectedFencers.contains(fencer) &&
                      !manuallyDeselectedFencers.contains(fencer);

                  return CheckboxListTile(
                    secondary: CircleAvatar(
                      child: Text("${index + 1}"),
                    ),
                    title: Text(fencer.fullName),
                    subtitle: widget.selectedTeam == Team.both
                        ? Text(fencer.team.type)
                        : null,
                    value: isSelected,
                    onChanged: (bool? isSelected) {
                      final newSelectedFencers =
                          List<UserData>.from(widget.selectedFencers);

                      if (isSelected == true) {
                        manuallyDeselectedFencers.remove(fencer);
                        newSelectedFencers.add(fencer);
                      } else {
                        manuallyDeselectedFencers.add(fencer);
                        newSelectedFencers.remove(fencer);
                      }

                      widget.onFencersSelected(newSelectedFencers);
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error loading fencers: $error')),
    );
  }
}

class FinalPoolSummaryStep extends StatelessWidget {
  final Weapon selectedWeapon;
  final Team selectedTeam;
  final List<UserData> selectedFencers;

  const FinalPoolSummaryStep({
    super.key,
    required this.selectedWeapon,
    required this.selectedTeam,
    required this.selectedFencers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: ListTile(
                  title: const Text("Selected Weapon"),
                  subtitle: Text(selectedWeapon.type),
                  leading: Icon(
                    Symbols.swords,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Flexible(
                child: ListTile(
                  title: const Text("Selected Team"),
                  subtitle: Text(selectedTeam.type),
                  leading: Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Text(
            "${selectedFencers.length} Selected Fencers:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: selectedFencers.length,
              itemBuilder: (context, index) {
                final fencer = selectedFencers[index];
                return ListTile(
                  title: Text(fencer.fullName),
                  subtitle:
                      selectedTeam == Team.both ? Text(fencer.team.type) : null,
                  leading: CircleAvatar(
                    child: Text("${index + 1}"),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
