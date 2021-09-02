import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/models/usuarios.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_usuarios.dart';
import 'package:tblpartes/screens/listas/usuarioslistas.dart';
import 'package:tblpartes/services/streams.dart';

class AdminUsuarios extends StatefulWidget {
  AdminUsuarios({Key? key}) : super(key: key);

  @override
  _AdminUsuariosState createState() => _AdminUsuariosState();
}

class _AdminUsuariosState extends State<AdminUsuarios> {
  TextEditingController editingController = TextEditingController();
  StreamServices streamServices = new StreamServices();
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Usuarios>>.value(
        initialData: [],
        value: streamServices.usuarios,
        child: Scaffold(
          floatingActionButton: StreamProvider<List<Batallon>>.value(
            value: streamServices.batallones,
            initialData: [],
            child: TextButton(
                child: Text(
                  "Registrar Usuario",
                  style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
                ),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return NewEditUsuarios(usuario: new Usuarios(uid_user: "", type_user: "", cedula: "", correo: "", compania: "", nombres: "", uid: ""));
                    }),
                  );
                }),
          ),
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
              "Gestión de usuarios",
              style: TextStyle(color: Colors.black, fontFamily: "Lato", fontWeight: FontWeight.bold),
            ),
          ),
          body: UsuarioslListas(),
        ));
  }
}
