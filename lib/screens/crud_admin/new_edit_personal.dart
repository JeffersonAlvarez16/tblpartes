import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class NewEditPersonal extends StatefulWidget {
  final UserModel userModel;
  NewEditPersonal({Key? key, required this.userModel}) : super(key: key);

  @override
  _NewEditPersonalState createState() => _NewEditPersonalState();
}

class _NewEditPersonalState extends State<NewEditPersonal> {
  final DatabaseService databaseService = new DatabaseService();

  static const List<String> perfilesUsuarios = <String>[
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

  String grado = "Soldado";
  String apellidos = "";
  String nombres = "";
  String batallon = "as";
  String compania = "as";
  String email = "";
  String password = "";
  String typeUser = "";
  String cedula = "";

  bool update = false;

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.userModel.uid.isNotEmpty) {
      setState(() {
        this.nombres = widget.userModel.nombres;
        this.apellidos = widget.userModel.apellidos;
        this.grado = widget.userModel.grado;
        this.compania = widget.userModel.compania;
        this.batallon = widget.userModel.batallon;
        this.email = widget.userModel.email;
        this.cedula = widget.userModel.cedula;
        this.update = true;
      });
    } else {
      databaseService.initbatallon().then((value) => batallon = value);
      databaseService.initcompania().then((value) => compania = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.grado, this.apellidos, this.nombres, this.batallon, this.compania, this.email, this.cedula, this.password) : ButonUpdate(_formKey, databaseService, context, this.grado, this.apellidos, this.nombres, this.batallon, this.compania, this.email, widget.userModel.uid, this.cedula),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black12,
          elevation: 0.0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          title: Text(
            "Datos del personal",
            style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black12,
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    color: Colors.black12,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(0),
                    child: DropdownButton(
                      isExpanded: true,
                      value: grado,
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
                        this.setState(() {
                          this.grado = newValue!;
                        });
                      },
                      items: perfilesUsuarios.map<DropdownMenuItem>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  textField(
                      hintText: 'Apellidos',
                      icono: Icons.lock_open_outlined,
                      obscureText: false,
                      valor: apellidos,
                      validator: (value) => value.isEmpty ? "Ingrese los apellidos del personal" : null,
                      onChanged: (value) {
                        setState(() {
                          apellidos = value;
                        });
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  textField(
                      hintText: 'Nombres',
                      icono: Icons.lock_open_outlined,
                      obscureText: false,
                      valor: nombres,
                      validator: (value) => value.isEmpty ? "Ingrese los nombres del personal" : null,
                      onChanged: (value) {
                        setState(() {
                          nombres = value;
                        });
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  textField(
                      hintText: 'Cedula',
                      icono: Icons.lock_open_outlined,
                      obscureText: false,
                      valor: cedula,
                      validator: (value) => value.isEmpty ? "Ingrese la cedula" : null,
                      onChanged: (value) {
                        setState(() {
                          cedula = value;
                        });
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("batallones").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List lista = snapshot.data!.docs;

                        if (lista.length > 0) {
                          return Container(
                              alignment: Alignment.center,
                              color: Colors.black12,
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(0),
                              child: DropdownButton(
                                isExpanded: true,
                                value: batallon,
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
                                    this.batallon = newValue!;
                                  });
                                },
                                items: snapshot.data!.docs.map<DropdownMenuItem>((dynamic value) {
                                  return DropdownMenuItem(
                                    value: value["nombre"],
                                    child: Text(value["nombre"]),
                                  );
                                }).toList(),
                              ));
                        } else {
                          setState(() {
                            this.batallon = "";
                          });
                          return Text("dsa");
                        }
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("companias").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List lista = snapshot.data!.docs;
                        if (lista.length > 0) {
                          return Container(
                            alignment: Alignment.center,
                            color: Colors.black12,
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.all(0),
                            child: DropdownButton(
                              isExpanded: true,
                              value: compania,
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
                                  this.compania = newValue!;
                                });
                              },
                              items: snapshot.data!.docs.reversed.map<DropdownMenuItem>((dynamic value) {
                                return DropdownMenuItem(
                                  value: value["nombre"],
                                  child: Text(value["nombre"]),
                                );
                              }).toList(),
                            ),
                          );
                        } else {
                          setState(() {
                            this.batallon = "";
                          });
                          return Text("dsa");
                        }
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  textField(
                      hintText: 'Correo Electrónico',
                      icono: Icons.lock_open_outlined,
                      obscureText: false,
                      valor: email,
                      validator: (value) => value.isEmpty ? "Ingrese el correo del personal" : null,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      }),
                  SizedBox(
                    height: 8,
                  ),
                  this.update == false
                      ? textField(
                          hintText: 'Contraseña',
                          icono: Icons.lock_open_outlined,
                          obscureText: false,
                          valor: password,
                          validator: (value) => value.isEmpty ? "Ingrese la contraseña" : null,
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          })
                      : SizedBox(
                          height: 1,
                        ),
                  SizedBox(
                    height: 48,
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "Lato"),
  );
}

Widget ButonGuardar(_formKey, databaseService, context, grado, apellidos, nombres, batallon, compania, email, cedula, password) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        var uid = Uuid().v4();

        final Map<String, dynamic> data = Map<String, dynamic>();
        data["uid"] = uid;
        data["grado"] = grado;
        data["apellidos"] = apellidos;
        data["nombres"] = nombres;
        data["batallon"] = batallon;
        data["compania"] = compania;
        data["email"] = email;
        data["typeUser"] = "personal";
        data["cedula"] = cedula;
        data["password"] = password;
        if (_formKey.currentState!.validate()) {
          await databaseService.createPersonal(uid, data);
          //await enviarEmail(email, password, nombres);
          Navigator.pop(context);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, grado, apellidos, nombres, batallon, compania, email, uid, cedula) {
  return TextButton(
      child: Text(
        "Actualizar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["uid"] = uid;
        data["grado"] = grado;
        data["apellidos"] = apellidos;
        data["nombres"] = nombres;
        data["batallon"] = batallon;
        data["compania"] = compania;
        data["email"] = email;
        data["cedula"] = cedula;

        if (_formKey.currentState!.validate()) {
          await databaseService.updatePersonal(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget textField({String? hintText, IconData? icono, String? valor, bool obscureText = false, Function(String)? onChanged, dynamic validator, TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black12,
    ),
    child: TextFormField(
      validator: validator,
      initialValue: valor,
      keyboardType: textInputTipe,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Lato", fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        labelText: hintText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(23, 23, 23, 1)),
        ),
        contentPadding: EdgeInsets.all(8),
        hintText: hintText,
        hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "Lato"),
      ),
    ),
  );
}

enviarEmail(email_send, password, nombres) async {
  final Email email = Email(
    body: 'Saludos $nombres. \n \n Sus datos de acceso a la aplicación del batallón son los siguientes: \n \n Correo Electrónico: $email_send \n Contraseña: $password',
    subject: 'Contraseña de acceso a la aplicación del Batallón',
    recipients: ['$email_send'],
    isHTML: false,
  );

  try {
    return await FlutterEmailSender.send(email);
  } catch (e) {
    return null;
  }
}
