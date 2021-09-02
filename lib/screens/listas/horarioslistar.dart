import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/horarios.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_compania.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_estados.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_horarios.dart';
import 'package:tblpartes/services/database.dart';

class HorariosListas extends StatefulWidget {
  @override
  _HorariosListasState createState() => _HorariosListasState();
}

class _HorariosListasState extends State<HorariosListas> {
  @override
  Widget build(BuildContext context) {
    final horarios = Provider.of<List<Horarios>>(context);
    final DatabaseService databaseService = new DatabaseService();

    return ListView.builder(
      itemCount: horarios.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.circle_rounded,
                color: horarios[index].estado == true ? Colors.greenAccent : Colors.redAccent,
                size: 24.0,
                semanticLabel: 'Text to announce in accessibility modes',
              ),
            ),
            Container(
              width: 120,
              child: InkWell(
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
                            horarios[index].hora + "?",
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
                  key: Key(horarios[index].uid),
                  // También debemos proporcionar una función que diga a nuestra aplicación
                  // qué hacer después de que un elemento ha sido eliminado.
                  onDismissed: (direction) async {
                    // Remueve el elemento de nuestro data source.
                    await databaseService.eliminarHoraroios(horarios[index].uid);

                    final snackBar = SnackBar(content: Text('Se elimino el estado correctamente'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    // Muestra un snackbar! Este snackbar tambien podría contener acciones "Undo".
                  },
                  child: ListTile(
                      title: Text(
                    horarios[index].hora,
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: "Lato", fontWeight: FontWeight.bold),
                  )),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return NewEditHorarios(horario: horarios[index]);
                    }),
                  );
                },
              ),
            ),
            TextButton(
                child: Text(
                  "Activar horario",
                  style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
                ),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
                onPressed: () async {
                  await databaseService.cambiarEstadoHorarios(horarios[index].uid);
                })
          ],
        );
      },
    );
  }
}
