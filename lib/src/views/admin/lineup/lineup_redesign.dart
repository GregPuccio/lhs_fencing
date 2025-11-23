// lineup_redesign.dart
// Full replacement for LineupPage + CreateLineupPage with redesigned UI
// Drop this file into your lib/ and adjust imports if needed.

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

// ---------- Helper provider: compute adjustments and flattened data ----------
final lineupDataProvider = Provider.autoDispose
    .family<LineupComputedData?, Map<String, dynamic>>((ref, params) {
  final team = params['team'] as Team?;
  final weapon = params['weapon'] as Weapon?;
  if (team == null || weapon == null) return null;

  final lineupsValue = ref.watch(lineupsProvider);
  final practicesValue = ref.watch(thisSeasonPracticesProvider);
  final attendancesValue = ref.watch(thisSeasonAttendancesProvider);
  final fencers = ref.read(activeFencersProvider);

  if (lineupsValue is AsyncData<List<Lineup>> &&
      practicesValue is AsyncData<List<PracticeMonth>> &&
      attendancesValue is AsyncData<List<AttendanceMonth>>) {
    final allLineups = lineupsValue.value
        .where((l) => l.team == team && l.weapon == weapon)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final currentLineup = allLineups.isEmpty ? null : allLineups.last;

    List<Practice> practices = [];
    for (var pm in practicesValue.value) {
      practices.addAll(pm.practices);
    }
    practices = practices.where((p) => p.isOver).toList();

    List<Attendance> attendances = [];
    for (var am in attendancesValue.value) {
      attendances.addAll(am.attendances);
    }

    final fencersToShow =
        fencers.where((f) => f.team == team && f.weapon == weapon).toList();

    // unaccounted practices (practices with types that adjust lineup and not already added)
    final unaccountedPractices = practices
        .where((p) =>
            !(currentLineup?.practicesAdded.contains(p.id) ?? false) &&
            p.type.adjustsLineup)
        .toList();
    final unaccountedAttendances = attendances
        .where((a) => !(currentLineup?.practicesAdded.contains(a.id) ?? false))
        .toList();

    // compute adjustments per fencer (based on unexcused absence only)
    final Map<String, int> adjustAmounts = {};

    final fencerList = currentLineup?.fencers.toList() ?? [];

    for (var fencer in fencerList) {
      final fencerAttendances = unaccountedAttendances
          .where((a) => a.userData.id == fencer.id)
          .toList();

      final unexcused =
          fencerAttendances.where((a) => a.unexcusedAbsense).toList();

      double adjustment = 0;
      for (var practice in unaccountedPractices) {
        if (unexcused.any((a) => a.id == practice.id)) {
          // if it's a regular practice => 1, otherwise (meet) => 3
          if (practice.type == TypePractice.practice) {
            adjustment += 1;
          } else {
            adjustment += 3;
          }
        }
      }

      adjustAmounts[fencer.id] = adjustment.round();
    }

    // cap adjustments so no-one drops more than number of people behind them
    if (adjustAmounts.isNotEmpty) {
      for (int i = 0; i < fencerList.length; i++) {
        final f = fencerList[i];
        final adj = adjustAmounts.putIfAbsent(f.id, () => 0);
        final numBelowNoAdjust =
            adjustAmounts.values.skip(i + 1).where((v) => v == 0).length;
        if (adj > numBelowNoAdjust) {
          adjustAmounts[f.id] = numBelowNoAdjust;
        }
      }
    }

    return LineupComputedData(
      currentLineup: currentLineup,
      allLineups: allLineups,
      fencersToShow: fencersToShow,
      fencersNoLongerInWeapon: currentLineup?.fencers
              .where((f) => !fencersToShow.contains(f))
              .toList() ??
          [],
      fencersNotInLineup: fencersToShow
          .where((f) => !(currentLineup?.fencers.contains(f) ?? false))
          .toList(),
      unaccountedPractices: unaccountedPractices,
      unaccountedAttendances: unaccountedAttendances,
      adjustAmounts: adjustAmounts,
    );
  }

  return null;
});

class LineupComputedData {
  final Lineup? currentLineup;
  final List<Lineup> allLineups;
  final List<UserData> fencersToShow;
  final List<UserData> fencersNoLongerInWeapon;
  final List<UserData> fencersNotInLineup;
  final List<Practice> unaccountedPractices;
  final List<Attendance> unaccountedAttendances;
  final Map<String, int> adjustAmounts;

  LineupComputedData({
    required this.currentLineup,
    required this.allLineups,
    required this.fencersToShow,
    required this.fencersNoLongerInWeapon,
    required this.fencersNotInLineup,
    required this.unaccountedPractices,
    required this.unaccountedAttendances,
    required this.adjustAmounts,
  });
}

// ------------------- Redesigned Lineup Page -------------------
@RoutePage()
class LineupRedesign extends ConsumerStatefulWidget {
  const LineupRedesign({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LineupRedesignPageState();
}

class _LineupRedesignPageState extends ConsumerState<LineupRedesign> {
  Team? teamFilter;
  Weapon? weaponFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lineup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(child: _buildTeamPicker(context)),
                const SizedBox(width: 8),
                Expanded(child: _buildWeaponPicker(context)),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                )
              ],
            ),
          ),
        ),
      ),
      body: teamFilter == null || weaponFilter == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select a Team and Weapon to view the current lineup.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          : _buildBody(context),
      floatingActionButton: teamFilter != null && weaponFilter != null
          ? FloatingActionButton.extended(
              onPressed: () {
                final params = {'team': teamFilter!, 'weapon': weaponFilter!};
                final data = ref.read(lineupDataProvider(params));
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CreateLineupRedesignPage(
                          team: teamFilter!,
                          weapon: weaponFilter!,
                          adjustAmounts: data?.adjustAmounts ?? {},
                          unaccountedPractices:
                              data?.unaccountedPractices ?? [],
                        )));
              },
              label: const Text('Create / Update'),
              icon: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildTeamPicker(BuildContext context) {
    if (teamFilter == null) {
      return OutlinedButton(
        onPressed: () async {
          final chosen = await showModalBottomSheet<Team?>(
              context: context,
              builder: (_) => _pickerSheet<Team>(
                  Team.values
                      .where((t) => t != Team.both)
                      .toList()
                      .map((t) => t.type)
                      .toList(),
                  Team.values.where((t) => t != Team.both).toList()));
          if (chosen != null) setState(() => teamFilter = chosen);
        },
        child: const Text('Select Team'),
      );
    }
    return Chip(
      avatar: const Icon(Icons.group),
      label: Text(teamFilter!.type),
      onDeleted: () => setState(() => teamFilter = null),
    );
  }

  Widget _buildWeaponPicker(BuildContext context) {
    if (weaponFilter == null) {
      return OutlinedButton(
        onPressed: () async {
          final chosen = await showModalBottomSheet<Weapon?>(
              context: context,
              builder: (_) => _pickerSheet<Weapon>(
                  Weapon.values.map((w) => w.type).toList(),
                  Weapon.values.toList()));
          if (chosen != null) setState(() => weaponFilter = chosen);
        },
        child: const Text('Select Weapon'),
      );
    }
    return Chip(
      avatar: const Icon(Icons.sports_martial_arts),
      label: Text(weaponFilter!.type),
      onDeleted: () => setState(() => weaponFilter = null),
    );
  }

  static Widget _pickerSheet<T>(List<String> labels, List<T> values) {
    return ListView.separated(
      itemCount: labels.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, idx) {
        return ListTile(
          title: Text(labels[idx]),
          onTap: () => Navigator.of(context).pop(values[idx]),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final params = {'team': teamFilter!, 'weapon': weaponFilter!};
    final computedAsync = ref.watch(lineupDataProvider(params));

    if (computedAsync == null) {
      // wait for underlying providers
      return ref.watch(lineupsProvider).when(
            data: (_) => const LoadingPage(),
            loading: () => const LoadingPage(),
            error: (_, __) => const ErrorPage(),
          );
    }

    final data = computedAsync;
    final current = data.currentLineup;

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _summaryCard(context, data),
          const SizedBox(height: 12),
          _startersRow(context, data),
          const SizedBox(height: 12),
          const Text('Ranked Fencers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                (current?.fencers.length ?? 0) + data.fencersNotInLineup.length,
            onReorder: (from, to) {
              // simple local reordering preview — saving occurs in Create page
              setState(() {
                final all = (current?.fencers ?? []) + data.fencersNotInLineup;
                if (from < to) to -= 1;
                final item = all.removeAt(from);
                all.insert(to, item);
                // can't directly modify backend here — we'll send this order to Create page when user taps FAB
              });
            },
            itemBuilder: (context, index) {
              if (index < (current?.fencers.length ?? 0)) {
                final fencer = current!.fencers[index];
                final isStarter = current.starters.contains(fencer);
                final adjust =
                    data.adjustAmounts.putIfAbsent(fencer.id, () => 0);
                final removed = data.fencersNoLongerInWeapon.contains(fencer);
                return Card(
                  key: ValueKey('f${fencer.id}'),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isStarter
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      foregroundColor: isStarter
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                      child: Text('${index + 1}'),
                    ),
                    title: Row(children: [
                      Expanded(child: Text(fencer.fullName)),
                      if (isStarter)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('STARTER',
                              style: TextStyle(fontSize: 12)),
                        ),
                      const SizedBox(width: 8),
                      Text(fencer.rating.isEmpty ? 'U' : fencer.rating),
                    ]),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Practices Missed: ${_practicesMissedFor(fencer, data)}   Meets Missed: ${_meetsMissedFor(fencer, data)}'),
                          const SizedBox(height: 4),
                          Row(children: [
                            if (adjust > 0) ...[
                              Icon(Icons.arrow_downward,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 18),
                              const SizedBox(width: 4),
                              Text('-$adjust',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ],
                            if (removed) ...[
                              const SizedBox(width: 12),
                              Text('Removed from weapon',
                                  style: TextStyle(color: Colors.grey)),
                            ]
                          ])
                        ]),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () =>
                          _showFencerDetails(context, fencer, data),
                    ),
                  ),
                );
              } else {
                final idx = index - (current?.fencers.length ?? 0);
                final fencer = data.fencersNotInLineup[idx];
                return Card(
                  key: ValueKey('outs${fencer.id}'),
                  color: Colors.yellow.shade50,
                  child: ListTile(
                    leading: const CircleAvatar(child: Text('-')),
                    title: Text(fencer.fullName),
                    subtitle: Text(
                        'Not in current lineup — Rating: ${fencer.rating.isEmpty ? 'U' : fencer.rating}'),
                    trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () =>
                            _showFencerDetails(context, fencer, data)),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          if (data.unaccountedPractices.isNotEmpty) ...[
            const Text('Unaccounted Practices / Meets:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: data.unaccountedPractices
                  .map((p) => Chip(
                      label: Text(
                          '${p.type.abbrev} ${DateFormat('MM/dd').format(p.startTime)}')))
                  .toList(),
            ),
          ]
        ],
      ),
    );
  }

  static int _practicesMissedFor(UserData f, LineupComputedData data) {
    final unexcused = data.unaccountedAttendances
        .where((a) => a.userData.id == f.id && a.unexcusedAbsense)
        .toList();
    return unexcused
        .where((a) => data.unaccountedPractices
            .where((p) => p.id == a.id && p.type == TypePractice.practice)
            .isNotEmpty)
        .length;
  }

  static int _meetsMissedFor(UserData f, LineupComputedData data) {
    final unexcused = data.unaccountedAttendances
        .where((a) => a.userData.id == f.id && a.unexcusedAbsense)
        .toList();
    final practicesMissed = unexcused
        .where((a) => data.unaccountedPractices
            .where((p) => p.id == a.id && p.type == TypePractice.practice)
            .isNotEmpty)
        .length;
    return unexcused.length - practicesMissed;
  }

  Widget _summaryCard(BuildContext context, LineupComputedData data) {
    final current = data.currentLineup;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Current Lineup',
                style: Theme.of(context).textTheme.titleMedium),
            if (current != null)
              Text(
                  DateFormat("EEE, MM/dd/y 'at' hh:mm a")
                      .format(current.createdAt),
                  style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            Chip(
                label:
                    Text('Unaccounted: ${data.unaccountedPractices.length}')),
            Chip(
                label: Text(
                    'Adjustments: ${data.adjustAmounts.values.where((v) => v > 0).length}')),
            Chip(label: Text('Fencers: ${data.fencersToShow.length}')),
          ])
        ]),
      ),
    );
  }

  Widget _startersRow(BuildContext context, LineupComputedData data) {
    final current = data.currentLineup;
    if (current == null) return const SizedBox.shrink();
    final starters = current.starters;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Starters', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: starters
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                          avatar: CircleAvatar(
                              child: Text((current.starters.indexOf(s) + 1)
                                  .toString())),
                          label: Text(s.fullName)),
                    ))
                .toList(),
          )
        ]),
      ),
    );
  }

  void _showFencerDetails(
      BuildContext context, UserData fencer, LineupComputedData data) {
    final adjust = data.adjustAmounts.putIfAbsent(fencer.id, () => 0);
    final fAtt = data.unaccountedAttendances
        .where((a) => a.userData.id == fencer.id)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fencer.fullName,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Adjust: -$adjust')
                    ]),
                const SizedBox(height: 8),
                Text('Rating: ${fencer.rating.isEmpty ? 'U' : fencer.rating}'),
                const SizedBox(height: 8),
                const Text('Attendance breakdown:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...fAtt.map((a) => ListTile(
                      dense: true,
                      title: Text(
                          '${a.participated ? 'Fenced' : (a.unexcusedAbsense ? 'Unexcused' : 'Excused')} - ${DateFormat('MM/dd').format(a.practiceStart)}'),
                      subtitle: Text(
                          'Check-in: ${a.checkIn != null ? DateFormat('hh:mm').format(a.checkIn!) : '—'} | Check-out: ${a.checkOut != null ? DateFormat('hh:mm').format(a.checkOut!) : '—'}'),
                    )),
              ]),
        );
      },
    );
  }
}

// ------------------- Create Lineup Redesign Page -------------------
@RoutePage()
class CreateLineupRedesignPage extends ConsumerStatefulWidget {
  final Team team;
  final Weapon weapon;
  final Map<String, int> adjustAmounts;
  final List<Practice> unaccountedPractices;

  const CreateLineupRedesignPage(
      {required this.team,
      required this.weapon,
      required this.adjustAmounts,
      required this.unaccountedPractices,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateLineupRedesignPageState();
}

class _CreateLineupRedesignPageState
    extends ConsumerState<CreateLineupRedesignPage> {
  late List<Lineup> lineups;
  late List<UserData> fencers;
  late List<UserData> fencersToShow;
  List<UserData> starters = [];
  bool loadFencers = true;
  Lineup? currentLineup;

  @override
  Widget build(BuildContext context) {
    return ref.watch(lineupsProvider).when(
          data: (lineupsData) {
            lineups = lineupsData;
            if (loadFencers) {
              fencers = ref.read(activeFencersProvider);

              final filteredLineups = lineups
                  .where(
                      (l) => l.team == widget.team && l.weapon == widget.weapon)
                  .toList();
              currentLineup =
                  filteredLineups.isEmpty ? null : filteredLineups.last;

              fencersToShow = fencers
                  .where(
                      (f) => f.team == widget.team && f.weapon == widget.weapon)
                  .toList();
              final fencersNotInLineup = fencersToShow
                  .where((f) => !(currentLineup?.fencers.contains(f) ?? false))
                  .toList();

              final fencersNoLongerInWeapon = currentLineup?.fencers
                      .where((f) => !(fencersToShow.contains(f)))
                      .toList() ??
                  [];
              if (currentLineup != null) {
                currentLineup!.fencers.removeWhere(
                    (f) => fencersNoLongerInWeapon.any((n) => n.id == f.id));
                starters = currentLineup!.starters;
              }

              fencersToShow =
                  (currentLineup?.fencers ?? []) + fencersNotInLineup;

              // apply adjustAmounts to reorder fencers locally for preview
              final adjusted = fencersToShow.reversed.toList();
              for (int i = 0; i < adjusted.length; i++) {
                final f = adjusted[i];
                final adj = widget.adjustAmounts.putIfAbsent(f.id, () => 0);
                if (i - adj >= 0) {
                  final item = adjusted.removeAt(i);
                  adjusted.insert(i - adj, item);
                } else {
                  final item = adjusted.removeAt(i);
                  adjusted.insert(0, item);
                }
              }
              fencersToShow = adjusted.reversed.toSet().toList();

              loadFencers = false;
            }

            return ref.watch(thisSeasonAttendancesProvider).when(
                  data: (attendanceMonths) => _buildCreateScaffold(context),
                  loading: () => const LoadingPage(),
                  error: (_, __) => const ErrorPage(),
                );
          },
          loading: () => const LoadingPage(),
          error: (_, __) => const ErrorPage(),
        );
  }

  Widget _buildCreateScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lineup')),
      body: ReorderableListView.builder(
        header: Column(children: [
          ListTile(
              leading: const Icon(Icons.sports_martial_arts),
              title: Text(widget.weapon.type),
              subtitle: const Text('Weapon')),
          ListTile(
              leading: const Icon(Icons.group),
              title: Text(widget.team.type),
              subtitle: const Text('Team')),
          const Divider(),
        ]),
        itemCount: fencersToShow.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final item = fencersToShow.removeAt(oldIndex);
            fencersToShow.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final f = fencersToShow[index];
          final adj = widget.adjustAmounts.putIfAbsent(f.id, () => 0);

          return CheckboxListTile(
            key: ValueKey(f.id),
            value: starters.contains(f),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  if (!starters.contains(f)) starters.add(f);
                } else {
                  starters.remove(f);
                }
              });
            },
            secondary: CircleAvatar(child: Text('${index + 1}')),
            title: Row(children: [
              Text(f.fullName),
              const SizedBox(width: 8),
              Text(f.rating.isEmpty ? 'U' : f.rating)
            ]),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (adj > 0)
                Text('Dropped $adj position${adj > 1 ? 's' : ''}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ]),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save Lineup'),
          onPressed: () async {
            final lineup = Lineup.create(
              fencers: fencersToShow,
              starters: starters,
              practices: (currentLineup?.practicesAdded ?? []) +
                  widget.unaccountedPractices.map((p) => p.id).toList(),
            );

            await FirestoreService.instance.setData(
                path: FirestorePath.lineup(lineup.id), data: lineup.toMap());

            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
