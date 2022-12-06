import 'package:lhs_fencing/src/models/attendance.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

class FirestoreStreams {
  final FirestoreService firestore = FirestoreService.instance;

  Stream<List<Attendance>> practiceAttendances(String practiceID) {
    return firestore.collectionGroupStream(
      groupTerm: attendanceCollection,
      queryBuilder: (query) =>
          query.where("id", isEqualTo: practiceID).orderBy("userData.lastName"),
      builder: (map, docID) {
        return Attendance.fromMap(map!).copyWith(id: docID);
      },
    );
  }
}
