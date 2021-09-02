import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/screens/administrador/admin_batallon.dart';
import 'package:tblpartes/screens/administrador/admin_compnia.dart';
import 'package:tblpartes/screens/administrador/admin_estados.dart';
import 'package:tblpartes/screens/administrador/admin_horarios.dart';
import 'package:tblpartes/screens/administrador/admin_notificaciones.dart';
import 'package:tblpartes/screens/administrador/admin_personal.dart';
import 'package:tblpartes/screens/administrador/admin_reportes.dart';
import 'package:tblpartes/screens/administrador/admin_usuarios.dart';
import 'package:tblpartes/services/auntentication.dart';
import 'package:tblpartes/services/auth.dart';

class Administrador extends StatefulWidget {
  Administrador({Key? key}) : super(key: key);

  @override
  _AdministradorState createState() => _AdministradorState();
}

class _AdministradorState extends State<Administrador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black12,
          elevation: 0.0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.pink], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          title: Text(
            'Administrador',
            style: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.w900, color: Colors.white),
          ),
          leading: IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/img/logo.png',
              width: 125.0,
              height: 125.0,
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: label("", Colors.white, 14),
              onPressed: () async {
                await context.read<Autentication>().signOut();
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black12,
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: [
              CardGrid("GESTIONAR BATALLONES", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminBatallon();
                  }),
                );
              }),
              CardGrid("GESTIONAR COMPAÑIAS", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminCompania();
                  }),
                );
              }),
              CardGrid("GESTIONAR PERSONAL", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminPersonal();
                  }),
                );
              }),
              CardGrid("GESTIONAR ESTADOS", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminEstados();
                  }),
                );
              }),
              CardGrid("GESTIONAR USUARIOS", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminUsuarios();
                  }),
                );
              }),
              CardGrid("GESTIONAR HORARIOS", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminHorarios();
                  }),
                );
              }),
              CardGrid("GENERAR REPORTES", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminReportes();
                  }),
                );
              }),
              CardGrid("ENVIAR NOTIFICACIONES", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return AdminNotificaciones();
                  }),
                );
              }),
            ],
          ),
        ));
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
        color: Colors.white54,
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
