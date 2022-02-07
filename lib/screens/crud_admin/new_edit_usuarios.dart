import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tblpartes/models/usuarios.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class NewEditUsuarios extends StatefulWidget {
  final Usuarios usuario;
  NewEditUsuarios({Key? key, required this.usuario}) : super(key: key);

  @override
  _NewEditUsuariosState createState() => _NewEditUsuariosState();
}

class _NewEditUsuariosState extends State<NewEditUsuarios> {
  final DatabaseService databaseService = new DatabaseService();
  String uid_user = "";
  String type_user = "Comandante";
  String nombres = "";
  String nombresTemporal = "";
  String uid = "";

  bool update = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.usuario.uid.isNotEmpty) {
      setState(() {
        this.uid_user = widget.usuario.uid_user;
        this.type_user = widget.usuario.type_user;
        this.nombres = widget.usuario.nombres;
        this.nombresTemporal = widget.usuario.nombres;
        this.compania = widget.usuario.compania;
        this.uid = widget.usuario.uid;
        this.update = true;
      });
    }
  }

  String compania = "No ha seleccionado un usuario";

  static const List<String> perfilesUsuarios = <String>[
    'Clase de Semana',
    'Oficial de Semana',
    'Comandante de Compañía',
    'Sub comandante',
    'Comandante',
  ];

  List<dynamic> listaRes = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.nombres, this.uid_user, this.type_user, compania) : ButonUpdate(_formKey, databaseService, context, nombres, widget.usuario.uid, uid_user, type_user, compania),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black12,
          elevation: 0.0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          title: Text(
            "Datos del usuario",
            style: TextStyle(color: Colors.black, fontFamily: "Lato", fontWeight: FontWeight.bold),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seleccione el tipo de usuario",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: Colors.black12,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(0),
                    child: DropdownButton(
                      isExpanded: true,
                      value: type_user,
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
                          this.type_user = newValue!;
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
                    height: 16,
                  ),
                  Text(
                    "Compañia a la que pertenece el usuario",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Text(
                    compania,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 15),
                  ),
                  Divider(),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Busque el personal para asignar un usuario",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("personal").snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        List<String> lista = [];
                        lista = [];
                        for (dynamic element in snapshot.data!.docs) {
                          lista.add(element.data()["nombres"].toString().toLowerCase() + ", " + element.data()["apellidos"].toString().toLowerCase());
                          listaRes.add(element.data());
                        }
                        return Autocomplete(
                          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                            textEditingController.text = nombresTemporal; // You can use the next snip of code if you dont want the initial text to come when you use setState((){});

                            return TextFormField(
                              controller: textEditingController, //uses fieldViewBuilder TextEditingController
                              focusNode: focusNode,
                            );
                          },
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }

                            return lista.where((String option) {
                              return option.contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            List<String> reasu = selection.split(",");
                            dynamic lis = listaRes.where((element) => element["apellidos"].toString().toLowerCase().trim() == reasu[1].toString().trim()).toList();
                            print(lis);
                            for (dynamic element in snapshot.data!.docs) {
                              String nombreCompleto = element.data()["nombres"].toString().toLowerCase() + ", " + element.data()["apellidos"].toString().toLowerCase();
                              if (nombreCompleto.contains(selection)) {
                                setState(() {
                                  uid_user = element.data()["uid"];
                                  compania = element.data()["compania"];
                                });
                              }
                            }
                            setState(() {
                              this.nombres = selection;
                              this.nombresTemporal = selection;
                              compania = lis[0]["compania"];
                            });
                            FocusScope.of(context).requestFocus(null);
                          },
                        );
                      }),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

Widget ButonGuardar(_formKey, databaseService, context, nombre, uid_user, type_user, compania) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombres"] = nombre;
        data["uid"] = uid_user;
        data["uid_user"] = uid_user;
        data["type_user"] = type_user;
        data["compania"] = compania;
        print(type_user);
        print(compania);

        /*    'Clase de Semana',
    'Oficial de Semana',
    'Comandante de Compañía',
    'Sub comandante',
    'Comandante', */
        QuerySnapshot resultuser = await databaseService.existeUsuarioUid(uid_user);
        if (resultuser.size == 0) {
          print("entro");
          if (type_user == "Oficial de Semana") {
            if (_formKey.currentState!.validate()) {
              await databaseService.createUsuarios(uid_user, data);
              Navigator.pop(context);
            }
          }
          if (type_user == "Comandante" || type_user == "Sub comandante") {
            QuerySnapshot result = await databaseService.existeUsuario(type_user);
            print(result);
            if (result.size == 0) {
              if (_formKey.currentState!.validate()) {
                await databaseService.createUsuarios(uid_user, data);
                Navigator.pop(context);
              }
            } else {
              final snackBar = SnackBar(content: Text('Ya existe un usuario $type_user'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }

          if (type_user == "Clase de Semana" || type_user == "Comandante de Compañía") {
            QuerySnapshot result = await databaseService.existeUsuarioCompania(type_user, compania);
            if (result.size == 0) {
              if (_formKey.currentState!.validate()) {
                await databaseService.createUsuarios(uid_user, data);
                Navigator.pop(context);
              }
            } else {
              final snackBar = SnackBar(content: Text('Ya existe un usuario $type_user en la compañia $compania'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
        } else {
          final snackBar = SnackBar(content: Text('Este usuarios ya esta registrado como $type_user'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, nombre, uid, uid_user, type_user, compania) {
  return TextButton(
      child: Text(
        "Actualizar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombres"] = nombre;
        data["uid"] = uid_user;
        data["uid_user"] = uid_user;
        data["type_user"] = type_user;
        data["compania"] = compania;
        if (_formKey.currentState!.validate()) {
          await databaseService.updateUsuarios(uid, data);
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
