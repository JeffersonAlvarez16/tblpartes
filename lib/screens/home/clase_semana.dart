import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/screens/home/asignar_parte.dart';
import 'package:tblpartes/screens/home/comandante.dart';
import 'package:tblpartes/screens/home/personal.dart';
import 'package:tblpartes/screens/listas/estadoparte.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/auntentication.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';
import 'package:firebase_core/firebase_core.dart';

class ClaseSemana extends StatefulWidget {
  static const String route = '/clase_semana';

  dynamic arguments;

  ClaseSemana({Key? key, required this.arguments}) : super(key: key);

  @override
  _ClaseSemanaState createState() => _ClaseSemanaState();
}

class _ClaseSemanaState extends State<ClaseSemana> {
  String? token = '';
  late FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  List<dynamic> lista = [];
  List<dynamic> listaTotal = [];
  StreamServices streamServices = new StreamServices();
  DatabaseService databaseService = new DatabaseService();
  String horaParte = "";
  String estadoParte = "";

  @override
  void initState() {
    DateTime selectedDate = new DateTime.now();

    setState(() {
      desdeString = new DateFormat("dd-MM-yyyy").format(selectedDate);
    });

    streamServices.horariosStringTrue.listen((event) {
      setState(() {
        horaParte = event.first;
      });
    });
    streamServices.estadosString.listen((event) {
      setState(() {
        estadoParte = event.first;
      });
    });
    _prepareStorage();
    super.initState();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final pdf = pw.Document();

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

  Directory? rootPath;

  String filePath = "";
  String dirPath = "";
  String? nameFile = "";

  DateTime selectedDate = new DateTime.now();
  DateTime desde = DateTime.now();
  DateTime hasta = DateTime.now();
  String desdeString = "";
  @override
  DateTime _now = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(locale: Locale('es'), context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        desdeString = new DateFormat("dd-MM-yyyy").format(picked);
      });
    }
  }

  Future<void> _prepareStorage() async {
    rootPath = await getApplicationDocumentsDirectory();

    // Create sample directory if not exists

    setState(() {});
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  final pdfs = pw.Document();

  int con = 1;
  List<pw.TableRow> getListTotal(listaFor) {
    List<pw.TableRow> childs = [
      pw.TableRow(children: [
        pw.Text("#"),
        pw.Text("Grado"),
        pw.Text("Nombre y apellidos"),
        pw.Text("Estado"),
        pw.Text("Nota"),
        pw.Text("Fecha inicio"),
        pw.Text("Fecha fin"),
        pw.Text("Hora"),
        pw.Text("Tarea"),
      ])
    ];
    print(listaFor.length);
    for (var i = 0; i < listaFor.length; i++) {
      childs.add(pw.TableRow(children: [
        pw.Text(con.toString()),
        pw.Text(listaFor[i]["rango"].toString()),
        pw.Text(listaFor[i]["nombres"].toString() + " " + listaFor[i]["apellidos"].toString()),
        pw.Text(listaFor[i]["estado"].toString()),
        pw.Text(listaFor[i]["nota"].toString()),
        pw.Text(listaFor[i]["desde"].toString()),
        pw.Text(listaFor[i]["hasta"].toString()),
        pw.Text(listaFor[i]["hora_registro"].toString()),
        pw.Text(listaFor[i]["seleccion"].toString()),
      ]));
      con++;
    }

    return childs;
  }

  List<pw.Widget> _retornarFilas(byteListes, byteList) {
    con = 1;
    List<pw.Widget> lis = [];
    List<List<dynamic>> listaARR = [];
    List<dynamic> listaNueva = [];
    int contadorLista = 0;
    List<dynamic> listaTotalOrder = filtrarLista(listaTotal);
    for (var i = 0; i < listaTotalOrder.length; i++) {
      if (i <= 10) {
        listaNueva.add(listaTotalOrder[i]);
      } else {
        if (i == 11) {
          listaARR.add(listaNueva);
          listaNueva = [];
          listaNueva.add(listaTotalOrder[i]);
        } else {
          if (contadorLista <= 22) {
            listaNueva.add(listaTotalOrder[i]);
            contadorLista += 1;
          } else {
            listaARR.add(listaNueva);
            contadorLista = 0;
            listaNueva = [];
            listaNueva.add(listaTotalOrder[i]);
          }
        }
      }
    }
    listaARR.add(listaNueva);
    print("LISTA: " + listaARR.length.toString());

    for (var i = 0; i < listaARR.length; i++) {
      if (i == 0) {
        lis.add(pw.Table(border: pw.TableBorder.all(), children: getListTotal(listaARR[i])));
      } else {
        lis.add(pw.Wrap(children: [header(byteListes, byteList), pw.SizedBox(height: 24), pw.Table(border: pw.TableBorder.all(), children: getListTotal(listaARR[i]))]));
      }
    }
    return lis;
  }

  pw.Row header(byteListes, byteList) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
      pw.Container(
        width: 100,
        height: 100,
        margin: pw.EdgeInsets.only(right: 12, bottom: 24),
        child: pw.Image(
            pw.MemoryImage(
              byteListes,
            ),
            fit: pw.BoxFit.fitHeight),
      ),
      pw.Column(
        children: [pw.Text("EJERCITO ECUATORIANO", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)), pw.Text('BATALL??N DE SELVA Nro. 63 "GUALAQUIZA"', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text("SISTEMA DE GESTI??N DE REGISTRO DE PARTES", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))],
      ),
      pw.Container(
        width: 100,
        height: 100,
        margin: pw.EdgeInsets.only(left: 12, bottom: 24),
        child: pw.Image(
            pw.MemoryImage(
              byteList,
            ),
            fit: pw.BoxFit.fitHeight),
      ),
    ]);
  }

  bool generando = false;

  List<pw.TableRow> getList() {
    final pdf = pw.Document();
    List<pw.TableRow> childs = [
      pw.TableRow(children: [
        pw.Text("Actividad"),
        pw.Text("Total"),
      ])
    ];
    for (var i = 0; i < lista.length; i++) {
      childs.add(pw.TableRow(children: [pw.Text(lista[i]["estado"]), pw.Text(lista[i]["contador"].toString())]));
    }
    return childs;
  }

  Future<bool> saveVideo() async {
    setState(() {
      generando = true;
    });
    String path = rootPath!.path;
    final pdf = pw.Document();
    final ByteData bytes = await rootBundle.load('assets/img/logo.png');
    final Uint8List byteList = bytes.buffer.asUint8List();
    final ByteData byteses = await rootBundle.load('assets/img/escudo.png');
    final Uint8List byteListes = byteses.buffer.asUint8List();
    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          build: (pw.Context context) {
            return [
              pw.Column(children: [
                header(byteListes, byteList),
                pw.Text("Datos generales"),
                pw.SizedBox(height: 12),
                pw.Wrap(children: [
                  pw.Table(border: pw.TableBorder.all(), children: getList()),
                ]),
                pw.SizedBox(height: 12),
                pw.Text("Lista detallada"),
                pw.SizedBox(height: 12),
              ]),
              ..._retornarFilas(byteListes, byteList)
            ];
          }),
    );

    Directory? directory;
    if (path.toString() == "null") {
      directory = Directory(rootPath!.path);
    } else {
      directory = Directory(path);
    }

    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";

          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath;
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        String path = directory.path;

        final saveFile = File('$path/$nameFile.pdf');
        await saveFile.writeAsBytes(await pdf.save());

        final snackBar = SnackBar(content: Text('El archivo $nameFile se guardo en la carpeta principal de su dispositivo '));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          generando = false;
        });
        //File saveFile = File(directory.path + "/$fileName");

        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path, isReturnPathOfIOS: true);
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  bool isSwitched = false;

  late Stream<QuerySnapshot<Map<String, dynamic>>> urlSearch = FirebaseFirestore.instance.collection("partes").where("compania", isEqualTo: widget.arguments["compania"]).where("fechaRegistro", isEqualTo: desdeString).snapshots();

  String texto = "Sin filtrar";

  List<dynamic> listaTest = [];
  final StreamController<List<dynamic>> _streamController = StreamController<List<dynamic>>.broadcast();
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("horarios").where("estado", isEqualTo: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                body: Center(
              child: Column(
                children: [Text("Cargando dato"), CircularProgressIndicator()],
              ),
            ));
          }
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
            Map<String, dynamic> data = snapshot.data!.docs[0].data();
            DateTime selectedDate = new DateTime.now();
            String desdeString = new DateFormat("dd-MM-yyyy").format(selectedDate);

            String compania = widget.arguments["compania"];
            dynamic hora = data["hora"];
            return SingleChildScrollView(
                child: Container(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      child: label("Lista de registros", Colors.black, 18),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              _streamController.add(listaTest);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => _BuscarParte(lista: listaTest)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("partes").where("compania", isEqualTo: compania).where("fechaRegistro", isEqualTo: desdeString).where("hora_registro", isEqualTo: hora).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return Scaffold(
                          body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text("Cargando dato"), CircularProgressIndicator()],
                        ),
                      ));
                    }
                    if (snapshot.connectionState == ConnectionState.active) {
                      List<dynamic> list = snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return doc.data();
                      }).toList();
                      List<dynamic> listrep = [];
                      listaTest = filtrarLista(list);

                      _streamController.add(listaTest);
                      for (var i = 0; i < list.length; i++) {
                        if (listrep.length == 0) {
                          list[i]["contador"] = 1;
                          listrep.add(list[i]);
                        } else {
                          List<dynamic> lsi = listrep.where((element) => element["estado"] == list[i]["estado"]).toList();
                          if (!lsi.isEmpty) {
                            int indexUpdate = listrep.indexWhere((element) => element["estado"] == list[i]["estado"]);

                            int numero = listrep[indexUpdate]["contador"];

                            listrep[indexUpdate]["contador"] = numero + 1;
                          } else {
                            list[i]["contador"] = 1;
                            listrep.add(list[i]);
                          }
                        }
                      }
                      //return Text("data");
                      return Container(
                          padding: EdgeInsets.only(left: 56, top: 12),
                          child: Column(children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: listrep.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: InkWell(
                                        onTap: () {
                                          List<dynamic> tempo = listaTest.where((element) => element["estado"] == listrep[index]["estado"]).toList();

                                          _streamController.add(tempo);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  child: label(listrep[index]["estado"], Colors.black, 16),
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: label((listrep[index]["contador"]).toString(), Colors.black, 15),
                                                ),
                                              ],
                                            )
                                          ],
                                        )));
                              },
                            ),
                          ]));
                    }
                    return Center(
                      child: Text("Sin registros"),
                    );
                  },
                ),
                StreamBuilder<List<dynamic>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    List<dynamic>? lt = snapshot.data;
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          dataRowHeight: 80,
                          dataTextStyle: TextStyle(fontSize: 12, color: Colors.black),
                          headingTextStyle: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                          columns: const <DataColumn>[
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('Grado')),
                            DataColumn(label: Text('Apellidos\ny Nombres')),
                            DataColumn(label: Text('Horario\nparte')),
                            DataColumn(label: Text('Observacion')),
                          ],
                          rows: lt!.map((e) {
                            var index = lt.indexOf(e);
                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(e["rango"])),
                              DataCell(SizedBox(
                                width: 100,
                                child: Text(e["nombres"] + "\n" + e["apellidos"]),
                              )),
                              DataCell(Text(e["hora_registro"])),
                              DataCell(
                                Text(e["estado"]),
                              ),
                            ]);
                          }).toList(),
                        ),
                      );
                    }
                    _streamController.add(listaTest);
                    return CircularProgressIndicator();
                  },
                )
              ]),
            ));
          }
          return Scaffold(
              body: Center(
            child: Column(
              children: [Text("Cargando dato"), CircularProgressIndicator()],
            ),
          ));
        },
      ),

      /* otro */
      SingleChildScrollView(
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 12,
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    label("Lista de registros", Colors.black, 18),
                    Row(
                      children: [
                        Text(texto),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            if (value == true) {
                              setState(() {
                                texto = "Aplique filtros";
                              });
                            } else {
                              DateTime selectedDate = new DateTime.now();
                              setState(() {
                                texto = "Sin filtrar";
                                desdeString = new DateFormat("dd-MM-yyyy").format(selectedDate);
                              });
                            }
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.yellow,
                          activeColor: Colors.orangeAccent,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                margin: EdgeInsets.only(left: 24, right: 24),
                child: Text("Seleccione la fecha"),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Seleccionar'),
                    ),
                    Text(desdeString)
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              if (isSwitched)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Text("Seleccione el horario del parte"),
                    ),
                    StreamBuilder<List<String>>(
                      stream: streamServices.horariosString,
                      builder: (context, AsyncSnapshot<List<String>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                          return Container(
                            alignment: Alignment.center,
                            color: Colors.black12,
                            margin: EdgeInsets.only(left: 24, right: 24),
                            child: DropdownButton(
                              isExpanded: true,
                              value: horaParte,
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                              ),
                              underline: Container(
                                width: Medidas.width(100),
                                height: 1,
                                color: Color.fromRGBO(23, 23, 23, 1),
                              ),
                              onChanged: (dynamic? newValue) {
                                setState(() {
                                  horaParte = newValue;
                                });
                              },
                              items: snapshot.data!.map<DropdownMenuItem>((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Text("");
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 24, right: 24),
                      child: Text("Seleccione el estado del parte"),
                    ),
                    StreamBuilder<List<String>>(
                      stream: streamServices.estadosString,
                      builder: (context, AsyncSnapshot<List<String>> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                          List<String>? lisTem = snapshot.data;
                          lisTem!.add("Todos");
                          return Container(
                            alignment: Alignment.center,
                            color: Colors.black12,
                            margin: EdgeInsets.only(left: 24, right: 24),
                            child: DropdownButton(
                              isExpanded: true,
                              value: estadoParte,
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lato",
                              ),
                              underline: Container(
                                width: Medidas.width(100),
                                height: 1,
                                color: Color.fromRGBO(23, 23, 23, 1),
                              ),
                              onChanged: (dynamic? newValue) {
                                if (newValue == "Todos") {
                                  setState(() {
                                    estadoParte = newValue;
                                    urlSearch = FirebaseFirestore.instance.collection("partes").where("compania", isEqualTo: widget.arguments["compania"]).where("hora_registro", isEqualTo: horaParte).where("fechaRegistro", isEqualTo: desdeString).snapshots();
                                  });
                                } else {
                                  setState(() {
                                    estadoParte = newValue;
                                    urlSearch = FirebaseFirestore.instance.collection("partes").where("compania", isEqualTo: widget.arguments["compania"]).where("hora_registro", isEqualTo: horaParte).where("estado", isEqualTo: newValue).where("fechaRegistro", isEqualTo: desdeString).snapshots();
                                  });
                                }
                              },
                              items: lisTem.map<DropdownMenuItem>((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Text("");
                      },
                    ),
                  ],
                ),
              SizedBox(
                height: 16,
              ),
              if (isSwitched)
                StreamBuilder(
                  stream: urlSearch,
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.connectionState == ConnectionState.active) {
                      List<dynamic> list = snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return doc.data();
                      }).toList();
                      List<dynamic> listrep = [];
                      lista = [];

                      for (var i = 0; i < list.length; i++) {
                        if (listrep.length == 0) {
                          listrep.add(list[i]);
                          lista.add(list[i]);
                          list[i]["contador"] = 1;
                        } else {
                          List<dynamic> lsi = listrep.where((element) => element["estado"] == list[i]["estado"]).toList();
                          if (!lsi.isEmpty) {
                            int indexUpdate = listrep.indexWhere((element) => element["estado"] == list[i]["estado"]);
                            int numero = listrep[indexUpdate]["contador"];
                            listrep[indexUpdate]["contador"] = numero + 1;
                          } else {
                            list[i]["contador"] = 1;
                            listrep.add(list[i]);
                            lista.add(list[i]);
                          }
                        }
                      }
                      listaTotal = list;

                      //return Text("data");

                      if (listrep.isEmpty) {
                        return Container(margin: EdgeInsets.only(left: 24, right: 24), child: Text("No se encontraron registros"));
                      } else {
                        return Container(
                            padding: EdgeInsets.only(left: 56, top: 12),
                            child: Column(children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: listrep.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: label(listrep[index]["estado"], Colors.black, 16),
                                              ),
                                              Container(
                                                width: 100,
                                                child: label((listrep[index]["contador"]).toString(), Colors.black, 15),
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                              ),
                            ]));
                      }
                    }
                    return Center(
                      child: Text("Sin registros"),
                    );
                  },
                ),
              if (isSwitched == false)
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("partes").where("compania", isEqualTo: widget.arguments["compania"]).where("fechaRegistro", isEqualTo: desdeString).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.connectionState == ConnectionState.active) {
                      List<dynamic> list = snapshot.data!.docs.map((DocumentSnapshot doc) {
                        return doc.data();
                      }).toList();
                      List<dynamic> listrep = [];
                      lista = [];

                      for (var i = 0; i < list.length; i++) {
                        if (listrep.length == 0) {
                          listrep.add(list[i]);
                          lista.add(list[i]);
                          list[i]["contador"] = 1;
                        } else {
                          List<dynamic> lsi = listrep.where((element) => element["estado"] == list[i]["estado"]).toList();
                          if (!lsi.isEmpty) {
                            int indexUpdate = listrep.indexWhere((element) => element["estado"] == list[i]["estado"]);
                            int numero = listrep[indexUpdate]["contador"];
                            listrep[indexUpdate]["contador"] = numero + 1;
                          } else {
                            list[i]["contador"] = 1;
                            listrep.add(list[i]);
                            lista.add(list[i]);
                          }
                        }
                      }
                      listaTotal = list;

                      //return Text("data");

                      if (listrep.isEmpty) {
                        return Container(margin: EdgeInsets.only(left: 24, right: 24), child: Text("No se encontraron registros"));
                      } else {
                        return Container(
                            padding: EdgeInsets.only(left: 56, top: 12),
                            child: Column(children: [
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: listrep.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: label(listrep[index]["estado"], Colors.black, 16),
                                              ),
                                              Container(
                                                width: 100,
                                                child: label((listrep[index]["contador"]).toString(), Colors.black, 15),
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                              ),
                            ]));
                      }
                    }
                    return Center(
                      child: Text("Sin registros"),
                    );
                  },
                ),
              SizedBox(
                height: 24,
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 24, right: 24),
                    child: textField(
                        hintText: "Nombre del archivo",
                        onChanged: (value) {
                          setState(() {
                            nameFile = value;
                          });
                        }),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    width: Medidas.width(100),
                    margin: EdgeInsets.only(left: 24, right: 24),
                    child: ElevatedButton(
                        onPressed: () async {
                          if (lista.length == 0) {
                            final snackBar = SnackBar(content: Text('No hay registros descargar'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return;
                          }
                          if (nameFile!.length > 0) {
                            saveVideo();
                          } else {
                            final snackBar = SnackBar(content: Text('Debe ingresar el nombre del archivo'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        child: Text("Descargar Reporte")),
                  ),
                ],
              )
            ])),
      ),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("personal").where("compania", isEqualTo: widget.arguments["compania"]).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return Scaffold(
                  body: Center(
                child: Column(
                  children: [Text("Cargando dato"), CircularProgressIndicator()],
                ),
              ));
            }
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
              print(snapshot.data);
              List<Map<String, dynamic>> data = snapshot.data!.docs.map((e) => e.data()).toList();
              List<dynamic> list = snapshot.data!.docs.map((DocumentSnapshot doc) {
                return doc.data();
              }).toList();
              print(data);
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: _RegistroParte(lista: list)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(12),
                    color: Colors.white,
                    child: Text("Lista de personal de la: " + '"' + widget.arguments["compania"].toString() + '"' + " ??? Total = " + data.length.toString()),
                  ),
                ],
              );
            }
            return Scaffold(
                body: Center(
              child: Column(
                children: [Text("Cargando dato"), CircularProgressIndicator()],
              ),
            ));
          }),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    final Widget co = Stack(
      children: [Text("data")],
    );

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Registrar Estados',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black12,
        elevation: 0.0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
        ),
        title: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clase de semana',
                style: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.bold, color: Colors.white),
              ),
              label(widget.arguments["compania"], Colors.white, 10),
              label("Versi??n 1.5", Colors.white, 9),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset(
            'assets/img/logo.png',
            width: 100.0,
            height: 100.0,
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
            label: label("", Color.fromRGBO(218, 0, 55, 1), 10),
            onPressed: () async {
              await context.read<Autentication>().signOut();
              Navigator.pushNamed(context, '/home');
            },
          )
        ],
      ),
      body: Center(
        child: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: Colors.black12, child: _widgetOptions.elementAt(_selectedIndex)),
      ),
    );
  }
}

class _BuscarParte extends StatefulWidget {
  _BuscarParte({Key? key, required this.lista}) : super(key: key);
  List<dynamic> lista = [];
  @override
  _BuscarParteState createState() => _BuscarParteState();
}

class _BuscarParteState extends State<_BuscarParte> {
  late List<dynamic> lista = widget.lista.sublist(0, 10);
  late List<dynamic> listaTemporal = widget.lista;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.black12,
            elevation: 0.0,
            toolbarHeight: 70,
            flexibleSpace: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.redAccent], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
            ),
            title: Container(
              height: 36,
              child: TextField(
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusColor: Colors.white,
                    hintStyle: TextStyle(fontWeight: FontWeight.w300, color: Colors.white)),
                onChanged: (value) {
                  if (value.toString().length == 0) {
                    setState(() {
                      lista = listaTemporal.sublist(0, 10);
                    });
                  } else {
                    List<dynamic> listaTemp = listaTemporal.where((element) => element["apellidos"].toString().toLowerCase().contains(value.toString().toLowerCase())).toList();
                    if (listaTemp.length > 10) {
                      setState(() {
                        lista = listaTemp.sublist(0, 10);
                        ;
                      });
                    } else {
                      setState(() {
                        lista = listaTemp;
                        ;
                      });
                    }
                  }
                },
              ),
            )),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowHeight: 80,
                dataTextStyle: TextStyle(fontSize: 12, color: Colors.black),
                headingTextStyle: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                columns: <DataColumn>[
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Grado')),
                  DataColumn(label: Text('Apellidos\ny Nombres')),
                  DataColumn(label: Text('Horario\nparte')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Observaci??n')),
                  DataColumn(label: Text('Desde')),
                  DataColumn(label: Text('Hasta')),
                ],
                rows: lista.map((e) {
                  var index = lista.indexOf(e);
                  return DataRow(cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(e["rango"])),
                    DataCell(SizedBox(
                      width: 100,
                      child: Text(e["nombres"] + "\n" + e["apellidos"]),
                    )),
                    DataCell(Text(e["hora_registro"])),
                    DataCell(
                      Text(e["estado"]),
                    ),
                    DataCell(
                      Text(e["nota"] ?? ""),
                    ),
                    DataCell(
                      Text(e["desde"] ?? ""),
                    ),
                    DataCell(
                      Text(e["hasta"] ?? ""),
                    ),
                  ]);
                }).toList(),
              ),
            )));
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
  );
}

Widget textField({String? hintText, IconData? icono, bool obscureText = false, bool passwordVisible = false, bool pass = false, Function(String)? onChanged, void Function()? onPress, dynamic validator, TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black12,
      borderRadius: BorderRadius.circular(24),
    ),
    child: TextFormField(
      validator: validator,
      keyboardType: textInputTipe,
      obscureText: obscureText == false
          ? false
          : passwordVisible == true
              ? true
              : false,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Lato", fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
          suffixIcon: pass == true
              ? IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: onPress,
                )
              : Text(""),
          hintText: hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          labelText: hintText,
          prefixIcon: Icon(
            icono,
            color: Colors.black,
          ),
          border: InputBorder.none),
    ),
  );
}

Widget CardGrid(String title, dynamic onTap) {
  return InkWell(
    child: Card(
        color: Color.fromRGBO(230, 230, 230, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: label(title, Colors.black, 16),
            ),
          ],
        )),
    onTap: onTap,
  );
}

class _RegistroParte extends StatefulWidget {
  _RegistroParte({Key? key, required this.lista}) : super(key: key);
  List<dynamic> lista = [];
  @override
  _RegistroParteState createState() => _RegistroParteState();
}

List<dynamic> filtrarListaGrado(List<dynamic> lista) {
  List<String> listaOrden = [
    "GRAE",
    "GRAD",
    "GRAB",
    "CRNL",
    "TCRN",
    "MAYO",
    "CAPT",
    "TNTE",
    "SUBT",
    "SUBM",
    "SUBP",
    "SUBS",
    "SGOP",
    "SGOS",
    "CBOP",
    "CBOS",
    "SLDO",
  ];
  List<dynamic> listaFilter = [];
  for (var item in listaOrden) {
    for (var itemParte in lista) {
      if (itemParte["grado"] == item) {
        listaFilter.add(itemParte);
      }
    }
  }
  return listaFilter;
}

class _RegistroParteState extends State<_RegistroParte> {
  late List<dynamic> listaTemporal = filtrarListaGrado(widget.lista);
  StreamServices streamServices = new StreamServices();
  String horaParte = "";
  @override
  void initState() {
    streamServices.horariosStringTrue.listen((event) {
      setState(() {
        horaParte = event.first;
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 45, bottom: 200),
      itemCount: listaTemporal.length,
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
                        listaTemporal[index].nombres + "?",
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
              key: Key(listaTemporal[index]["nombres"]),
              // Tambi??n debemos proporcionar una funci??n que diga a nuestra aplicaci??n
              // qu?? hacer despu??s de que un elemento ha sido eliminado.
              onDismissed: (direction) async {
                // Remueve el elemento de nuestro data source.

                final snackBar = SnackBar(content: Text('Se elimino el usuario correctamente'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: ListTile(
                  title: Text(
                listaTemporal[index]["grado"] + " ??? " + listaTemporal[index]["nombres"] + " " + listaTemporal[index]["apellidos"],
                style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
              ))),
          onTap: () {
            late UserModel userModel = new UserModel(uid: "");
            userModel = new UserModel.fromUserModel(uid: listaTemporal[index]["uid"], hasta: listaTemporal[index]["hasta"] ?? "", token: listaTemporal[index]["token"] ?? "", apellidos: listaTemporal[index]["apellidos"], grado: listaTemporal[index]["grado"], nombres: listaTemporal[index]["nombres"], batallon: listaTemporal[index]["batallon"], compania: listaTemporal[index]["compania"], cedula: listaTemporal[index]["cedula"], email: listaTemporal[index]["email"], typeUser: "typeUser", estado: listaTemporal[index]["estado"]);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return AsignarParte(
                  usuario: userModel,
                  horaParte: horaParte,
                );
              }),
            );
          },
        );
      },
    );
  }
}
