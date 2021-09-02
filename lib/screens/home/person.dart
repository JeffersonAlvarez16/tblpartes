import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/services/auntentication.dart';

class Person extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("HOME"),
          ElevatedButton(
            onPressed: () {
              context.read<Autentication>().signOut();
            },
            child: StreamBuilder<User?>(
              stream: context.read<Autentication>().autStateChange,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Sin datos aun ");
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [Text("Hecho"), TextButton(onPressed: () {}, child: Text("Salir"))],
                  );
                } else if (snapshot.hasError) {
                  return Text("Error ");
                } else {
                  return Column(
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        label: label("Cerrar Sesión", Color.fromRGBO(218, 0, 55, 1), 14),
                        onPressed: () {
                          context.read<Autentication>().signOut();
                          Navigator.pushNamed(context, '/signIn');
                        },
                      )
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: size > 14 ? size : 14, fontFamily: "Lato", fontWeight: FontWeight.bold),
  );
}
