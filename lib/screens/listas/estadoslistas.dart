import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/services/database.dart';

class EstadosListas extends StatefulWidget {
  @override
  _EstadosListasState createState() => _EstadosListasState();
}

class _EstadosListasState extends State<EstadosListas> {
  @override
  Widget build(BuildContext context) {
    final estados = Provider.of<List<Estados>>(context);
    final DatabaseService databaseService = new DatabaseService();

    return ListView.builder(
      itemCount: estados.length,
      itemBuilder: (context, index) {
        return InkWell(
          child: Dismissible(
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Desea eliminar el estado:",
                      style: TextStyle(fontFamily: "Lato", fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      estados[index].nombre + "?",
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
            // identificar de manera ??nica los Widgets.
            key: Key(estados[index].nombre),
            // Tambi??n debemos proporcionar una funci??n que diga a nuestra aplicaci??n
            // qu?? hacer despu??s de que un elemento ha sido eliminado.
            onDismissed: (direction) async {
              // Remueve el elemento de nuestro data source.
              await databaseService.eliminarEstados(estados[index].uid);

              final snackBar = SnackBar(content: Text('Se elimino el estado correctamente'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              // Muestra un snackbar! Este snackbar tambien podr??a contener acciones "Undo".
            },
            child: ListTile(
                title: Text(
              estados[index].nombre,
              style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
            )),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return NewEditEstados(
                  estados: estados[index],
                );
              }),
            );
          },
        );
      },
    );
  }
}
