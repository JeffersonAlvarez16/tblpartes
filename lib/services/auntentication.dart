import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tblpartes/models/user.dart';

class Autentication {
  late final FirebaseAuth _firebaseAuth;

  final _estadoSelec = StreamController<String>.broadcast();
  final _desde = StreamController<String>.broadcast();
  final _hasta = StreamController<String>.broadcast();
  final _userData = StreamController<String>.broadcast();
  final _horario = StreamController<String>.broadcast();

  Stream<String> get estadoSelec => _estadoSelec.stream;
  Stream<String> get desde => _desde.stream;
  Stream<String> get hasta => _hasta.stream;
  Stream<String> get userData => _userData.stream;
  Stream<String> get horario => _horario.stream;

  Function(String) get changeEstado => _estadoSelec.sink.add;
  Function(String) get changeDesde => _desde.sink.add;
  Function(String) get changeHasta => _hasta.sink.add;
  Function(String) get changeUserData => _userData.sink.add;
  Function(String) get changeHorario => _horario.sink.add;

  Autentication(this._firebaseAuth);

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Logeado";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Stream<User?> get autStateChange => _firebaseAuth.authStateChanges();

  dispose() {
    _estadoSelec.close();
    _desde.close();
    _hasta.close();
    _userData.close();
    _horario.close();
  }
}
