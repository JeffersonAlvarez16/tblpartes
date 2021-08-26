import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/horarios.dart';
import 'package:tblpartes/models/notificaciones.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/models/usuarios.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseApp secondary = Firebase.apps.elementAt(1);

  Future<String> initbatallon() async {
    QuerySnapshot<Map<String, dynamic>> batallon = await firestore.collection("batallones").snapshots().first;
    return batallon.docs[0]["nombre"];
  }

  Future<String> initcompania() async {
    QuerySnapshot<Map<String, dynamic>> compania = await firestore.collection("companias").snapshots().first;
    return compania.docs[0]["nombre"];
  }

  //////////////////////////////////////////////////////////////////////
  // CRUD MODEL BATALLON
  Future<void> createBatallon(String uid, Map<String, dynamic> batallon) async {
    return await firestore.collection("batallones").doc(uid).set(batallon);
  }

  Future<void> updateBatallon(String uid, Map<String, dynamic> batallon) async {
    return await firestore.collection("batallones").doc(uid).update(batallon);
  }

  Future<void> eliminarBatallon(String uid) async {
    return await firestore.collection("batallones").doc(uid).delete();
  }

//////////////////////////////////////////////////////////////////////
// CRUD MODEL COMPANIA
  Future<void> createCompania(String uid, Map<String, dynamic> compania) async {
    return await firestore.collection("companias").doc(uid).set(compania);
  }

  Future<void> updateCompania(String uid, Map<String, dynamic> compania) async {
    return await firestore.collection("companias").doc(uid).update(compania);
  }

  Future<void> eliminarCompania(String uid) async {
    return await firestore.collection("companias").doc(uid).delete();
  }

  Future<void> createParte(String uid, Map<String, dynamic> parte) async {
    return await firestore.collection("partes").doc(uid).set(parte);
  }

//////////////////////////////////////////////////////////////////////
// CRUD MODEL COMPANIA
  Future<void> createPersonal(String uid, Map<String, dynamic> personal) async {
    try {
      FirebaseAuth _auth_secondari = FirebaseAuth.instanceFor(app: secondary);
      UserCredential user = await _auth_secondari.createUserWithEmailAndPassword(email: personal["email"], password: personal["password"]);
      personal["uid"] = user.user!.uid;
      return await firestore.collection("personal").doc(user.user!.uid).set(personal);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePersonal(String uid, Map<String, dynamic> personal) async {
    return await firestore.collection("personal").doc(uid).update(personal);
  }

  Future<void> eliminarPersonal(String uid) async {
    return await firestore.collection("personal").doc(uid).delete();
  }

  Future<void> crearNotificacion(String uid, Map<String, dynamic> notificacion) async {
    try {
      return await firestore.collection("notificaciones_admin").doc(uid).set(notificacion);
    } catch (e) {
      return null;
    }
  }

  //////////////////////////////////////////////////////////////////////
// CRUD MODEL ESTADOS
  Future<void> createEstados(String uid, Map<String, dynamic> estados) async {
    try {
      return await firestore.collection("estados").doc(uid).set(estados);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateEstados(String uid, Map<String, dynamic> estados) async {
    return await firestore.collection("estados").doc(uid).update(estados);
  }

  Future<void> eliminarEstados(String uid) async {
    return await firestore.collection("estados").doc(uid).delete();
  }

  Future<void> eliminarNotificacion(String uid) async {
    return await firestore.collection("notificaciones_admin").doc(uid).delete();
  }

  //////////////////////////////////////////////////////////////////////
// CRUD MODEL USUARIOS
  Future<void> createUsuarios(String uid, Map<String, dynamic> usuarios) async {
    try {
      return await firestore.collection("users").doc(usuarios["uid_user"]).set(usuarios);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUsuarios(String uid, Map<String, dynamic> usuarios) async {
    return await firestore.collection("users").doc(uid).update(usuarios);
  }

  Future<void> eliminarUsuarios(String uid) async {
    return await firestore.collection("users").doc(uid).delete();
  }

  //CRUD MODEL HORARIOS
  Future<void> createHoraroios(String uid, Map<String, dynamic> horarios) async {
    try {
      return await firestore.collection("horarios").doc(horarios["uid"]).set(horarios);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateHoraroios(String uid, Map<String, dynamic> horarios) async {
    return await firestore.collection("horarios").doc(uid).update(horarios);
  }

  Future<void> eliminarHoraroios(String uid) async {
    return await firestore.collection("horarios").doc(uid).delete();
  }

  //listas batallon
  List<Batallon> batallonListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.data);

      String json = jsonEncode(doc.data());
      Map<String, dynamic> batallon = jsonDecode(json);
      return Batallon(
        nombre: batallon['nombre'] ?? '',
        uid: batallon['uid'] ?? "",
      );
    }).toList();
  }

  //listas companias
  List<Compania> companiaListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.data);

      String json = jsonEncode(doc.data());
      Map<String, dynamic> compania = jsonDecode(json);
      return Compania(
        nombre: compania['nombre'] ?? '',
        uid: compania['uid'] ?? "",
      );
    }).toList();
  }

  //listas companias
  List<UserModel> personalListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.data);

      String json = jsonEncode(doc.data());
      Map<String, dynamic> personal = jsonDecode(json);
      return UserModel.fromUserModel(uid: personal['uid'] ?? "", token: personal["token"] ?? "", apellidos: personal['apellidos'] ?? '', grado: personal['grado'] ?? '', nombres: personal['nombres'] ?? '', batallon: personal['batallon'] ?? '', compania: personal['compania'] ?? '', email: personal['email'] ?? '', typeUser: personal['typeUser'] ?? '', cedula: personal['cedula'] ?? '');
    }).toList();
  }

//listas estados
  List<Estados> estadosListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final Map<String, dynamic> estados = doc.data() as Map<String, dynamic>;

      List<String> listass = <String>["sas", "dasf"];
      dynamic lista = estados["listas"];

      //print(lista);

      return Estados(nombre: estados['nombre'] ?? '', uid: estados['uid'] ?? "", nota: estados['nota'] ?? false, listado: estados['listado'] ?? false, estado: estados["estado"] ?? false, fechas: estados['fechas'] ?? false, lista: lista ?? []);
    }).toList();
  }

  List<Notificaciones> notificacionesListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.data);
      String json = jsonEncode(doc.data());
      Map<String, dynamic> personal = jsonDecode(json);
      return Notificaciones(name: personal["name"], subject: personal["subject"], uid: personal["uid"]);
    }).toList();
  }

  List<Usuarios> usuariosListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //print(doc.data);

      String json = jsonEncode(doc.data());
      Map<String, dynamic> usuarios = jsonDecode(json);
      return Usuarios(
        uid_user: usuarios['uid_user'] ?? '',
        type_user: usuarios['type_user'] ?? "",
        nombres: usuarios['nombres'] ?? false,
        uid: usuarios['uid'] ?? false,
        compania: usuarios['compania'] ?? "",
        cedula: usuarios['cedula'] ?? "",
        correo: usuarios['correo'] ?? "",
      );
    }).toList();
  }

  List<Horarios> horariosListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((QueryDocumentSnapshot doc) {
      dynamic data = doc.data();

      return Horarios(hora: data["hora"], uid: data["uid"], createAt: data["createAt"].toDate());
    }).toList();
  }

  List<String> horariosListFromSnapshotString(QuerySnapshot snapshot) {
    List<String> horarios = [];
    return snapshot.docs.map((QueryDocumentSnapshot doc) {
      dynamic data = doc.data();
      return data["hora"].toString();
    }).toList();
  }

  List<String> estadosListFromSnapshotString(QuerySnapshot snapshot) {
    List<String> horarios = [];
    return snapshot.docs.map((QueryDocumentSnapshot doc) {
      dynamic data = doc.data();
      return data["nombre"].toString();
    }).toList();
  }

  List<String> compniaListFromSnapshotString(QuerySnapshot snapshot) {
    List<String> horarios = [];
    return snapshot.docs.map((QueryDocumentSnapshot doc) {
      dynamic data = doc.data();
      return data["nombre"].toString();
    }).toList();
  }

  Future<String> getCorreo(String cedula) async {
    var user = await firestore.collection("personal").where("cedula", isEqualTo: cedula).get();
    if (user.size > 0) {
      String json = jsonEncode(user.docs[0].data());
      Map<String, dynamic> usuarios = jsonDecode(json);

      return usuarios["email"];
    } else {
      return "null";
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> registrarToken(String? token) async {
    if (_auth.currentUser!.uid.isEmpty) {
    } else {
      firestore.collection("personal").doc(_auth.currentUser!.uid).update({"token": token});
    }
    return null;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> existeHorario(String hora) async {
    return await firestore.collection("horarios").where("hora", isEqualTo: hora).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> existenciaParte(String fecha, String hora, String uidPersonal) async {
    return await firestore.collection("partes").where("uid_personal", isEqualTo: uidPersonal).where("fechaRegistro", isEqualTo: fecha).where("hora_registro", isEqualTo: hora).get();
  }

  Future saveNotification(String compania, String estado, String nombres, String apellidos, String horario, String parteAnterior, String idParte, String uid_personal) async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    String desdeString = new DateFormat("dd-MM-yyyy").format(date);
    QuerySnapshot<Map<String, dynamic>> user = await firestore.collection("users").where("compania", isEqualTo: compania).where("type_user", isEqualTo: "Comandante de Compañía").get();
    String id = user.docs[0].id;
    Map<String, dynamic> dataUser = user.docs[0].data();
    DocumentSnapshot<Map<String, dynamic>> personal = await firestore.collection("personal").doc(id).get();
    Map<String, dynamic>? data = personal.data();
    String token = data!["token"];
    return await firestore.collection("notification").add({"name": "Autorización de cambio de estado en el parte", "subject": "El Sr. $nombres $apellidos desea hacer el cambio de esatado en el parte de: $horario, del dia $desdeString", "token": token, "parte_anterior": parteAnterior, "parte_nuevo": estado, "uid": dataUser["uid"], "estado": "en_espera", "create": FieldValue.serverTimestamp(), "id_parte": idParte, "atendido": false, "uid_personal": uid_personal});
  }

  Future saveNotificationUser(bool acepted, String idUser) async {
    if (acepted == true) {
      DocumentSnapshot<Map<String, dynamic>> personal = await firestore.collection("personal").doc(idUser).get();
      Map<String, dynamic>? data = personal.data();
      String token = data!["token"];

      return await firestore.collection("notifications").add({"name": "Se acepto el cambio de estado", "subject": "Su cambio estado en el parte a sido aceptado", "token": token, "create": FieldValue.serverTimestamp(), "atendido": false, "uid": idUser});
    } else {
      DocumentSnapshot<Map<String, dynamic>> personal = await firestore.collection("personal").doc(idUser).get();
      Map<String, dynamic>? data = personal.data();
      String token = data!["token"];

      return await firestore.collection("notifications").add({"name": "Se rechazo el cambio de estado en su parte", "subject": "Su cambio de estado en el parte a sido rechazado", "token": token, "create": FieldValue.serverTimestamp(), "atendido": false, "uid": idUser});
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificacionesExistentes() {
    String uid = _auth.currentUser!.uid;

    return firestore.collection("notification").where("uid", isEqualTo: uid).orderBy("create").snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificacionesExistentesUser() {
    String uid = _auth.currentUser!.uid;

    return firestore.collection("notifications").where("uid", isEqualTo: uid).orderBy("create").snapshots();
  }

  Future cambiarParte(String idParte, String idNotifi, String estado, bool type, String idUser) async {
    if (type == true) {
      await firestore.collection("notification").doc(idNotifi).update({"atendido": true, "estado": "aceptado"});
      await saveNotificationUser(true, idUser);
      return await firestore.collection("partes").doc(idParte).update({"estado": estado});
    } else {
      await firestore.collection("notification").doc(idNotifi).update({"atendido": true, "estado": "rechazado"});
      await saveNotificationUser(false, idUser);
      return await firestore.collection("partes").doc(idParte).update({"estado": estado});
    }
  }

  Future cambiarEstadoNotiUser(String notificacion) async {
    return await firestore.collection("notifications").doc(notificacion).update({"atendido": true});
  }

  Future<QuerySnapshot<Map<String, dynamic>>> existeUsuario(String typeUser) async {
    return await firestore.collection("users").where("type_user", isEqualTo: typeUser).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> existeUsuarioCompania(String typeUser, String compania) async {
    return await firestore.collection("users").where("type_user", isEqualTo: typeUser).where("compania", isEqualTo: compania).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> existeUsuarioUid(
    String uidUser,
  ) async {
    return await firestore.collection("users").where("uid_user", isEqualTo: uidUser).get();
  }
}
