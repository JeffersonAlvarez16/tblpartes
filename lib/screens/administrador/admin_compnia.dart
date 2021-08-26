import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_compania.dart';
import 'package:tblpartes/screens/listas/companialistas.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminCompania extends StatefulWidget {
  AdminCompania({Key? key}) : super(key: key);

  @override
  _AdminCompaniaState createState() => _AdminCompaniaState();
}

class _AdminCompaniaState extends State<AdminCompania> {
  DatabaseService databaseService = new DatabaseService();
  StreamServices streamServices = new StreamServices();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Compania>>.value(
        initialData: [],
        value: streamServices.companias,
        child: Scaffold(
          floatingActionButton: TextButton(
              child: Text(
                "Registrar Compañia",
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
                    return NewEditCompania(
                      compania: new Compania(nombre: "", uid: ""),
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
              "Gestión de Compañias",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: CompaniaListas(),
        ));
  }
}
