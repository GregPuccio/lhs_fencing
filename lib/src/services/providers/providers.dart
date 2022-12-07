import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';
import 'package:lhs_fencing/src/settings/theme_service.dart';
import 'package:lhs_fencing/src/settings/theme_service_hive.dart';

final themeServiceProvider =
    Provider<ThemeService>((ref) => ThemeServiceHive('tournado_theming'));

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return ThemeController(themeService);
});

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final currentUser = Provider((ref) {
  return ref.watch(firebaseAuthProvider).currentUser;
});

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreService>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  if (auth.asData?.value?.uid != null) {
    return FirestoreService.instance;
  }
  ref.watch(firebaseAuthProvider).currentUser?.reload();
  throw UnimplementedError();
});

final userDataProvider = StreamProvider<UserData?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.documentStream(
    path: FirestorePath.user(auth.asData!.value!.uid),
    builder: (map, docID) {
      if (map != null) {
        return UserData.fromMap(map).copyWith(id: docID);
      } else {
        return null;
      }
    },
  );
});

final fencersProvider = StreamProvider<List<UserData>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.users(),
    queryBuilder: (query) =>
        query.where("admin", isEqualTo: false).orderBy("lastName"),
    builder: (map, docID) {
      return UserData.fromMap(map!).copyWith(id: docID);
    },
  );
});

final practicesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.practices(),
    builder: (map, docID) => PracticeMonth.fromMap(map!).copyWith(id: docID),
  );
});

final attendancesProvider = StreamProvider((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.attendances(auth.asData!.value!.uid),
    builder: (map, docID) => AttendanceMonth.fromMap(map!).copyWith(id: docID),
  );
});

final allAttendancesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: attendanceCollection,
    builder: (map, docID) => AttendanceMonth.fromMap(map!).copyWith(id: docID),
  );
});
