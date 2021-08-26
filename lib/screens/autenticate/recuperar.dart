import 'package:flutter/material.dart';
import 'package:tblpartes/screens/autenticate/sign_in.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_personal.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/database.dart';

class Recuperar extends StatefulWidget {
  Recuperar({Key? key}) : super(key: key);

  @override
  _RecuperarState createState() => _RecuperarState();
}

class _RecuperarState extends State<Recuperar> {
  final DatabaseService databaseService = new DatabaseService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(23, 23, 23, 1),
        body: Container(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                label("Restablecer contraseña", Colors.white, 24),
                SizedBox(
                  height: Medidas.heigth(8),
                ),
                textField(
                    hintText: 'Cedula',
                    icono: Icons.lock_open_outlined,
                    obscureText: true,
                    validator: (value) =>
                        value.isEmpty ? "Ingrese la cedula" : null,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    }),
                label("Se enviara un correo de recuperación de contraseña",
                    Colors.white, 12),
                SizedBox(
                  height: Medidas.heigth(8),
                ),
                Container(
                  width: Medidas.width(100),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(218, 0, 55, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: TextButton(
                    child: Text(
                      "Recuperar contraseña",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        var correo = await databaseService.getCorreo(email);

                        if (correo == "null") {
                          final snackBar =
                              SnackBar(content: Text('No existe este usuario'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          try {
                            await databaseService.resetPassword(correo);
                            final snackBar = SnackBar(
                                content: Text(
                                    'Se envio el correo de recuperación a: ' +
                                        correo));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } catch (e) {
                            final snackBar = SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  'Error al enviar el correo de recuperación',
                                  style: TextStyle(color: Colors.white),
                                ));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Container(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: label("Iniciar Sesión", Colors.white, 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

Widget textField(
    {String? hintText,
    IconData? icono,
    bool obscureText = false,
    Function(String)? onChanged,
    dynamic validator,
    TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(24),
    ),
    child: TextFormField(
      validator: validator,
      keyboardType: textInputTipe,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: "OpenSans",
          fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          prefixIcon: Icon(
            icono,
            color: Colors.white,
          ),
          border: InputBorder.none),
    ),
  );
}
