import 'package:flutter/material.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class NewEditEstados extends StatefulWidget {
  final Estados estados;
  NewEditEstados({Key? key, required this.estados}) : super(key: key);

  @override
  _NewEditEstadosState createState() => _NewEditEstadosState();
}

class _NewEditEstadosState extends State<NewEditEstados> {
  final DatabaseService databaseService = new DatabaseService();
  String nombre = "";

  bool nota = false;
  bool fechas = false;
  bool update = false;
  bool listado = false;
  String nombreLista = "";
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.estados.uid.isNotEmpty) {
      setState(() {
        this.nombre = widget.estados.nombre;
        this.nota = widget.estados.nota;
        this.fechas = widget.estados.fechas;
        this.listado = widget.estados.listado;
        this.listas = widget.estados.lista;
        this.update = true;
      });
    }
  }

  dynamic listas = <String>[];

  agregarEstado(String estado) {
    setState(() {
      listas.add(estado);
      nombreLista = "";
    });
  }

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.nombre, this.nota, this.fechas, this.listas, this.listado) : ButonUpdate(_formKey, databaseService, context, nombre, widget.estados.uid, nota, fechas, listas, listado),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(237, 237, 237, 1),
        title: Text(
          "Datos del estado",
          style: TextStyle(color: Colors.black, fontFamily: "OpenSans", fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 36),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  textField(
                      hintText: 'Nombre',
                      icono: Icons.lock_open_outlined,
                      obscureText: false,
                      valor: nombre,
                      validator: (value) => value.isEmpty ? "Ingrese el nombre del batallón" : null,
                      onChanged: (value) {
                        setState(() {
                          nombre = value;
                        });
                      }),
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: nota,
                            onChanged: (bool? value) {
                              setState(() {
                                nota = value!;
                              });
                            },
                          ),
                          Expanded(child: Text("Marque esta casilla, si debe dejar una nota ", style: TextStyle(color: Colors.black, fontFamily: "OpenSans", fontSize: 12))),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: fechas,
                            onChanged: (bool? value) {
                              setState(() {
                                fechas = value!;
                              });
                            },
                          ),
                          Expanded(child: Text("Marque esta casilla, si debe una fecha de salida y regreso", style: TextStyle(color: Colors.black, fontFamily: "OpenSans", fontSize: 12))),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: listado,
                            onChanged: (bool? value) {
                              setState(() {
                                listado = value!;
                              });
                              if (value == false) {
                                setState(() {
                                  listas.clear();
                                });
                              }
                            },
                          ),
                          Expanded(child: Text("Marque está casilla, si debe seleccionar de un listado", style: TextStyle(color: Colors.black, fontFamily: "OpenSans", fontSize: 12))),
                        ],
                      )
                    ],
                  ),
                  listado == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: Medidas.width(75),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                  ),
                                  child: TextFormField(
                                    controller: textController,
                                    onChanged: (value) {
                                      setState(() {
                                        nombreLista = value;
                                      });
                                    },
                                    style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "OpenSans", fontStyle: FontStyle.normal),
                                    textAlign: TextAlign.justify,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
                                      ),
                                      contentPadding: EdgeInsets.all(8),
                                      hintText: "Nombre",
                                      labelText: "Nombre",
                                      hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
                                      labelStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
                                    ),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      if (nombreLista.length > 0) {
                                        agregarEstado(nombreLista);
                                        setState(() {
                                          nombreLista = "";
                                        });
                                        textController.clear();
                                      } else {
                                        final snackBar = SnackBar(content: Text('Debe ingresar un nombre para poder añadir a la lista'));
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    },
                                    child: Text("Agregar"))
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text("Lista de opciones"),
                          ],
                        )
                      : Text(""),
                  SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listas.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(listas[index])),
                                    TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            listas.removeWhere((element) => element == listas[index]);
                                          });
                                        },
                                        icon: Icon(Icons.delete),
                                        label: Text(""))
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ))
                ],
              ),
            ),
          )),
    );
  }
}

Widget Listas() {
  return ListView.builder(
    itemCount: 1,
    itemBuilder: (context, index) {
      return Text("dsadg");
    },
  );
}

Widget ButonGuardar(_formKey, databaseService, context, nombre, nota, fechas, listas, listado) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        var uid = Uuid().v4();
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombre"] = nombre;
        data["uid"] = uid;
        data["nota"] = nota;
        data["fechas"] = fechas;
        data["listas"] = listas;
        data["listado"] = listado;

        if (_formKey.currentState!.validate()) {
          await databaseService.createEstados(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, nombre, uid, nota, fechas, listas, listado) {
  return TextButton(
      child: Text(
        "Actualizar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombre"] = nombre;
        data["uid"] = uid;
        data["nota"] = nota;
        data["fechas"] = fechas;
        data["listas"] = listas;
        data["listado"] = listado;
        if (_formKey.currentState!.validate()) {
          await databaseService.updateEstados(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget textField({String? hintText, IconData? icono, String? valor, bool obscureText = false, Function(String)? onChanged, dynamic validator, TextEditingController? textController, TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black12,
    ),
    child: TextFormField(
      controller: textController,
      validator: validator,
      initialValue: valor,
      keyboardType: textInputTipe,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "OpenSans", fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
        ),
        contentPadding: EdgeInsets.all(8),
        hintText: hintText,
        labelText: hintText,
        hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
        labelStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
      ),
    ),
  );
}
