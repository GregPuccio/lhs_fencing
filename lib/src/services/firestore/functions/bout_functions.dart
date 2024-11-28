import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/bout.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

final FirestoreService firestore = FirestoreService.instance;

Future addBoutPair(List<BoutMonth> months, List<Bout> bouts) async {
  String month = bouts.first.date.monthOnly.millisecondsSinceEpoch.toString();

  // taking care of the [fencer] bout first
  Bout fencerBout = bouts.first;
  String fencerID = fencerBout.fencer.id;

  int fencerMonthIndex = months.indexWhere(
    (m) => m.fencerID == fencerID && m.id == month,
  );

  // if this month is missing for the fencer we need to add it
  if (fencerMonthIndex == -1) {
    months.add(BoutMonth(id: month, fencerID: fencerID, bouts: [fencerBout]));
    // need to get the new index after the BoutMonth was added
    fencerMonthIndex = months.indexWhere(
      (m) => m.fencerID == fencerID && m.id == month,
    );
    await FirestoreService.instance.setData(
      path: FirestorePath.currentSeasonBoutMonth(
          fencerID, months[fencerMonthIndex].id),
      data: months[fencerMonthIndex].toMap(),
    );
  }
  // if its not missing we can just update the month
  else {
    // just need to add the bout to the BoutMonth we found
    months[fencerMonthIndex].bouts.add(fencerBout);
    await FirestoreService.instance.updateData(
      path: FirestorePath.currentSeasonBoutMonth(
          fencerID, months[fencerMonthIndex].id),
      data: months[fencerMonthIndex].toMap(),
    );
  }

  // now we can take care of the [opponent] bout
  Bout opponentBout = bouts.last;
  String opponentID = opponentBout.fencer.id;

  int opponentMonthIndex = months.indexWhere(
    (m) => m.fencerID == opponentID && m.id == month,
  );

  // THIS FOLLOWS THE SAME LOGIC AS ABOVE JUST FOR THE [opponent] INSTEAD
  // if this month is missing for the fencer we need to add it
  if (opponentMonthIndex == -1) {
    months
        .add(BoutMonth(id: month, fencerID: opponentID, bouts: [opponentBout]));
    // need to get the new index after the BoutMonth was added
    opponentMonthIndex = months.indexWhere(
      (m) => m.fencerID == opponentID && m.id == month,
    );
    await FirestoreService.instance.setData(
      path: FirestorePath.currentSeasonBoutMonth(
          opponentID, months[opponentMonthIndex].id),
      data: months[opponentMonthIndex].toMap(),
    );
  }
  // if its not missing we can just update the month
  else {
    // just need to add the bout to the BoutMonth we found
    months[opponentMonthIndex].bouts.add(opponentBout);
    await FirestoreService.instance.updateData(
      path: FirestorePath.currentSeasonBoutMonth(
          opponentID, months[opponentMonthIndex].id),
      data: months[opponentMonthIndex].toMap(),
    );
  }
}

Future<void> updateBoutPair(List<BoutMonth> months, List<Bout> bouts) async {
  String month = bouts.first.date.monthOnly.millisecondsSinceEpoch.toString();

  // taking care of the [fencer] bout first
  Bout fencerBout = bouts.first;
  String fencerID = fencerBout.fencer.id;

  int fencerMonthIndex = months.indexWhere(
    (m) => m.fencerID == fencerID && m.id == month,
  );

  // if this month is missing for the fencer, we need to add it
  if (fencerMonthIndex == -1) {
    months.add(BoutMonth(id: month, fencerID: fencerID, bouts: [fencerBout]));
    fencerMonthIndex = months.indexWhere(
      (m) => m.fencerID == fencerID && m.id == month,
    );
    await FirestoreService.instance.setData(
      path: FirestorePath.currentSeasonBoutMonth(
          fencerID, months[fencerMonthIndex].id),
      data: months[fencerMonthIndex].toMap(),
    );
  }
  // if the month exists, we update or replace the existing bout
  else {
    int existingBoutIndex = months[fencerMonthIndex].bouts.indexWhere(
          (b) => b.id == fencerBout.id,
        );

    // If the bout doesn't exist, add it
    if (existingBoutIndex == -1) {
      months[fencerMonthIndex].bouts.add(fencerBout);
    }
    // If the bout exists, replace it
    else {
      months[fencerMonthIndex].bouts[existingBoutIndex] = fencerBout;
    }

    await FirestoreService.instance.updateData(
      path: FirestorePath.currentSeasonBoutMonth(
          fencerID, months[fencerMonthIndex].id),
      data: months[fencerMonthIndex].toMap(),
    );
  }

  // now we can take care of the [opponent] bout
  Bout opponentBout = bouts.last;
  String opponentID = opponentBout.fencer.id;

  int opponentMonthIndex = months.indexWhere(
    (m) => m.fencerID == opponentID && m.id == month,
  );

  // if this month is missing for the opponent, we need to add it
  if (opponentMonthIndex == -1) {
    months
        .add(BoutMonth(id: month, fencerID: opponentID, bouts: [opponentBout]));
    opponentMonthIndex = months.indexWhere(
      (m) => m.fencerID == opponentID && m.id == month,
    );
    await FirestoreService.instance.setData(
      path: FirestorePath.currentSeasonBoutMonth(
          opponentID, months[opponentMonthIndex].id),
      data: months[opponentMonthIndex].toMap(),
    );
  }
  // if the month exists, we update or replace the existing bout
  else {
    int existingBoutIndex = months[opponentMonthIndex].bouts.indexWhere(
          (b) => b.id == opponentBout.id,
        );

    // If the bout doesn't exist, add it
    if (existingBoutIndex == -1) {
      months[opponentMonthIndex].bouts.add(opponentBout);
    }
    // If the bout exists, replace it
    else {
      months[opponentMonthIndex].bouts[existingBoutIndex] = opponentBout;
    }

    await FirestoreService.instance.updateData(
      path: FirestorePath.currentSeasonBoutMonth(
          opponentID, months[opponentMonthIndex].id),
      data: months[opponentMonthIndex].toMap(),
    );
  }
}

Future deleteBoutPair(List<BoutMonth> boutMonths, Bout bout) async {
  int index = boutMonths.indexWhere((m) =>
      m.fencerID == bout.fencer.id &&
      m.id == bout.date.monthOnly.millisecondsSinceEpoch.toString());
  if (index != -1) {
    boutMonths[index].bouts.removeWhere((b) => b.id == bout.id);
    if (boutMonths[index].bouts.isEmpty) {
      await FirestoreService.instance.deleteData(
        path: FirestorePath.currentSeasonBoutMonth(
            boutMonths[index].fencerID, boutMonths[index].id),
      );
    } else {
      await FirestoreService.instance.updateData(
        path: FirestorePath.currentSeasonBoutMonth(
            boutMonths[index].fencerID, boutMonths[index].id),
        data: boutMonths[index].toMap(),
      );
    }
  }
  index = boutMonths.indexWhere((m) =>
      m.fencerID == bout.opponent.id &&
      m.id == bout.date.monthOnly.millisecondsSinceEpoch.toString());
  if (index != -1) {
    boutMonths[index].bouts.removeWhere((b) => b.id == bout.partnerID);
    if (boutMonths[index].bouts.isEmpty) {
      await FirestoreService.instance.deleteData(
        path: FirestorePath.currentSeasonBoutMonth(
            boutMonths[index].fencerID, boutMonths[index].id),
      );
    } else {
      await FirestoreService.instance.updateData(
        path: FirestorePath.currentSeasonBoutMonth(
            boutMonths[index].fencerID, boutMonths[index].id),
        data: boutMonths[index].toMap(),
      );
    }
  }
}

Future deleteBoutMonths(List<BoutMonth> boutMonths) async {
  for (var boutMonth in boutMonths) {
    await FirestoreService.instance.deleteData(
      path: FirestorePath.currentSeasonBoutMonth(
          boutMonth.fencerID, boutMonth.id),
    );
  }
}

Future addPool(Pool pool) async {
  return await FirestoreService.instance.addData(
    path: FirestorePath.pools(),
    data: pool.toMap(),
  );
}

Future<void> deletePool({
  required Pool pool,
  required List<BoutMonth> boutMonths,
}) async {
  try {
    // Step 1: Collect all bout IDs to delete
    List<String> boutIDsToDelete = [...pool.boutIDs, ...pool.opponentBoutIDs];

    // Step 2: Delete associated bouts from BoutMonths
    await _deleteBoutsFromBoutMonths(
      boutIDs: boutIDsToDelete,
      boutMonths: boutMonths,
    );

    // Step 3: Delete the pool
    String poolPath = 'pools24/${pool.id}';
    await FirestoreService.instance.deleteData(path: poolPath);
  } catch (error) {
    // catches error
  }
}

/// Finds the BoutMonth containing the given bout ID.
BoutMonth? _findBoutMonth(List<BoutMonth>? boutMonths, String boutID) {
  if (boutMonths == null) return null;
  for (var month in boutMonths) {
    if (month.bouts.any((bout) => bout.id == boutID)) {
      return month;
    }
  }
  return null;
}

Future<void> _deleteBoutsFromBoutMonths({
  required List<String> boutIDs,
  required List<BoutMonth> boutMonths,
}) async {
  for (String boutID in boutIDs) {
    BoutMonth? month = _findBoutMonth(boutMonths, boutID);
    if (month != null) {
      month.bouts.removeWhere((bout) => bout.id == boutID);
      await _updateBoutMonth(month);
    }
  }
}

Future<void> _updateBoutMonth(BoutMonth boutMonth) async {
  String path = 'users24/${boutMonth.fencerID}/bouts24/${boutMonth.id}';
  await FirestoreService.instance.updateData(
    path: path,
    data: boutMonth.toMap(),
  );
}
