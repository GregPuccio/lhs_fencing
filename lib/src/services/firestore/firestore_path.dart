String lastSeasonUserCollection = "users23";
String userCollection = "users24";
String practiceCollection = "practices24";
String attendanceCollection = "attendances24";
String drillCollection = "drills";
String drillSeason23 = "drills23";
String drillSeason24 = "drills24";
String boutsSeason23 = "bouts23";
String boutsSeason24 = "bouts24";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
  static String lastSeasonUser(String userID) =>
      '$lastSeasonUserCollection/$userID';
  static String user(String userID) => '$userCollection/$userID';
  static String users() => userCollection;

  /// notifications for practices
  static String practices() => practiceCollection;

  static String practice(String practiceID) =>
      '$practiceCollection/$practiceID';

  static String attendances(String userID) =>
      '$userCollection/$userID/$attendanceCollection';
  static String attendance(String userID, String practiceID) =>
      '$userCollection/$userID/$attendanceCollection/$practiceID';

  static String drills() => drillCollection;
  static String drill(String drillSeasonID) =>
      '$drillCollection/$drillSeasonID';

  static String currentSeasonBoutMonths(String fencerID) =>
      '$userCollection/$fencerID/$boutsSeason24';
  static String currentSeasonBoutMonth(String fencerID, String month) =>
      '${currentSeasonBoutMonths(fencerID)}/$month';
}
