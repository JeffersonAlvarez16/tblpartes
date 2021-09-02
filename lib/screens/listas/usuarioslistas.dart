import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/models/usuarios.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_compania.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_personal.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_usuarios.dart';
import 'package:tblpartes/services/database.dart';

class UsuarioslListas extends StatefulWidget {
  @override
  _UsuarioslListasState createState() => _UsuarioslListasState();
}

class _UsuarioslListasState extends State<UsuarioslListas> {
  @override
  Widget build(BuildContext context) {
    final usuarios = Provider.of<List<Usuarios>>(context);
    final DatabaseService databaseService = new DatabaseService();

    return ListView.builder(
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Dismissible(
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Desea eliminar el usuario:",
                        style: TextStyle(fontFamily: "Lato", fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        usuarios[index].nombres + "?",
                        style: TextStyle(fontFamily: "Lato", fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancelar", style: TextStyle(fontFamily: "Lato", fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromRGBO(218, 0, 55, 1))),
                        ),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Eliminar",
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))),
                      ],
                    );
                  },
                );
              },
              // Cada Dismissible debe contener una llave. Las llaves permiten a Flutter
              // identificar de manera única los Widgets.
              key: Key(usuarios[index].nombres),
              // También debemos proporcionar una función que diga a nuestra aplicación
              // qué hacer después de que un elemento ha sido eliminado.
              onDismissed: (direction) async {
                // Remueve el elemento de nuestro data source.
                await databaseService.eliminarUsuarios(usuarios[index].uid);

                final snackBar = SnackBar(content: Text('Se elimino el usuario correctamente'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);

                // Muestra un snackbar! Este snackbar tambien podría contener acciones "Undo".
              },
              child: ListTile(
                  title: Text(
                "(" + usuarios[index].type_user + ")" + " " + usuarios[index].nombres,
                style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
              ))),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return NewEditUsuarios(
                  usuario: usuarios[index],
                );
              }),
            );
          },
        );
      },
    );
  }
}
