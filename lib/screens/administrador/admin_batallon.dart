import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_batallon.dart';
import 'package:tblpartes/screens/listas/batallonlistas.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminBatallon extends StatefulWidget {
  AdminBatallon({Key? key}) : super(key: key);

  @override
  _AdminBatallonState createState() => _AdminBatallonState();
}

class _AdminBatallonState extends State<AdminBatallon> {
  DatabaseService databaseService = new DatabaseService();
  StreamServices streamServices = new StreamServices();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Batallon>>.value(
        initialData: [],
        value: streamServices.batallones,
        child: Scaffold(
          floatingActionButton: TextButton(
              child: Text(
                "Registrar Batallón",
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
                    return NewEditBatallon(
                      batallon: new Batallon(nombre: "", uid: ""),
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
              "Gestión de Batallones",
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: BatallonListas(),
        ));
  }
}
