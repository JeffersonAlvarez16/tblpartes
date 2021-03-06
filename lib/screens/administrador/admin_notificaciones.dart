import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/notificaciones.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_notificacion.dart';
import 'package:tblpartes/screens/listas/estadoslistas.dart';
import 'package:tblpartes/screens/listas/notificacioneslistas.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminNotificaciones extends StatefulWidget {
  AdminNotificaciones({Key? key}) : super(key: key);

  @override
  _AdminNotificacionesState createState() => _AdminNotificacionesState();
}

class _AdminNotificacionesState extends State<AdminNotificaciones> {
  DatabaseService databaseService = new DatabaseService();
  StreamServices streamServices = new StreamServices();
  List<String> listas = <String>[];
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Notificaciones>>.value(
        initialData: [],
        value: streamServices.notificaciones,
        child: Scaffold(
          floatingActionButton: TextButton(
              child: Text(
                "Registrar Notificación",
                style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
              ),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return NewEditNotificacion(notificaciones: new Notificaciones(name: "", uid: "", subject: ""));
                  }),
                );
              }),
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.black12,
            elevation: 0.0,
            toolbarHeight: 70,
            flexibleSpace: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
            ),
            actions: <Widget>[
              Tooltip(
                message: 'User Account',
                child: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Tooltip(
                      message: 'User Account',
                      child: IconButton(
                        icon: Icon(Icons.high_quality),
                        onPressed: () {
                          /* your code */
                        },
                      ),
                    );
                  },
                ),
              )
            ],
            title: Text(
              "Gestión de notificaciones",
              style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: Colors.black12, child: NotificacionesLista()),
        ));
  }
}
