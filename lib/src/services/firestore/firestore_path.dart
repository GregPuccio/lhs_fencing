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
String boutsSeason24 = "bouts24";
String boutsSeason25 = "bouts25";
String poolsSeason24 = "pools24";
String poolsSeason25 = "pools25";
String lineupSeason24 = "lineup24";
String lineupSeason25 = "lineup25";

class FirestorePath {
  /// users
  static String lastSeasonUsers() => userSeason24;
  static String lastSeasonUser(String userID) => '${lastSeasonUsers()}/$userID';
  static String users() => userSeason25;
  static String user(String userID) => '${users()}/$userID';

  /// practices
  static String thisSeasonPractices() => practiceSeason25;
  static String thisSeasonPractice(String practiceID) =>
      '${thisSeasonPractices()}/$practiceID';
  static String lastSeasonPractices() => practiceSeason24;
  static String lastSeasonPractice(String practiceID) =>
      '${lastSeasonPractices()}/$practiceID';

  /// attendances
  static String thisSeasonAttendances() => attendanceSeason25;
  static String lastSeasonAttendances() => attendanceSeason24;
  static String attendances(String userID) =>
      '${users()}/$userID/$attendanceSeason25';
  static String attendance(String userID, String practiceID) =>
      '${users()}/$userID/${thisSeasonAttendances()}/$practiceID';

  /// drills
  static String drills() => drillCollection;
  static String thisSeasonDrills() => drillSeason25;
  static String drill(String drillSeasonID) => '${drills()}/$drillSeasonID';

  /// bouts
  static String thisSeasonBouts() => boutsSeason25;
  static String lastSeasonBouts() => boutsSeason24;
  static String currentSeasonBoutMonths(String fencerID) =>
      '${users()}/$fencerID/${thisSeasonBouts()}';
  static String currentSeasonBoutMonth(String fencerID, String month) =>
      '${currentSeasonBoutMonths(fencerID)}/$month';

  /// lineups
  static String lineups() => lineupSeason25;
  static String lineup(String lineupID) => '${lineups()}/$lineupID';

  /// pools
  static String pools() => poolsSeason25;
}
