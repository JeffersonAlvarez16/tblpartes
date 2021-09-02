import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/screens/listas/estadoslistas.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminEstados extends StatefulWidget {
  AdminEstados({Key? key}) : super(key: key);

  @override
  _AdminEstadosState createState() => _AdminEstadosState();
}

class _AdminEstadosState extends State<AdminEstados> {
  DatabaseService databaseService = new DatabaseService();
  StreamServices streamServices = new StreamServices();
  List<String> listas = <String>[];
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Estados>>.value(
        initialData: [],
        value: streamServices.estados,
        child: Scaffold(
          floatingActionButton: TextButton(
              child: Text(
                "Registrar Estados",
                style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
              ),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return NewEditEstados(
                      estados: new Estados(nombre: "", uid: "", nota: false, fechas: false, listado: false, lista: listas, estado: false),
                    );
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
              "Gestión de Estados",
              style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: Colors.black12, child: EstadosListas()),
        ));
  }
}
