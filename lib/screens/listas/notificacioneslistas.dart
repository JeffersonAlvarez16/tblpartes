import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/notificaciones.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/services/database.dart';

class NotificacionesLista extends StatefulWidget {
  @override
  _NotificacionesListaState createState() => _NotificacionesListaState();
}

class _NotificacionesListaState extends State<NotificacionesLista> {
  @override
  Widget build(BuildContext context) {
    final notificaciones = Provider.of<List<Notificaciones>>(context);
    final DatabaseService databaseService = new DatabaseService();

    return ListView.builder(
      itemCount: notificaciones.length,
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
                      notificaciones[index].name + "?",
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
            key: Key(notificaciones[index].uid),
            // También debemos proporcionar una función que diga a nuestra aplicación
            // qué hacer después de que un elemento ha sido eliminado.
            onDismissed: (direction) async {
              // Remueve el elemento de nuestro data source.
              await databaseService.eliminarNotificacion(notificaciones[index].uid);

              final snackBar = SnackBar(content: Text('Se elimino el estado correctamente'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              // Muestra un snackbar! Este snackbar tambien podría contener acciones "Undo".
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                  subtitle: Text(
                    notificaciones[index].subject,
                    style: TextStyle(color: Colors.black45, fontSize: 12, fontFamily: "Lato", fontWeight: FontWeight.bold),
                  ),
                  title: Text(
                    notificaciones[index].name,
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: "Lato", fontWeight: FontWeight.bold),
                  )),
            ),
          ),
          onTap: () {},
        );
      },
    );
  }
}
