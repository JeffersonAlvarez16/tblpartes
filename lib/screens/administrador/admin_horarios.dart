import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/horarios.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_horarios.dart';
import 'package:tblpartes/screens/listas/estadoslistas.dart';
import 'package:tblpartes/screens/listas/horarioslistar.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminHorarios extends StatefulWidget {
  AdminHorarios({Key? key}) : super(key: key);

  @override
  _AdminHorariosState createState() => _AdminHorariosState();
}

class _AdminHorariosState extends State<AdminHorarios> {
  DatabaseService databaseService = new DatabaseService();
  StreamServices streamServices = new StreamServices();
  bool registrando = false;
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Horarios>>.value(
        initialData: [],
        value: streamServices.horarios,
        child: Scaffold(
          floatingActionButton: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              registrando == true
                  ? Row(
                      children: [
                        Text("Registando"),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(),
                        )
                      ],
                    )
                  : TextButton(
                      child: Text(
                        "Registrar parte Falto",
                        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
                      ),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red.shade900)),
                      onPressed: () async {
                        DateTime selectedDate = new DateTime.now();
                        String desdeString = new DateFormat("dd-MM-yyyy").format(selectedDate);
                        setState(() {
                          registrando = true;
                        });
                        String messaje = await databaseService.fetchPost(desdeString);

                        if (messaje != "null") {
                          setState(() {
                            registrando = false;
                          });
                          final snackBar = SnackBar(content: Text('Se registro el parte correctamente'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          setState(() {
                            registrando = false;
                          });
                          final snackBar = SnackBar(content: Text('Error al registrar los partes'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }),
              TextButton(
                  child: Text(
                    "Registrar Horarios",
                    style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
                  ),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return NewEditHorarios(horario: new Horarios(hora: "", uid: "", createAt: new DateTime.now(), estado: false));
                      }),
                    );
                  })
            ],
          ),
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
              "Gesti??n de Horarios",
              style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: Colors.black12, child: HorariosListas()),
        ));
  }
}
