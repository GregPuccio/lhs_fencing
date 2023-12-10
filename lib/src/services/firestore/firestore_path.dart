String userCollection = "users23";
String practiceCollection = "practices23";
String attendanceCollection = "attendances23";
String drillCollection = "drills";
String drillSeason23 = "drills23";
String boutCollection = "bouts23";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
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

  static String bouts(String fencerID) =>
      '$userCollection/$fencerID/$boutCollection';
  static String bout(String fencerID, String month) =>
      '${bouts(fencerID)}/$month';
}
