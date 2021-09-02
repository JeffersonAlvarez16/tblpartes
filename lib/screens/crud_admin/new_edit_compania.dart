import 'package:flutter/material.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/compania.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class NewEditCompania extends StatefulWidget {
  final Compania compania;
  NewEditCompania({Key? key, required this.compania}) : super(key: key);

  @override
  _NewEditCompaniaState createState() => _NewEditCompaniaState();
}

class _NewEditCompaniaState extends State<NewEditCompania> {
  final DatabaseService databaseService = new DatabaseService();
  String nombre = "";
  bool update = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.compania.uid.isNotEmpty) {
      setState(() {
        this.nombre = widget.compania.nombre;
        this.update = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.nombre) : ButonUpdate(_formKey, databaseService, context, nombre, widget.compania.uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(237, 237, 237, 1),
        title: Text(
          "Datos de la compañia",
          style: TextStyle(color: Colors.black, fontFamily: "Lato", fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
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
            ],
          ),
        ),
      )),
    );
  }
}

Widget ButonGuardar(_formKey, databaseService, context, nombre) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        var uid = Uuid().v4();
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombre"] = nombre;
        data["uid"] = uid;
        if (_formKey.currentState!.validate()) {
          await databaseService.createCompania(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, nombre, uid) {
  return TextButton(
      child: Text(
        "Actualizar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["nombre"] = nombre;
        data["uid"] = uid;
        if (_formKey.currentState!.validate()) {
          await databaseService.updateCompania(uid, data);
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
