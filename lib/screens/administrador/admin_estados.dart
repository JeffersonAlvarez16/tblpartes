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
                style: TextStyle(
                    color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return NewEditEstados(
                      estados: new Estados(
                          nombre: "",
                          uid: "",
                          nota: false,
                          fechas: false,
                          listado: false,
                          lista: listas,
                          estado: false),
                    );
                  }),
                );
              }),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Color.fromRGBO(237, 237, 237, 1),
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
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: EstadosListas(),
        ));
  }
}
