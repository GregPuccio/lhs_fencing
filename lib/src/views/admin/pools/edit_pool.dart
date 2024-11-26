import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/services/firestore/functions/bout_functions.dart';
import 'package:lhs_fencing/src/services/providers/providers.dart';
import 'package:lhs_fencing/src/views/auth/account_setup_page.dart';
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

  void _updateBout(Bout bout, int fencerScore, int opponentScore,
      {bool fencerWins = false}) {
    // When scores are equal, an explicit winner must be selected
    bool isSameScore = fencerScore == opponentScore;

    final updatedBout = bout.copyWith(
      fencerScore: fencerScore,
      opponentScore: opponentScore,
      fencerWin: isSameScore ? fencerWins : (fencerScore > opponentScore),
      opponentWin: isSameScore ? !fencerWins : (opponentScore > fencerScore),
    );

    setState(() {
      int index = bouts.indexWhere((b) => b.id == bout.id);
      if (index != -1) {
        bouts[index] = updatedBout;
      }
      _editingBouts.remove(bout.id);
    });
  }

  Color _getScoreColor(int score, int opponentScore, bool isFencer) {
    if (score > opponentScore) {
      return Colors.green;
    } else if (score < opponentScore) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<Pool> pools) {
      Pool pool = pools.firstWhere((p) => p.id == widget.poolID);

      return Scaffold(
        appBar: AppBar(
          title:
              Text("Edit Pool", style: Theme.of(context).textTheme.titleLarge),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Pool"),
                          content: const Text(
                            "Are you sure you want to delete this pool and all its bouts? This action cannot be undone.",
                            style: TextStyle(color: Colors.red),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Pool Bouts",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pool.boutIDs.length,
                itemBuilder: (context, index) {
                  Bout bout =
                      bouts.firstWhere((b) => b.id == pool.boutIDs[index]);
                  bool isEditing = _editingBouts.contains(bout.id);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: isEditing
                        ? _buildEditableBoutTile(bout, index)
                        : _buildStaticBoutTile(bout, index),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountSetupPage(user: null),
            ),
          ),
          child: const Icon(Icons.add),
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

  Widget _buildStaticBoutTile(Bout bout, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          "${index + 1}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              bout.fencer.fullShortenedName,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${bout.fencerScore}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getScoreColor(
                        bout.fencerScore, bout.opponentScore, true),
                  ),
            ),
          ),
          Text(
            ":",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${bout.opponentScore}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getScoreColor(
                        bout.opponentScore, bout.fencerScore, false),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              bout.opponent.fullShortenedName,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          setState(() {
            _editingBouts.add(bout.id);
          });
        },
      ),
    );
  }

  Widget _buildEditableBoutTile(Bout bout, int index) {
    final fencerController =
        TextEditingController(text: bout.fencerScore.toString());
    final opponentController =
        TextEditingController(text: bout.opponentScore.toString());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  bout.fencer.fullShortenedName,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: fencerController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(":"),
              ),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: opponentController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  bout.opponent.fullShortenedName,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // When scores are equal, show winner selection
          if (int.tryParse(fencerController.text) ==
              int.tryParse(opponentController.text))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select Winner:",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      int fencerScore =
                          int.tryParse(fencerController.text) ?? 0;
                      int opponentScore =
                          int.tryParse(opponentController.text) ?? 0;
                      _updateBout(bout, fencerScore, opponentScore,
                          fencerWins: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(bout.fencer.fullShortenedName),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      int fencerScore =
                          int.tryParse(fencerController.text) ?? 0;
                      int opponentScore =
                          int.tryParse(opponentController.text) ?? 0;
                      _updateBout(bout, fencerScore, opponentScore,
                          fencerWins: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(bout.opponent.fullShortenedName),
                  ),
                ],
              ),
            ),
          // Existing buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () {
                  int fencerScore = int.tryParse(fencerController.text) ?? 0;
                  int opponentScore =
                      int.tryParse(opponentController.text) ?? 0;

                  // If scores are different, update normally
                  if (fencerScore != opponentScore) {
                    _updateBout(bout, fencerScore, opponentScore);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _editingBouts.remove(bout.id);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
