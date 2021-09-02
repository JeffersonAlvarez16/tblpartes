import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/screens/autenticate/recuperar.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_personal.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/auntentication.dart';
import 'package:tblpartes/services/auth.dart';
import 'package:tblpartes/services/database.dart';

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // ignore: unused_field

  final DatabaseService databaseService = new DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final UserModel userData = new UserModel(uid: "");

  String email = "";
  String password = "";
  bool passwordvisible = false;
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    Medidas(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(23, 23, 23, 1),
      body: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.black87, Colors.white54], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            height: Medidas.heigth(100),
            width: Medidas.width(100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: Medidas.heigth(8),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Image.asset(
                    'assets/img/logo.png',
                    width: 125.0,
                    height: 125.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Ejército Ecuatoriano",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Lato"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Fuerza Terrestre",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Lato"),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Batallón de Selva 63 "Gualaquiza"',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Lato"),
                    )),
                Expanded(
                  child: Container(),
                ),
                Expanded(
                  flex: 32,
                  child: Center(
                      child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Container(
                            alignment: Alignment.topCenter,
                            width: Medidas.width(80),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: Medidas.heigth(5),
                                ),
                                textField(
                                    hintText: 'Cedula',
                                    icono: Icons.email_outlined,
                                    textInputTipe: TextInputType.emailAddress,
                                    validator: (value) => value.isEmpty ? "Ingrese la cedula" : null,
                                    onChanged: (value) {
                                      email = value;
                                    }),
                                SizedBox(
                                  height: Medidas.heigth(5),
                                ),
                                textField(
                                    hintText: 'Contraseña',
                                    icono: Icons.lock_open_outlined,
                                    pass: true,
                                    passwordVisible: passwordvisible,
                                    onPress: () {
                                      setState(() {
                                        passwordvisible = !passwordvisible;
                                      });
                                    },
                                    obscureText: true,
                                    validator: (value) => value.isEmpty ? "Ingrese la contraseña" : null,
                                    onChanged: (value) {
                                      password = value;
                                    }),
                                SizedBox(
                                  height: Medidas.heigth(4),
                                ),
                                cargando == true
                                    ? Container(
                                        width: Medidas.width(100),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(218, 0, 55, 1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            )),
                                        child: TextButton(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                          ),
                                          onPressed: () {},
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            gradient: LinearGradient(colors: [Colors.red, Colors.pink], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                                        width: Medidas.width(100),
                                        child: TextButton(
                                          child: Text(
                                            "Ingresar",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              cargando = true;
                                            });
                                            FocusScope.of(context).unfocus();
                                            if (_formKey.currentState!.validate()) {
                                              var correo = await databaseService.getCorreo(email);
                                              if (correo == "null") {
                                                final snackBar = SnackBar(content: Text('Debe ingresar los datos validos'));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                setState(() {
                                                  cargando = false;
                                                });
                                              } else {
                                                await context.read<Autentication>().signOut();
                                                dynamic result = context.read<Autentication>().signIn(
                                                      email: correo,
                                                      password: password,
                                                    );
                                                Navigator.pushNamed(context, '/home');
                                                if (result == null) {
                                                  final snackBar = SnackBar(content: Text('Contraseña incorrecta'));
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  setState(() {
                                                    cargando = false;
                                                  });
                                                }
                                              }
                                            } else {
                                              setState(() {
                                                cargando = false;
                                              });
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return Recuperar();
                                        }),
                                      );
                                    },
                                    child: label("Recuperar Contraseña", Colors.redAccent, 16),
                                  ),
                                )
                              ],
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget textField({String? hintText, IconData? icono, bool obscureText = false, bool passwordVisible = false, bool pass = false, Function(String)? onChanged, void Function()? onPress, dynamic validator, TextInputType textInputTipe = TextInputType.text}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white12,
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
      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Lato", fontStyle: FontStyle.normal),
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
          suffixIcon: pass == true
              ? IconButton(
                  icon: Icon(
                    // Based on passwordVisible state choose the icon
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: onPress,
                )
              : Text(""),
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
