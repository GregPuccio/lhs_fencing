import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
  bool _isProcessing = false; // To track processing state

  Future<void> _deletePoolAndBouts(Pool pool) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Delete all fencer and opponenet bouts in the pool
      await deletePool(
        pool: pool,
        boutMonths: boutMonths,
      );

      // Delete the pool itself
      // Call your pool deletion function here

      if (context.mounted) {
        context.maybePop(); // Close the page after completion
      }
    } catch (e) {
      // Handle error here
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting pool: $e")),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(List<Pool> pools) {
      Pool pool = pools.firstWhere((p) => p.id == widget.poolID);

      return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountSetupPage(user: null),
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text("Pool"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Pool"),
                            content: const Text(
                                "Are you sure you want to delete this pool and all its bouts (including opponent bouts)? This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        await _deletePoolAndBouts(pool);
                      }
                    },
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.only(bottom: 60),
          itemCount: pool.boutIDs.length,
          itemBuilder: (context, index) {
            Bout bout = bouts.firstWhere((b) => b.id == pool.boutIDs[index]);
            return ListTile(
              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              title: Text(
                  "${bout.fencer.fullShortenedName} vs ${bout.opponent.fullShortenedName}"),
              subtitle: Text("${bout.original}"),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
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
