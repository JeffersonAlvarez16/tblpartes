import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:tblpartes/models/horarios.dart';
import 'package:tblpartes/services/database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewEditHorarios extends StatefulWidget {
  final Horarios horario;
  NewEditHorarios({Key? key, required this.horario}) : super(key: key);

  @override
  _NewEditHorariosState createState() => _NewEditHorariosState();
}

class _NewEditHorariosState extends State<NewEditHorarios> {
  final DatabaseService databaseService = new DatabaseService();
  String hora = "";
  bool update = false;
  final _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  late double _height;
  late double _width;

  late String _setTime, _setDate;

  late String _hour, _minute, _time;

  late String dateTime;
  TextEditingController _timeController = TextEditingController();

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute), [hh, ':', nn, " ", am]).toString();
        hora = formatDate(DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute), [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.horario.uid.isNotEmpty) {
      setState(() {
        this.hora = widget.horario.hora;
        this.update = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: update == false ? ButonGuardar(_formKey, databaseService, context, this.hora) : ButonUpdate(_formKey, databaseService, context, hora, widget.horario.uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(237, 237, 237, 1),
        title: Text(
          "Datos de los horarios",
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
              InkWell(
                onTap: () {
                  selectTime(context);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.black12),
                  child: TextFormField(
                    validator: (value) => value!.isEmpty || value == null ? "Ingrese un horario" : null,
                    style: TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: "OpenSans", fontStyle: FontStyle.normal),
                    textAlign: TextAlign.center,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: _timeController,
                    decoration: InputDecoration(
                        labelText: "Seleccionar el horario",
                        hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
                        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14, fontFamily: "OpenSans"),
                        disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                        // labelText: 'Time',
                        contentPadding: EdgeInsets.all(5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

Widget ButonGuardar(_formKey, databaseService, context, hora) {
  return TextButton(
      child: Text(
        "Guardar Datos",
        style: TextStyle(color: Colors.white, fontFamily: "OpenSans", fontSize: 14),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
      onPressed: () async {
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);
        var uid = Uuid().v4();
        final Map<String, dynamic> data = Map<String, dynamic>();
        data["hora"] = hora;
        data["uid"] = uid;
        data["createAt"] = date;

        if (hora.toString().isNotEmpty) {
          int res = await validateExistencia(databaseService, hora);
          if (res == 1) {
            final snackBar = SnackBar(content: Text('Ya existe un horario con esta hora registrado'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            await databaseService.createHoraroios(uid, data);
            Navigator.pop(context);
          }
        } else {
          final snackBar = SnackBar(content: Text('Debe seleecionar un horario'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
}

Widget ButonUpdate(_formKey, databaseService, context, nombre, uid) {
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
        if (_formKey.currentState!.validate()) {
          await databaseService.updateBatallon(uid, data);
          Navigator.pop(context);
        }
      });
}

validateExistencia(DatabaseService databaseService, String hora) async {
  QuerySnapshot result = await databaseService.existeHorario(hora);

  return result.size;
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
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "OpenSans", fontStyle: FontStyle.normal),
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
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontFamily: "OpenSans"),
        hintStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontFamily: "OpenSans"),
      ),
    ),
  );
}
