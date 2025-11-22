String userSeason23 = "users23";
String userSeason24 = "users24";
String userSeason25 = "users25";
String practiceSeason23 = "practices23";
String practiceSeason24 = "practices24";
String practiceSeason25 = "practices25";
String attendanceSeason23 = "attendances23";
String attendanceSeason24 = "attendances24";
String attendanceSeason25 = "attendances25";
String drillCollection = "drills";
String drillSeason23 = "drills23";
String drillSeason24 = "drills24";
String drillSeason25 = "drills25";
String boutsSeason23 = "bouts23";
String poolsSeason24 = "pools24";
String poolsSeason25 = "pools25";
String boutsSeason24 = "bouts24";
String boutsSeason25 = "bouts25";
String lineupSeason24 = "lineup24";
String lineupSeason25 = "lineup25";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
  static String lastSeasonUser(String userID) => '$userSeason24/$userID';
  static String user(String userID) => '$userSeason25/$userID';
  static String users() => userSeason25;

  static String thisSeasonPractice(String practiceID) =>
      '$practiceSeason25/$practiceID';
  static String lastSeasonPractice(String practiceID) =>
      '$practiceSeason24/$practiceID';

  static String attendances(String userID) =>
      '$userSeason25/$userID/$attendanceSeason25';
  static String attendance(String userID, String practiceID) =>
      '$userSeason25/$userID/$attendanceSeason25/$practiceID';

  static String drills() => drillCollection;
  static String drill(String drillSeasonID) =>
      '$drillCollection/$drillSeasonID';

  static String currentSeasonBoutMonths(String fencerID) =>
      '$userSeason25/$fencerID/$boutsSeason25';
  static String currentSeasonBoutMonth(String fencerID, String month) =>
      '${currentSeasonBoutMonths(fencerID)}/$month';

  static String lineups() => lineupSeason25;
  static String lineup(String lineupID) => '$lineupSeason25/$lineupID';

  static String pools() => poolsSeason25;
}
