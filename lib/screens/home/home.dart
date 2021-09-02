import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/screens/home/administrador.dart';
import 'package:tblpartes/screens/home/clase_semana.dart';
import 'package:tblpartes/screens/home/person.dart';
import 'package:tblpartes/screens/home/personal.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/auntentication.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<Autentication>().autStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              width: Medidas.width(100),
              height: Medidas.heigth(100),
              color: Color.fromRGBO(218, 0, 55, 1),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    label("Cargando Datos", Colors.white, 18),
                    SizedBox(
                      height: 8,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          );
        }
        User? data = snapshot.data;

        // ignore: unnecessary_null_comparison
        if (data!.uid != null) {
          return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("users").doc(data.uid).snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Container(
                      width: Medidas.width(100),
                      height: Medidas.heigth(100),
                      color: Color.fromRGBO(218, 0, 55, 1),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            label("Cargando Datos", Colors.white, 18),
                            SizedBox(
                              height: 8,
                            ),
                            CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [Text("Hecho"), TextButton(onPressed: () {}, child: Text("Salir"))],
                  );
                } else if (snapshot.hasError) {
                  return Text("Error ");
                } else {
                  String json = jsonEncode(snapshot.data!.data());

                  // ignore: unnecessary_null_comparison
                  if (json != "null") {
                    Map<String, dynamic> personal = jsonDecode(json);

                    //String typeUser = personal["type_user"];
                    String typeUser = "Clase de Semana";

                    if (typeUser == "administrador") {
                      return Administrador();
                    }
                    if (typeUser == "Clase de Semana") {
                      return Scaffold(
                        body: Container(
                          width: Medidas.width(100),
                          height: Medidas.heigth(100),
                          color: Color.fromRGBO(218, 0, 55, 1),
                          child: Center(
                            child: GridView.count(
                              shrinkWrap: true,
                              primary: false,
                              padding: const EdgeInsets.all(20),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              children: [
                                CardGrid("Ingresar como Clase de semana", () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ClaseSemana(
                                        arguments: "",
                                      );
                                    }),
                                  );
                                }),
                                CardGrid("Ingresar como Personal", () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return Person();
                                    }),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Personal();
                  } else {
                    return Personal();
                  }
                }
              });
        } else {
          return Text("data");
        }
      },
    );
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
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
