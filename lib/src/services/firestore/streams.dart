import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

class FirestoreStreams {
  final FirestoreService firestore = FirestoreService.instance;

  Stream<List<Attendance>> previousAttendances(String userID) {
    return firestore.collectionStream(
      path: FirestorePath.attendances(userID),
      queryBuilder: (query) => query.limit(20),
      builder: (map, docID) {
        return Attendance.fromMap(map!).copyWith(id: docID);
      },
    );
  }
}
