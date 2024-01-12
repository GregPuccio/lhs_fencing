import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  dynamic signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'AN ERROR HAS OCCURED';
    }
  }

  Future forgotPassword(String email) {
    try {
      return _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return Future.value(e.toString());
    }
  }

  Future register(String email, String password) async {
    try {
      return await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => value.user?.sendEmailVerification());
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'AN ERROR HAS OCCURED';
    }
  }

  Future signOut() {
    return _auth.signOut();
  }

  /// USED TO UPDATE PASSWORD INSIDE OF SETTINGS
  Future updatePassword(String oldPassword, String? newPassword) async {
    final User user = _auth.currentUser!;
    try {
      return await user
          .reauthenticateWithCredential(EmailAuthProvider.credential(
              email: user.email!, password: oldPassword))
          .then((value) {
        return user.updatePassword(newPassword!);
      });
    } catch (e) {
      return null;
    }
  }

  // Future deleteAccount() async {
  //   var credential = Credentials.applicationDefault();
  //   try {} catch (e) {
  //     return null;
  //   }
  // }
}
