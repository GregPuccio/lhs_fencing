import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/services/firestore/functions/bout_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/admin/pools/widgets/editable_pool_tile.dart';
import 'package:lhs_fencing/src/widgets/error.dart';
import 'package:lhs_fencing/src/widgets/loading.dart';

@RoutePage()
class EditPoolPage extends ConsumerStatefulWidget {
  final String poolID;
  const EditPoolPage({required this.poolID, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditPoolPageState();
}

class _EditPoolPageState extends ConsumerState<EditPoolPage> {
  late List<Bout> bouts;
  late List<BoutMonth> boutMonths;
  bool _isProcessing = false;
  final Set<String> _editingBouts = {};

  Future<void> _deletePoolAndBouts(Pool pool) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await deletePool(
        pool: pool,
        boutMonths: boutMonths,
      );

      if (mounted) {
        context.maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting pool: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _toggleBoutEditing(String boutId) {
    setState(() {
      if (_editingBouts.contains(boutId)) {
        _editingBouts.remove(boutId);
      } else {
        _editingBouts.add(boutId);
      }
    });
  }

  void _updateBout(Bout bout) {
    setState(() {
      final index = bouts.indexWhere((bout) => bout.id == bout.id);
      if (index != -1) {
        bouts[index] = bout;
      }
    });
    Bout opponentBout = bouts.firstWhere((b) => b.id == bout.partnerID);
    opponentBout = opponentBout.copyWith(
      fencerScore: bout.opponentScore,
      opponentScore: bout.fencerScore,
      fencerWin: bout.opponentWin,
      opponentWin: bout.fencerWin,
    );
    updateBoutPair(boutMonths, [bout, opponentBout]);
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<Pool> pools) {
      int poolIndex = pools.indexWhere((p) => p.id == widget.poolID);
      if (poolIndex == -1) {
        return LoadingPage();
      }
      Pool pool = pools[poolIndex];

      return Scaffold(
        appBar: AppBar(
          title: Text(
              "${pool.team.capitalizedName} ${pool.weapon.type} | ${pool.fencers.length} Fencers"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Pool"),
                          content: const Text(
                            "Are you sure you want to delete this pool and all its bouts? This action cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        await _deletePoolAndBouts(pool);
                      }
                    },
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: pool.boutIDs.length,
          itemBuilder: (context, index) {
            int boutIndex =
                bouts.indexWhere((b) => b.id == pool.boutIDs[index]);
            if (boutIndex == -1) {
              return ListTile(
                title: Text("Bout has been deleted"),
              );
            }
            Bout bout = bouts[boutIndex];
            return BoutTile(
              key: ValueKey(bout),
              bout: bout,
              index: index,
              isEditing: _editingBouts.contains(bout.id),
              onBoutUpdated: _updateBout,
              onEditToggle: _toggleBoutEditing,
            );
          },
        ),
      );
    }

    Widget whenBoutData(List<BoutMonth> data) {
      bouts = [];
      boutMonths = data;
      for (var month in data) {
        bouts.addAll(month.bouts);
      }
      return ref.watch(poolsProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    return Stack(
      children: [
        ref.watch(thisSeasonBoutsProvider).when(
              data: whenBoutData,
              error: (error, stackTrace) => const ErrorPage(),
              loading: () => const LoadingPage(),
            ),
        if (_isProcessing)
          const ModalBarrier(
            color: Colors.black38,
            dismissible: false,
          ),
        if (_isProcessing)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
