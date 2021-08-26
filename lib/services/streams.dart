import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/horarios.dart';
import 'package:tblpartes/models/notificaciones.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/models/usuarios.dart';
import 'package:tblpartes/services/database.dart';

class StreamServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DatabaseService databaseService = new DatabaseService();

  Stream<List<Batallon>> get batallones {
    return firestore.collection("batallones").snapshots().map(databaseService.batallonListFromSnapshot);
  }

  Stream<List<Compania>> get companias {
    return firestore.collection("companias").snapshots().map(databaseService.companiaListFromSnapshot);
  }

  Stream<List<UserModel>> get personal {
    return firestore.collection("personal").where("typeUser", isNotEqualTo: "administrador").snapshots().map(databaseService.personalListFromSnapshot);
  }

  Stream<List<Estados>> get estados {
    return firestore.collection("estados").snapshots().map(databaseService.estadosListFromSnapshot);
  }

  Stream<List<Notificaciones>> get notificaciones {
    return firestore.collection("notificaciones_admin").snapshots().map(databaseService.notificacionesListFromSnapshot);
  }

  Stream<List<Usuarios>> get usuarios {
    return firestore.collection("users").where("type_user", isNotEqualTo: "administrador").snapshots().map(databaseService.usuariosListFromSnapshot);
  }

  Stream<List<Horarios>> get horarios {
    return firestore.collection("horarios").snapshots().map(databaseService.horariosListFromSnapshot);
  }

  Stream<List<String>> get horariosString {
    return firestore.collection("horarios").snapshots().map(databaseService.horariosListFromSnapshotString);
  }

  Stream<List<String>> get estadosString {
    return firestore.collection("estados").snapshots().map(databaseService.estadosListFromSnapshotString);
  }

  Stream<List<String>> get companiaStringString {
    return firestore.collection("companias").snapshots().map(databaseService.compniaListFromSnapshotString);
  }
}
