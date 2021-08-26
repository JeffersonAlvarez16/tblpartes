import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/AutenticationWraper.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/screens/autenticate/sign_in.dart';
import 'package:tblpartes/screens/home/administrador.dart';
import 'package:tblpartes/screens/home/comandante.dart';
import 'package:tblpartes/screens/home/oficial_semana.dart';
import 'package:tblpartes/screens/home/person.dart';
import 'package:tblpartes/screens/home/personal.dart';
import 'package:tblpartes/screens/home/sub_comandante.dart';
import 'package:tblpartes/services/auntentication.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext contexta) {
    contexta.read<Autentication>().changeUserData("");
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: contexta.read<Autentication>().autStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
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
          );
        }
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            User? data = snapshot.data;
            print(data!.uid);
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection("users").where("uid_user", isEqualTo: data.uid).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
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
                    );
                  }
                  if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
                    print(snapshot.data!.size);
                    if (snapshot.data!.size == 0) {
                      return Personal();
                    }

                    String json = jsonEncode(snapshot.data!.docs[0].data());
                    Map<String, dynamic> personal = jsonDecode(json);

                    String typeUser = personal["type_user"];
                    /*    List<String> perfilesUsuarios = <String>[
                      'Clase de Semana',
                      'Oficial de Semana',
                      'Comandante de Compañía',
                      'Sub comandante',
                      'Comandante',
                    ]; */
                    print(typeUser);
                    if (typeUser == "Comandante") {
                      return Comandante();
                    }
                    if (typeUser == "Sub comandante") {
                      return SubComandante();
                    }
                    if (typeUser == "Oficial de Semana") {
                      return OficialSemana();
                    }
                    if (typeUser == "administrador") {
                      return Administrador();
                    }
                    if (typeUser == "Clase de Semana") {
                      String compania = personal["compania"] ?? "";
                      contexta.read<Autentication>().changeUserData(compania);
                      Future.delayed(Duration(seconds: 5));
                      return SwicthA({"clase_semana": "clase_semana", "compania": compania});
                    }
                    if (typeUser == "Comandante de Compañía") {
                      String compania = personal["compania"] ?? "";
                      contexta.read<Autentication>().changeUserData(compania);
                      Future.delayed(Duration(seconds: 5));
                      return SwicthA({"comandante_compania": "comandante_compania", "compania": compania});
                    }
                    return Personal();
                  }
                  return Center(
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
                  );
                });
          } else {
            return SignIn();
          }
        } else {
          return Text("data");
        }
      },
    ));
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "OpenSans", fontWeight: FontWeight.bold),
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