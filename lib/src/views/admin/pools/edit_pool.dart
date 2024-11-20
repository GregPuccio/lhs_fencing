import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/enums.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/pool.dart';
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
          ));
    }

    Widget whenBoutData(List<BoutMonth> boutMonths) {
      bouts = [];
      for (var month in boutMonths) {
        bouts.addAll(month.bouts);
      }
      return ref.watch(poolsProvider).when(
            data: whenData,
            error: (error, stackTrace) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
    }

    return ref.watch(thisSeasonBoutsProvider).when(
          data: whenBoutData,
          error: (error, stackTrace) => const ErrorPage(),
          loading: () => const LoadingPage(),
        );
  }
}
