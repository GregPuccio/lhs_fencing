import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final firestore = FirebaseFirestore.instance;

  /// sets the [data] into a given document at the specified [path]
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = firestore.doc(path);
    debugPrint('$path: $data');
    await reference.set(data, SetOptions(merge: merge));
  }

  /// adds the [data] into a given collection at the specified [path]
  Future<DocumentReference> addData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = firestore.collection(path);
    debugPrint('$path: $data');
    return reference.add(data);
  }

  /// updates the [data] given at the specified [path]
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = firestore.doc(path);
    debugPrint('$path: $data');
    await reference.update(data);
  }

  /// deletes the data at the given [path]
  Future<void> deleteData({required String path}) async {
    final reference = firestore.doc(path);
    debugPrint('delete: $path');
    await reference.delete();
  }

  /// a future that when complete gives the first document in a collection
  /// that fits the [queryBuilder] constraints
  Future<T> documentFutureFromCollection<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    required Query<Map<String, dynamic>> Function(
            Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Future<QuerySnapshot<Map<String, dynamic>>> snapshots = query.get();
    return snapshots.then((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return Future.value();
      }
    });
  }

  /// a stream that gives updates of all of the documents at a given [path]
  /// based on the [queryBuilder] queries
  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  /// a future that gives the documents in a given collection
  /// MAKE SURE TO USE THE BUILDER TO LIMIT THE NUMBER OF DOCUMENTS
  Future<List<T>> collectionFuture<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Future<QuerySnapshot<Map<String, dynamic>>> snapshots = query.get();
    return snapshots.then((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      return result;
    });
  }

  /// a stream that gives updates of all of the documents in a given [groupTerm]
  /// based on the [queryBuilder] queries
  Stream<List<T>> collectionGroupStream<T>({
    required String groupTerm,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collectionGroup(groupTerm);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  /// a stream that gives updates of all of the data at a given [path]
  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference =
        firestore.doc(path);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data(), snapshot.id));
  }

  /// a future that when complete gives all of the data at a given [path]
  Future<T> documentFuture<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference =
        firestore.doc(path);
    final Future<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        reference.get();
    return snapshots.then((snapshot) => builder(snapshot.data(), snapshot.id));
  }

  // /// a stream of a map that is created from a collection of tournaments and
  // /// the dates that they occur on
  // Stream<Map<DateTime, List<Tournament>>> collectionCalendarStream<T>({
  //   required String path,
  //   required Tournament Function(Map<String, dynamic>? data, String documentID)
  //       builder,
  //   required Query<Map<String, dynamic>> Function(
  //           Query<Map<String, dynamic>> query)?
  //       queryBuilder,
  //   required DateTime startDate,
  //   required DateTime endDate,
  //   int Function(Tournament lhs, Tournament rhs)? sort,
  // }) {
  //   Query<Map<String, dynamic>> query =
  //       firestore.collection(path);
  //   if (queryBuilder != null) {
  //     query = queryBuilder(query);
  //   }
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
  //       query.snapshots();
  //   return snapshots.map((snapshot) {
  //     final result = snapshot.docs
  //         .map((snapshot) => builder(snapshot.data(), snapshot.id))
  //         .toList();
  //     if (sort != null) {
  //       result.sort(sort);
  //     }
  //     final Map<DateTime, List<Tournament>> map = {};
  //     DateTime day = startDate;
  //     while (endDate.isAfter(day)) {
  //       final List<Tournament> tournamentsOnDay = [];
  //       for (final tournament in result) {
  //         if ((day.isAtSameMomentAs(tournament.startDay) ||
  //                 day.isAfter(tournament.startDay)) &&
  //             (day.isAtSameMomentAs(tournament.endDay) ||
  //                 day.isBefore(tournament.endDay))) {
  //           tournamentsOnDay.add(tournament);
  //         }
  //       }
  //       if (tournamentsOnDay.isNotEmpty) {
  //         map.addEntries([
  //           MapEntry(day, tournamentsOnDay),
  //         ]);
  //       }

  //       day = day.add(const Duration(days: 1));
  //     }
  //     return map;
  //   });
  // }

  // /// used to set [data] to a specified [batch] at a given [path]
  // void setBatchData({
  //   required WriteBatch batch,
  //   required String path,
  //   required Map<String, dynamic> data,
  // }) {
  //   final DocumentReference reference = firestore.doc(path);
  //   debugPrint('set batch: $path: $data');
  //   return batch.set(reference, data);
  // }

  // /// used to updated [data] to a specified [batch] at a given [path]
  // void updateBatchData({
  //   required WriteBatch batch,
  //   required String path,
  //   required Map<String, dynamic> data,
  // }) {
  //   final DocumentReference reference = firestore.doc(path);
  //   debugPrint('update batch: $path: $data');
  //   return batch.update(reference, data);
  // }

  // /// commits all of the CRUD applied to the specified [batch]
  // void commitBatch({required WriteBatch batch}) {
  //   debugPrint('commit batch');
  //   batch.commit();
  // }

  // /// stream for specific use case of getting a single top node for
  // /// the elimination tableau
  // Stream<ENode> collectionStreamToENodeDocumentStream({
  //   required String path,
  //   required ENode? Function(
  //     Map<String, dynamic> data,
  //     String docID,
  //     Elimination elimination,
  //     List<Fencer> fencers,
  //     List<Referee> referees,
  //   )
  //       builder,
  //   required Elimination elimination,
  //   required List<Fencer> fencers,
  //   required List<Referee> referees,
  // }) {
  //   final CollectionReference<Map<String, dynamic>> reference =
  //       firestore.collection(path);
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> snapshot =
  //       reference.snapshots();
  //   return snapshot.map((snap) {
  //     final List<ENode> eNodes = snap.docs
  //         .map((e) => ENode.fromMap(
  //               e.data(),
  //               e.id,
  //               elimination,
  //               fencers,
  //               referees,
  //             ))
  //         .toList();
  //     return elimination.databaseToENode(eNodes);
  //   });
  // }

  // /// stream for specific use case of getting a single pool built
  // /// from all of the pool bouts and the encased pool info
  // Stream<Pool> collectionStreamToPoolDocumentStream({
  //   required String path,
  //   required Pool initialPool,
  //   required List<Fencer> fencers,
  //   required List<Referee> referees,
  //   required List<Strip> strips,
  //   required bool onePool,
  // }) {
  //   final CollectionReference<Map<String, dynamic>> reference =
  //       firestore.collection(path);
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> snapshot =
  //       reference.snapshots();
  //   return snapshot.map((snapshot) => Pool.fromMapOfBouts(
  //       snapshot, initialPool, fencers, referees, strips,
  //       onePool: onePool));
  // }
}
