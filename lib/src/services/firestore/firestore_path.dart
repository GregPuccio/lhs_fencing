String userCollection = "users";
String notificationCollection = "notifications";
String memberCollection = "members";
String tournamentCollection = "tournaments";
String stripCollection = "strips";
String fencerCollection = "fencers";
String eventCollection = "events";
String roundCollection = "rounds";
String refereeCollection = "referees";
String poolCollection = "pools";
String elimCollection = "elimination";

class FirestorePath {
  final FirestorePath firestorePath = FirestorePath();

  /// users
  static String user(String userID) => '$userCollection/$userID';
  static String users() => userCollection;

  /// notifications for user
  static String notifications(String userID) =>
      '$userCollection/$userID/$notificationCollection';

  /// members from usa fencing
  static String member(String memberID) => '$memberCollection/$memberID';
  static String members() => memberCollection;

  /// tournaments
  static String tournament(String tournamentID) =>
      '$tournamentCollection/$tournamentID';
  static String tournaments() => tournamentCollection;

  /// strips
  static String strip(String tournamentID, String stripID) =>
      '$tournamentCollection/$tournamentID/$stripCollection/$stripID';
  static String strips(String tournamentID) =>
      '$tournamentCollection/$tournamentID/$stripCollection';

  /// events
  static String event(String eventID) => '$eventCollection/$eventID';
  static String events() => eventCollection;

  /// referees
  static String referee(String tournamentID, String refereeID) =>
      '$tournamentCollection/$tournamentID/$refereeCollection/$refereeID';
  static String referees(String tournamentID) =>
      '$tournamentCollection/$tournamentID/$refereeCollection';

  /// fencers
  static String fencer(String eventID, String fencerID) =>
      '$eventCollection/$eventID/$fencerCollection/$fencerID';
  static String fencers(String eventID) =>
      '$eventCollection/$eventID/$fencerCollection';

  /// event rounds
  static String round(String eventID, String roundID) =>
      "$eventCollection/$eventID/$roundCollection/$roundID";
  static String rounds(String eventID) =>
      "$eventCollection/$eventID/$roundCollection";
}
