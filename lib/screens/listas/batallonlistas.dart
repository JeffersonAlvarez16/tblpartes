import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_batallon.dart';
import 'package:tblpartes/services/database.dart';

class BatallonListas extends StatefulWidget {
  @override
  _BatallonListasState createState() => _BatallonListasState();
}

class _BatallonListasState extends State<BatallonListas> {
  @override
  Widget build(BuildContext context) {
    final batallones = Provider.of<List<Batallon>>(context);
    final DatabaseService databaseService = new DatabaseService();

    return ListView.builder(
      itemCount: batallones.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Dismissible(
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Desea eliminar el batallon:",
                      style: TextStyle(
                          fontFamily: "OpenSans",
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      batallones[index].nombre + "?",
                      style: TextStyle(
                          fontFamily: "OpenSans",
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancelar",
                            style: TextStyle(
                                fontFamily: "OpenSans",
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(218, 0, 55, 1))),
                      ),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Eliminar",
                              style: TextStyle(
                                fontFamily: "OpenSans",
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
            key: Key(batallones[index].nombre),
            // También debemos proporcionar una función que diga a nuestra aplicación
            // qué hacer después de que un elemento ha sido eliminado.
            onDismissed: (direction) async {
              // Remueve el elemento de nuestro data source.
              await databaseService.eliminarBatallon(batallones[index].uid);

              final snackBar = SnackBar(
                  content: Text('Se elimino el batallón correctamente'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              // Muestra un snackbar! Este snackbar tambien podría contener acciones "Undo".
            },
            child: ListTile(
                title: Text(
              batallones[index].nombre.toUpperCase(),
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.bold),
            )),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return NewEditBatallon(
                  batallon: batallones[index],
                );
              }),
            );
          },
        );
      },
    );
  }
}
