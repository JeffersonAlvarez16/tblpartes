import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:tblpartes/models/use.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/services/database.dart';

enum AuthStatus { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService databaseService = new DatabaseService();
  late final FirebaseAuth authe;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late User _user;

  AuthStatus _status = AuthStatus.Uninitialized;

  AuthService.instance() : authe = FirebaseAuth.instance {
    authe.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        _status = AuthStatus.Unauthenticated;
        _user = FirebaseAuth.instance.currentUser!;
      } else {
        _user = firebaseUser;
        _status = AuthStatus.Authenticated;
      }

      notifyListeners();
    });
  }

  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  /* Stream<UserModel?> get user {
    return _auth.authStateChanges().(_userFromFirebaseUser);
  } */

  //sing in anonymous

  //sing in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await authe.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user!;
      return user;
    } catch (error) {
      return null;
    }
  }

  Future signOuta() async {
    await _auth.signOut();

    _status = AuthStatus.Unauthenticated;
    notifyListeners();
  }

  // sing out
  Future signOut() async {
    return _auth.signOut();
  }

  AuthStatus get status => _status;
  User get userA => _user;
}
