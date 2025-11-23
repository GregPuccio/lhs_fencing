import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lhs_fencing/src/constants/date_utils.dart';
import 'package:lhs_fencing/src/models/attendance_month.dart';
import 'package:lhs_fencing/src/models/bout_month.dart';
import 'package:lhs_fencing/src/models/drill_season.dart';
import 'package:lhs_fencing/src/models/lineup.dart';
import 'package:lhs_fencing/src/models/pool.dart';
import 'package:lhs_fencing/src/models/practice.dart';
import 'package:lhs_fencing/src/models/practice_month.dart';
import 'package:lhs_fencing/src/models/user_data.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_path.dart';
import 'package:lhs_fencing/src/services/firestore/firestore_service.dart';
import 'package:lhs_fencing/src/settings/theme_controller.dart';
import 'package:lhs_fencing/src/settings/theme_service.dart';
import 'package:lhs_fencing/src/settings/theme_service_hive.dart';

final themeServiceProvider =
    Provider<ThemeService>((ref) => ThemeServiceHive('lhsfencing23'));

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
  if (auth.value?.uid != null) {
    return FirestoreService.instance;
  }
  ref.watch(firebaseAuthProvider).currentUser?.reload();
  throw UnimplementedError();
});

final lastSeasonUserDataProvider = StreamProvider<UserData?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.documentStream(
    path: FirestorePath.lastSeasonUser(auth.value!.uid),
    builder: (map, docID) {
      if (map != null) {
        return UserData.fromMap(map).copyWith(id: docID);
      } else {
        return null;
      }
    },
  );
});

final userDataProvider = StreamProvider<UserData?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.documentStream(
    path: FirestorePath.user(auth.value!.uid),
    builder: (map, docID) {
      if (map != null) {
        return UserData.fromMap(map).copyWith(id: docID);
      } else {
        return null;
      }
    },
  );
});

final thisSeasonFencersProvider = StreamProvider<List<UserData>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.users(),
    queryBuilder: (query) => query.where("admin", isEqualTo: false),
    sort: (lhs, rhs) => lhs.compareTo(rhs),
    builder: (map, docID) {
      return UserData.fromMap(map!).copyWith(id: docID);
    },
  );
});

final lastSeasonFencersProvider = StreamProvider<List<UserData>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.lastSeasonUsers(),
    queryBuilder: (query) => query.where("admin", isEqualTo: false),
    sort: (lhs, rhs) => lhs.compareTo(rhs),
    builder: (map, docID) {
      return UserData.fromMap(map!).copyWith(id: docID);
    },
  );
});

final activeFencersProvider = Provider<List<UserData>>((ref) {
  final fencers = ref.watch(thisSeasonFencersProvider).asData!.value;
  return fencers.where((f) => f.active).toList();
});

final thisSeasonPracticesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.thisSeasonPractices(),
    builder: (map, docID) => PracticeMonth.fromMap(map!).copyWith(id: docID),
  );
});

final lastSeasonPracticesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.lastSeasonPractices(),
    builder: (map, docID) => PracticeMonth.fromMap(map!).copyWith(id: docID),
  );
});

final currentPracticesProvider = Provider((ref) {
  final practices =
      ref.watch(thisSeasonPracticesProvider).whenData((practiceMonths) {
    List<Practice> practices = [];
    for (var month in practiceMonths) {
      practices.addAll(
        month.practices
            .where((e) =>
                e.startTime.isToday &&
                e.endTime
                    .isAfter(DateTime.now().subtract(const Duration(hours: 2))))
            .toList(),
      );
    }
    return practices;
  });
  return practices;
});

final fencerAttendancesProvider = StreamProvider((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.attendances(auth.value!.uid),
    builder: (map, docID) => AttendanceMonth.fromMap(map!).copyWith(id: docID),
  );
});

final thisSeasonAttendancesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: FirestorePath.thisSeasonAttendances(),
    builder: (map, docID) => AttendanceMonth.fromMap(map!).copyWith(id: docID),
  );
});

final lastSeasonAttendancesProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: FirestorePath.lastSeasonAttendances(),
    builder: (map, docID) => AttendanceMonth.fromMap(map!).copyWith(id: docID),
  );
});

final drillsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.drills(),
    builder: (map, docID) => DrillSeason.fromMap(map!).copyWith(id: docID),
  );
});

final thisSeasonBoutsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: FirestorePath.thisSeasonBouts(),
    builder: (map, docID) => BoutMonth.fromMap(map!).copyWith(id: docID),
  );
});

final lastSeasonBoutsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: FirestorePath.lastSeasonBouts(),
    builder: (map, docID) => BoutMonth.fromMap(map!).copyWith(id: docID),
  );
});

final thisSeasonUserBoutsProvider = StreamProvider((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
      groupTerm: FirestorePath.thisSeasonBouts(),
      builder: (map, docID) => BoutMonth.fromMap(map!).copyWith(id: docID),
      queryBuilder: (query) =>
          query.where("fencerID", isEqualTo: auth.value!.uid));
});

final poolsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionStream(
    path: FirestorePath.pools(),
    builder: (map, docID) => Pool.fromMap(map!).copyWith(id: docID),
  );
});

final lineupsProvider = StreamProvider((ref) {
  final database = ref.watch(databaseProvider);
  return database.collectionGroupStream(
    groupTerm: FirestorePath.lineups(),
    builder: (map, docID) => Lineup.fromMap(map!).copyWith(id: docID),
    sort: (lhs, rhs) => lhs.createdAt.compareTo(rhs.createdAt),
  );
});
