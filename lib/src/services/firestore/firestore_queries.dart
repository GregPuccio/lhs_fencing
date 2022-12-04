import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueries {
  FirestoreQueries firestoreQueries = FirestoreQueries();
  static Query<Map<String, dynamic>> searchQuery(
    Query<Map<String, dynamic>> query,
    String orderBy,
    String value, {
    int limit = 25,
  }) =>
      query
          .orderBy(orderBy)
          .where(orderBy, isGreaterThanOrEqualTo: int.tryParse(value) ?? value)
          .limit(limit);

  static Query<Map<String, dynamic>> searchArrayQuery(
    Query<Map<String, dynamic>> query,
    String orderBy,
    String value, {
    int limit = 25,
  }) =>
      query.orderBy(orderBy).where(orderBy, arrayContains: value).limit(limit);
}
