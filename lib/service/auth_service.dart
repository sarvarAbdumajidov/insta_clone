import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static bool isLoggedIn() {
    User? firebaseUser = _auth.currentUser;
    return firebaseUser != null;
  }

  static String currentUserId() {
    User? firebaseUser = _auth.currentUser;
    return firebaseUser!.uid;
  }

  static Future<User?> signInUser(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? firebaseUser = _auth.currentUser;
    return firebaseUser;
  }

  static Future<User?> signUpUser(String fullName, String email, String password) async {
    var authResult = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = authResult.user;
    return user;
  }

  static Future<void> signOut(BuildContext context) async{
   await _auth.signOut();
   if(context.mounted){
     Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
   }
  }
}
