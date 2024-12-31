String userSeason23 = "users23";
String userSeason24 = "users24";
String practiceSeason23 = "practices23";
String practiceSeason24 = "practices24";
String attendanceSeason23 = "attendances23";
String attendanceSeason24 = "attendances24";
String drillCollection = "drills";
String drillSeason23 = "drills23";
String drillSeason24 = "drills24";
String poolsSeason24 = "pools24";
String boutsSeason23 = "bouts23";
String boutsSeason24 = "bouts24";
String lineupSeason24 = "lineup24";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
  static String lastSeasonUser(String userID) => '$userSeason23/$userID';
  static String user(String userID) => '$userSeason24/$userID';
  static String users() => userSeason24;

  static String thisSeasonPractice(String practiceID) =>
      '$practiceSeason24/$practiceID';
  static String lastSeasonPractice(String practiceID) =>
      '$practiceSeason23/$practiceID';

  static String attendances(String userID) =>
      '$userSeason24/$userID/$attendanceSeason24';
  static String attendance(String userID, String practiceID) =>
      '$userSeason24/$userID/$attendanceSeason24/$practiceID';

  static String drills() => drillCollection;
  static String drill(String drillSeasonID) =>
      '$drillCollection/$drillSeasonID';

  static String currentSeasonBoutMonths(String fencerID) =>
      '$userSeason24/$fencerID/$boutsSeason24';
  static String currentSeasonBoutMonth(String fencerID, String month) =>
      '${currentSeasonBoutMonths(fencerID)}/$month';

  static String lineups() => lineupSeason24;
  static String lineup(String lineupID) => '$lineupSeason24/$lineupID';

  static String pools() => poolsSeason24;
}
