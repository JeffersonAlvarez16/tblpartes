import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminReportes extends StatefulWidget {
  AdminReportes({Key? key}) : super(key: key);

  @override
  _AdminReportesState createState() => _AdminReportesState();
}

class _AdminReportesState extends State<AdminReportes> {
  List<dynamic> lista = [];
  List<dynamic> listaTotal = [];
  StreamServices streamServices = new StreamServices();
  DatabaseService databaseService = new DatabaseService();
  String horaParte = "";
  String estadoParte = "";
  late Stream<QuerySnapshot<Map<String, dynamic>>> urlSeacrh;

  @override
  void initState() {
    DateTime selectedDate = new DateTime.now();

    setState(() {
      desdeString = new DateFormat("dd-MM-yyyy").format(selectedDate);
      urlSeacrh = FirebaseFirestore.instance.collection("partes").where("hora_registro", isEqualTo: horaParte).where("estado", isEqualTo: estadoParte).where("fechaRegistro", isEqualTo: desdeString).snapshots();
    });
    streamServices.horariosString.listen((event) {
      setState(() {
        horaParte = event.first;
      });
    });
    streamServices.companiaStringString.listen((event) {
      setState(() {
        companiaselect = event.first;
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

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final pdf = pw.Document();

  final Dio dio = Dio();
  bool loading = false;
  double progress = 0;

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

  Directory? rootPath;

  String filePath = "";
  String dirPath = "";
  String? nameFile = "";
  bool generando = false;
  DateTime selectedDate = new DateTime.now();
  DateTime desde = DateTime.now();
  DateTime hasta = DateTime.now();
  String desdeString = "";
  String companiaselect = "";
  @override
  DateTime _now = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(locale: Locale('es'), context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        desdeString = new DateFormat("dd-MM-yyyy").format(picked);
        urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).snapshots();
      });
    }
  }

  Future<void> _prepareStorage() async {
    rootPath = await getApplicationDocumentsDirectory();

    // Create sample directory if not exists

    setState(() {});
  }

  final pdfs = pw.Document();

  List<pw.TableRow> getList() {
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
    print("valor total:" + listaTotal.length.toString());
    print("valor ind" + lista.length.toString());
    for (var i = 0; i < listaTotal.length; i++) {
      if (i <= 10) {
        listaNueva.add(listaTotal[i]);
      } else {
        if (i == 11) {
          listaARR.add(listaNueva);
          listaNueva = [];
          listaNueva.add(listaTotal[i]);
        } else {
          if (contadorLista <= 22) {
            listaNueva.add(listaTotal[i]);
            contadorLista += 1;
          } else {
            listaARR.add(listaNueva);
            contadorLista = 0;
            listaNueva = [];
            listaNueva.add(listaTotal[i]);
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
        children: [pw.Text("EJERCITO ECUATORIANO", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)), pw.Text('BATALLÓN DE SELVA Nro. 63 "GUALAQUIZA"', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text("SISTEMA DE GESTIÓN DE REGISTRO DE PARTES", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))],
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

  String texto = "Sin filtrar";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black12,
          elevation: 0.0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          title: Text("Gestión de reportes", style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold)),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black12,
          child: SingleChildScrollView(
              child: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            DateTime selectedDate = new DateTime.now();
                            String desdeStrings = new DateFormat("dd-MM-yyyy").format(selectedDate);
                            print(desdeStrings);
                            setState(() {
                              texto = "Aplique filtros";
                              urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeStrings).snapshots();
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
                    height: 24,
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
                        List<String>? lisTem = snapshot.data;
                        lisTem!.add("Todos");
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
                              if (newValue == "Todos" && estadoParte == "Todos" && companiaselect == "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && estadoParte == "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).snapshots();
                                });
                                return;
                              }
                              if (companiaselect == "Todos" && estadoParte == "Todos") {
                                print(newValue);
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("hora_registro", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && companiaselect == "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: estadoParte).snapshots();
                                });
                                return;
                              }
                              if (companiaselect == "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: estadoParte).where("hora_registro", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }
                              if (estadoParte == "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("hora_registro", isEqualTo: newValue).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && estadoParte != "Todos" && companiaselect != "Todos") {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).where("estado", isEqualTo: estadoParte).snapshots();
                                });
                              } else {
                                setState(() {
                                  horaParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("hora_registro", isEqualTo: newValue).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).where("estado", isEqualTo: estadoParte).snapshots();
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
                  SizedBox(
                    height: 24,
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
                              if (newValue == "Todos" && horaParte == "Todos" && companiaselect == "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && horaParte == "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).snapshots();
                                });
                                return;
                              }
                              if (companiaselect == "Todos" && horaParte == "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && companiaselect == "Todos") {
                                print("entro busqueda");
                                print(newValue);
                                print(companiaselect);
                                print(horaParte);

                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                                return;
                              }
                              if (companiaselect == "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: newValue).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                                return;
                              }
                              if (horaParte == "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("estado", isEqualTo: newValue).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && horaParte != "Todos" && companiaselect != "Todos") {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                              } else {
                                setState(() {
                                  estadoParte = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("estado", isEqualTo: newValue).where("hora_registro", isEqualTo: horaParte).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: companiaselect).snapshots();
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
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 24, right: 24),
                    child: Text("Seleccione la compañia"),
                  ),
                  StreamBuilder<List<String>>(
                    stream: streamServices.companiaStringString,
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
                            value: companiaselect,
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
                              if (newValue == "Todos" && horaParte == "Todos" && estadoParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && horaParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: estadoParte).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos" && estadoParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                                return;
                              }
                              if (horaParte == "Todos" && estadoParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }

                              if (horaParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("estado", isEqualTo: estadoParte).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }
                              if (estadoParte == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("hora_registro", isEqualTo: horaParte).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: newValue).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: estadoParte).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                                return;
                              }
                              if (newValue == "Todos") {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).where("estado", isEqualTo: estadoParte).where("hora_registro", isEqualTo: horaParte).snapshots();
                                });
                              } else {
                                setState(() {
                                  companiaselect = newValue;
                                  urlSeacrh = FirebaseFirestore.instance.collection("partes").where("estado", isEqualTo: estadoParte).where("hora_registro", isEqualTo: horaParte).where("fechaRegistro", isEqualTo: desdeString).where("compania", isEqualTo: newValue).snapshots();
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
                stream: urlSeacrh,
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
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listrep.length,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: EdgeInsets.only(top: 10),
                              margin: EdgeInsets.only(left: 24),
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
                      );
                    }
                  }
                  return Center(
                    child: Text("Sin registros"),
                  );
                },
              ),
            if (isSwitched == false)
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("partes").where("fechaRegistro", isEqualTo: desdeString).snapshots(),
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
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listrep.length,
                        itemBuilder: (context, index) {
                          return Container(
                              padding: EdgeInsets.only(top: 10),
                              margin: EdgeInsets.only(left: 24),
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
                      );
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
            ),
          ])),
        ));
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
