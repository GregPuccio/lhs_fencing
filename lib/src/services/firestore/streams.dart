import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';

class FirestoreStreams {
  final FirestoreService firestore = FirestoreService.instance;

  // Stream<List<UserData>> fencerList() {
  //   return firestore.collectionStream(
  //     path: FirestorePath.users(),
  //     queryBuilder: (query) =>
  //         query.where("admin", isEqualTo: false).orderBy("lastName"),
  //     builder: (map, docID) {
  //       return UserData.fromMap(map!).copyWith(id: docID);
  //     },
  //   );
  // }

  // Stream<List<AttendanceMonth>> previousAttendances(String userID) {
  //   return firestore.collectionStream(
  //     path: FirestorePath.attendances(userID),
  //     builder: (map, docID) {
  //       return AttendanceMonth.fromMap(map!).copyWith(id: docID);
  //     },
  //   );
  // }
}
