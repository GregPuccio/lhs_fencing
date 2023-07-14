String userCollection = "users23";
String practiceCollection = "practices";
String attendanceCollection = "attendances";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
  static String user(String userID) => '$userCollection/$userID';
  static String users() => userCollection;

  /// notifications for practices
  static String practices() => practiceCollection;

  static practice(String practiceID) => '$practiceCollection/$practiceID';

  static attendances(String userID) =>
      '$userCollection/$userID/$attendanceCollection';
  static attendance(String userID, String practiceID) =>
      '$userCollection/$userID/$attendanceCollection/$practiceID';
}
