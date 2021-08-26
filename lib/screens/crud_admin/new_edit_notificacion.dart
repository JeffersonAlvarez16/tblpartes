import 'package:flutter/material.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/notificaciones.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';

class NewEditNotificacion extends StatefulWidget {
  final Notificaciones notificaciones;
  NewEditNotificacion({Key? key, required this.notificaciones}) : super(key: key);

  @override
  _NewEditNotificacionState createState() => _NewEditNotificacionState();
}

class _NewEditNotificacionState extends State<NewEditNotificacion> {
  final DatabaseService databaseService = new DatabaseService();
  String name = "";
  String subject = "";
  bool update = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.notificaciones.uid.isNotEmpty) {
      setState(() {
        this.name = widget.notificaciones.name;
        this.subject = widget.notificaciones.subject;
        this.update = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.name, this.subject) : ButonUpdate(_formKey, databaseService, context, name, this.subject, widget.notificaciones.uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(237, 237, 237, 1),
        title: Text(
          "Datos de la notificación",
          style: TextStyle(color: Colors.black, fontFamily: "OpenSans", fontWeight: FontWeight.bold),
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
                  maxlines: 1,
                  hintText: 'Titutlo',
                  icono: Icons.lock_open_outlined,
                  obscureText: false,
                  valor: name,
                  validator: (value) => value.isEmpty ? "Ingrese titulo de la notificación" : null,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  }),
              SizedBox(
                height: 16,
              ),
              textField(
                  maxlines: 8,
                  hintText: 'Mensaje',
                  icono: Icons.lock_open_outlined,
                  obscureText: false,
                  valor: subject,
                  validator: (value) => value.isEmpty ? "Ingrese el mensaje de la notificación" : null,
                  onChanged: (value) {
                    setState(() {
                      subject = value;
                    });
                  }),
            ],
          ),
        ),
      )),
    );
  }
}

Widget ButonGuardar(_formKey, databaseService, context, name, subject) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        var uid = Uuid().v4();
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["name"] = name;
        data["subject"] = subject;
        data["uid"] = uid;
        if (_formKey.currentState!.validate()) {
          await databaseService.crearNotificacion(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, name, subject, uid) {
  return TextButton(
      child: Text(
        "Actualizar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["name"] = name;
        data["subject"] = subject;
        data["uid"] = uid;
        if (_formKey.currentState!.validate()) {
          await databaseService.updateBatallon(uid, data);
          Navigator.pop(context);
        }
      });
}

Widget textField({String? hintText, IconData? icono, String? valor, bool obscureText = false, Function(String)? onChanged, dynamic validator, TextInputType textInputTipe = TextInputType.text, int? maxlines}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black12,
    ),
    child: TextFormField(
      maxLines: maxlines,
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
        hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
      ),
    ),
  );
}
