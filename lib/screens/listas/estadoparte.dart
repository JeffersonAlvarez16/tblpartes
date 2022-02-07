import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/services/auntentication.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class EstadosParte extends StatefulWidget {
  final UserModel usuario;
  final String horaParte;
  EstadosParte({Key? key, required this.usuario, required this.horaParte}) : super(key: key);
  @override
  _EstadosParteState createState() => _EstadosParteState();
}

class _EstadosParteState extends State<EstadosParte> {
  bool seleccionado = false;
  bool fechas = false;
  bool nota = false;
  String notastr = "";
  bool listado = false;
  dynamic lista = [];
  int indexbefore = 0;
  int indexbeforeb = 0;
  String estado = "";
  String seleccion = "";

  bool seleccionb = false;
  DateTime selectedDate = new DateTime.now();
  DateTime desde = DateTime.now();
  DateTime hasta = DateTime.now();
  String desdeString = "";
  String hastaString = "";
  DatabaseService databaseService = new DatabaseService();

  @override
  DateTime _now = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(locale: Locale('es'), context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        desde = picked;
        desdeString = new DateFormat("dd-MM-yyyy").format(picked);
        context.read<Autentication>().changeDesde(desdeString);
      });
    }
  }

  validateExistencia() async {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    String fechaStr = new DateFormat("dd-MM-yyyy").format(date);
    QuerySnapshot result = await databaseService.existenciaParte(fechaStr, widget.horaParte, widget.usuario.cedula);
    print("consulta");
    print(result.size);
    return result.size;
  }

  Future<Null> _selectDateHasta(BuildContext context) async {
    final DateTime? picked = await showDatePicker(locale: Locale('es'), context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      if (desde.compareTo(picked) > 0) {
        final snackBar = SnackBar(content: Text('La fecha debe ser mayor a la fecha de inicio'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          hastaString = "";
        });
      } else {
        setState(() {
          hasta = picked;
          hastaString = new DateFormat("dd-MM-yyyy").format(picked);
          context.read<Autentication>().changeHasta(hastaString);
        });
      }
    }
  }

  List<Widget> listaW = <Widget>[];

  @override
  Widget build(BuildContext context) {
    final estados = Provider.of<List<Estados>>(context);
    final DatabaseService databaseService = new DatabaseService();
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: NeverScrollableScrollPhysics(),
          itemCount: estados.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
                activeColor: Colors.pink[300],
                dense: true,
                //font change
                title: new Text(
                  estados[index].nombre,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                value: estados[index].estado,
                onChanged: (val) {
                  context.read<Autentication>().changeHasta("");
                  context.read<Autentication>().changeDesde("");
                  setState(() {
                    listaW.clear();

                    estado = estados[index].nombre;
                  });
                  if (estados[index].estado == true && seleccionado == true) {
                    setState(() {
                      estados[index].estado = false;
                      seleccionado = false;
                      this.nota = false;
                      this.fechas = false;
                      this.listado = false;
                    });
                  } else {
                    if (seleccionado == true) {
                      setState(() {
                        listaW.clear();
                        estados[indexbefore].estado = false;
                        estados[index].estado = val!;
                        indexbefore = index;
                        this.nota = estados[index].nota;
                        this.fechas = estados[index].fechas;
                        this.listado = estados[index].listado;
                        this.lista = estados[index].lista;
                      });
                    } else {
                      setState(() {
                        listaW.clear();

                        seleccionado = true;
                        estados[index].estado = val!;
                        indexbefore = index;
                        this.nota = estados[index].nota;
                        this.fechas = estados[index].fechas;
                        this.listado = estados[index].listado;
                        this.lista = estados[index].lista;
                      });
                    }

                    if (this.nota == true) {
                      setState(() {
                        listaW.add(textField(
                            hintText: 'Nota de la actividad',
                            enabled: true,
                            icono: Icons.note_add,
                            obscureText: false,
                            validator: (value) => value.isEmpty ? "Ingrese la nota de la actividad" : null,
                            onChanged: (value) {
                              setState(() {
                                notastr = value;
                              });
                            }));
                      });
                    }

                    if (this.fechas == true) {
                      if (hastaString.length > 0) {
                        context.read<Autentication>().changeHasta(hastaString);
                        context.read<Autentication>().changeDesde(desdeString);
                      } else {
                        context.read<Autentication>().changeHasta("");
                        context.read<Autentication>().changeDesde("");
                      }
                      setState(() {
                        listaW.add(Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _selectDate(context),
                                  child: Text('Desde'),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: label("Fecha Inicio: ", Colors.black, 16, FontWeight.bold),
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 12),
                                    child: StreamBuilder<dynamic>(
                                      stream: context.read<Autentication>().desde,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text("Seleccionar una fecha");
                                        }
                                        return label(snapshot.data, Colors.black, 16, FontWeight.normal);
                                      },
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _selectDateHasta(context),
                                  child: Text('Hasta'),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: label("Fecha Fin: ", Colors.black, 16, FontWeight.bold),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 12),
                                  child: StreamBuilder<dynamic>(
                                    stream: context.read<Autentication>().hasta,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text("Seleccionar una fecha");
                                      }
                                      return label(snapshot.data, Colors.black, 16, FontWeight.normal);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ));
                      });
                    }
                    if (listado == true) {
                      if (seleccion.length > 0) {
                        context.read<Autentication>().changeEstado(seleccion);
                      } else {
                        context.read<Autentication>().changeEstado(lista[0]);
                      }
                      listaW.add(Divider());
                      listaW.add(label("Selecciones una opcion de la lista", Colors.black, 16, FontWeight.bold));
                      listaW.add(StreamBuilder<dynamic>(
                        stream: context.read<Autentication>().estadoSelec,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            context.read<Autentication>().changeEstado(lista[0]);
                            return CircularProgressIndicator();
                          }
                          return DropdownButton<dynamic>(
                            isExpanded: true,
                            value: snapshot.data,
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Lato",
                            ),
                            onChanged: (dynamic? newValue) {
                              context.read<Autentication>().changeEstado(newValue);

                              seleccion = newValue;
                            },
                            items: lista.map<DropdownMenuItem>((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          );
                        },
                      ));
                    }
                    if (seleccionado == true) {
                      if (nota == false && fechas == false && listado == false) {
                        listaW.add(ElevatedButton(
                          onPressed: () async {
                            int res = await validateExistencia();
                            if (res == 1) {
                              bool res = await ButonUpdateGuardia(widget.usuario.cedula, widget.horaParte, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, estado, widget.usuario.grado, widget.usuario.compania, databaseService, context);
                              if (res == false) {
                              } else {
                                final snackBar = SnackBar(content: Text('Se actualizo el parte de las: ' + widget.horaParte));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                setState(() {
                                  seleccionado = false;
                                  estados[indexbefore].estado = false;
                                  listaW.clear();
                                });
                              }
                            } else if (res == 0) {
                              ButonGuardarGuardia(widget.usuario.cedula, widget.horaParte, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                              setState(() {
                                seleccionado = false;
                                estados[indexbefore].estado = false;
                                listaW.clear();
                              });
                              final snackBar = SnackBar(content: Text('Se registro el parte correctamente'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            } else {
                              final snackBar = SnackBar(content: Text('Error en registro, validar tu internet'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: Text('Registrar Parte'),
                        ));
                      }
                      if (nota == true && fechas == false && listado == false && seleccionado == true) {
                        listaW.add(ElevatedButton(
                          onPressed: () async {
                            if (notastr.length > 0) {
                              int res = await validateExistencia();
                              if (res == 1) {
                                ButonUpdateGuardaNota(widget.usuario.cedula, widget.horaParte, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                setState(() {
                                  seleccionado = false;
                                  estados[indexbefore].estado = false;
                                  listaW.clear();
                                });
                                final snackBar = SnackBar(content: Text('Se actualizo el parte de las: ' + widget.horaParte));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } else if (res == 0) {
                                ButonGuardarGuardaNota(widget.usuario.cedula, widget.horaParte, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                setState(() {
                                  seleccionado = false;
                                  estados[indexbefore].estado = false;
                                  listaW.clear();
                                });
                                final snackBar = SnackBar(content: Text('Se registro el parte correctamente'));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              } else {
                                final snackBar = SnackBar(content: Text('Error en registro, validar tu internet'));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            } else {
                              final snackBar = SnackBar(content: Text('Debe ingresar una nota'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: Text('Registrar Parte'),
                        ));
                      }
                      if (nota == true && fechas == true && listado == false && seleccionado == true) {
                        listaW.add(ElevatedButton(
                          onPressed: () async {
                            if (desdeString.length > 0) {
                              if (hastaString.length > 0) {
                                if (notastr.length > 0) {
                                  int res = await validateExistencia();
                                  if (res == 1) {
                                    ButonUpdateGuardaNotaFechas(widget.usuario.cedula, widget.horaParte, desdeString, hastaString, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                    setState(() {
                                      seleccionado = false;
                                      estados[indexbefore].estado = false;
                                      listaW.clear();
                                    });
                                    final snackBar = SnackBar(content: Text('Se actualizo el parte de las: ' + widget.horaParte));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  } else if (res == 0) {
                                    ButonGuardarGuardaNotaFechas(widget.usuario.cedula, widget.horaParte, desdeString, hastaString, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                    setState(() {
                                      seleccionado = false;
                                      estados[indexbefore].estado = false;
                                      listaW.clear();
                                    });
                                    final snackBar = SnackBar(content: Text('Se registro el parte correctamente'));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  } else {
                                    final snackBar = SnackBar(content: Text('Error en registro, validar tu internet'));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                } else {
                                  final snackBar = SnackBar(content: Text('Debe Ingresar una nota'));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              } else {
                                final snackBar = SnackBar(content: Text('Debe Ingresar una fecha de finalización'));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            } else {
                              final snackBar = SnackBar(content: Text('Debe Ingresar una fecha de incio'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: Text('Registrar Parte'),
                        ));
                      }
                      if (nota == true && fechas == true && listado == true && seleccionado == true) {
                        listaW.add(ElevatedButton(
                          onPressed: () async {
                            if (desdeString.length > 0) {
                              if (hastaString.length > 0) {
                                if (notastr.length > 0) {
                                  if (seleccion.length > 0) {
                                    int res = await validateExistencia();
                                    if (res == 1) {
                                      ButonUpdateGuardaNotaFechasListado(widget.usuario.cedula, seleccion, widget.horaParte, desdeString, hastaString, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                      setState(() {
                                        seleccionado = false;
                                        estados[indexbefore].estado = false;
                                        listaW.clear();
                                      });
                                      final snackBar = SnackBar(content: Text('Se actualizo el parte de las: ' + widget.horaParte));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    } else if (res == 0) {
                                      ButonGuardarGuardaNotaFechasListado(widget.usuario.cedula, seleccion, widget.horaParte, desdeString, hastaString, widget.usuario.uid, widget.usuario.nombres, widget.usuario.apellidos, notastr, estado, widget.usuario.grado, widget.usuario.compania, databaseService);
                                      setState(() {
                                        seleccionado = false;
                                        estados[indexbefore].estado = false;
                                        listaW.clear();
                                      });
                                      final snackBar = SnackBar(content: Text('Se registro el parte correctamente'));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    } else {
                                      final snackBar = SnackBar(content: Text('Error en registro, validar tu internet'));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  } else {
                                    final snackBar = SnackBar(content: Text('Debe seleccionar una opcion de la lista'));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                } else {
                                  final snackBar = SnackBar(content: Text('Debe Ingresar una nota'));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              } else {
                                final snackBar = SnackBar(content: Text('Debe Ingresar una fecha de finalización'));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            } else {
                              final snackBar = SnackBar(content: Text('Debe Ingresar una fecha de incio'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: Text('Registrar Parte'),
                        ));
                      }
                    }
                  }
                });
          },
        ),
        ListView.builder(
            shrinkWrap: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            itemCount: listaW.length,
            itemBuilder: (context, index) {
              return this.listaW[index];
            }),
      ],
    );
  }

  void dispose() {
    super.dispose();
  }
}

void ButonGuardarGuardia(cedula, horaParte, uidPersonal, nombres, apellidos, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  var uid = Uuid().v4();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = uid;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["apellidos"] = apellidos;
  data["compania"] = compania;
  data["seleccion"] = "";
  data["contador"] = 0;
  data["nota"] = "";
  data["cedula"] = cedula;
  data["desde"] = "";
  data["hasta"] = "";
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();

  await databaseService.createParte(uid, data);
}

Future<bool> ButonUpdateGuardia(cedula, horaParte, uidPersonal, nombres, apellidos, estado, rango, compania, databaseService, context) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  QuerySnapshot<Map<String, dynamic>> docu = await databaseService.existenciaParte(desdeString, horaParte, cedula);
  print(docu.docs[0]);
  Map<String, dynamic> dataAnterior = docu.docs[0].data();

  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = docu.docs[0].id;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["apellidos"] = apellidos;
  data["compania"] = compania;
  data["seleccion"] = "";
  data["contador"] = 0;
  data["cedula"] = cedula;
  data["nota"] = "";
  data["desde"] = "";
  data["hasta"] = "";
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();
  if (dataAnterior["estado"] == estado) {
    final snackBar = SnackBar(content: Text("El estado a registrar es el mismo en que se encuentra actualmente"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  } else {
    dynamic reus = await databaseService.saveNotification(compania, estado, nombres, apellidos, horaParte, dataAnterior["estado"], docu.docs[0].id, dataAnterior["uid_personal"], "", "");
    if (reus == false) {
      final snackBar = SnackBar(content: Text("No existe un comandate de compañia asignado aun"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    } else {
      await databaseService.createParte(docu.docs[0].id, data);
      return true;
    }
  }
}

void ButonGuardarGuardaNota(cedula, horaParte, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);

  var uid = Uuid().v4();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = uid;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["seleccion"] = "";
  data["apellidos"] = apellidos;
  data["contador"] = 0;
  data["desde"] = "";
  data["cedula"] = cedula;
  data["hasta"] = "";
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();
  await databaseService.createParte(uid, data);
}

Future<bool> ButonUpdateGuardaNota(cedula, horaParte, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  QuerySnapshot<Map<String, dynamic>> docu = await databaseService.existenciaParte(desdeString, horaParte, cedula);
  Map<String, dynamic> dataAnterior = docu.docs[0].data();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = docu.docs[0].id;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["seleccion"] = "";
  data["cedula"] = cedula;
  data["apellidos"] = apellidos;
  data["contador"] = 0;
  data["desde"] = "";
  data["hasta"] = "";
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();
  if (dataAnterior["estado"] == estado) {
    return false;
  } else {
    await databaseService.createParte(docu.docs[0].id, data);
    await databaseService.saveNotification(compania, estado, nombres, apellidos, horaParte, dataAnterior["estado"], docu.docs[0].id, dataAnterior["uid_personal"], "", "");
    return true;
  }
}

void ButonGuardarGuardaNotaFechas(cedula, horaParte, desde, hasta, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  var uid = Uuid().v4();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = uid;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["apellidos"] = apellidos;
  data["seleccion"] = "";
  data["contador"] = 0;
  data["cedula"] = cedula;
  data["desde"] = desde;
  data["hasta"] = hasta;
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();

  await databaseService.createParte(uid, data);
}

Future<bool> ButonUpdateGuardaNotaFechas(cedula, horaParte, desde, hasta, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  QuerySnapshot<Map<String, dynamic>> docu = await databaseService.existenciaParte(desdeString, horaParte, cedula);
  Map<String, dynamic> dataAnterior = docu.docs[0].data();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = docu.docs[0].id;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["apellidos"] = apellidos;
  data["cedula"] = cedula;
  data["seleccion"] = "";
  data["contador"] = 0;
  data["desde"] = desde;
  data["hasta"] = hasta;
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();

  if (dataAnterior["estado"] == estado) {
    return false;
  } else {
    await databaseService.createParte(docu.docs[0].id, data);
    await databaseService.saveNotification(compania, estado, nombres, apellidos, horaParte, dataAnterior["estado"], docu.docs[0].id, dataAnterior["uid_personal"], desde, hasta);
    return true;
  }
}

void ButonGuardarGuardaNotaFechasListado(cedula, seleccion, horaParte, desde, hasta, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  var uid = Uuid().v4();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = uid;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["apellidos"] = apellidos;
  data["cedula"] = cedula;
  data["seleccion"] = seleccion;
  data["contador"] = 0;
  data["desde"] = desde;
  data["hasta"] = hasta;
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();
  await databaseService.createParte(uid, data);
}

Future<bool> ButonUpdateGuardaNotaFechasListado(cedula, seleccion, horaParte, desde, hasta, uidPersonal, nombres, apellidos, nota, estado, rango, compania, databaseService) async {
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(now.year, now.month, now.day);
  String desdeString = new DateFormat("dd-MM-yyyy").format(date);
  QuerySnapshot<Map<String, dynamic>> docu = await databaseService.existenciaParte(desdeString, horaParte, cedula);
  Map<String, dynamic> dataAnterior = docu.docs[0].data();
  final Map<String, dynamic> data = Map<String, dynamic>();
  data["uid"] = docu.docs[0].id;
  data["uid_personal"] = uidPersonal;
  data["nombres"] = nombres;
  data["estado"] = estado;
  data["rango"] = rango;
  data["compania"] = compania;
  data["nota"] = nota;
  data["apellidos"] = apellidos;
  data["cedula"] = cedula;
  data["seleccion"] = seleccion;
  data["contador"] = 0;
  data["desde"] = desde;
  data["hasta"] = hasta;
  data["fechaRegistro"] = desdeString;
  data["hora_registro"] = horaParte;
  data["create"] = FieldValue.serverTimestamp();
  if (dataAnterior["estado"] == estado) {
    return false;
  } else {
    await databaseService.createParte(docu.docs[0].id, data);
    await databaseService.saveNotification(compania, estado, nombres, apellidos, horaParte, dataAnterior["estado"], docu.docs[0].id, dataAnterior["uid_personal"], desde, hasta);
    return true;
  }
}

Widget label(String text, Color color, double size, FontWeight weight) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "Lato", fontWeight: weight != null ? weight : FontWeight.bold),
  );
}

Widget textField({String? hintText, IconData? icono, bool enabled = false, bool obscureText = false, Function(String)? onChanged, dynamic validator, TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(24),
    ),
    child: TextFormField(
      enabled: enabled,
      validator: validator,
      keyboardType: textInputTipe,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Lato", fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          prefixIcon: Icon(
            icono,
            color: Colors.black,
          ),
          border: InputBorder.none),
    ),
  );
}
