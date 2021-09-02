import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/estados.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/screens/listas/estadoparte.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:tblpartes/services/auntentication.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';
import 'package:firebase_core/firebase_core.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class Personal extends StatefulWidget {
  Personal({Key? key}) : super(key: key);

  @override
  _PersonalState createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  String? token = '';
  late FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  StreamServices streamServices = new StreamServices();
  late UserModel userModel = new UserModel(uid: "");
  DateTime now = new DateTime.now();
  DateTime date = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  void getToken() async {
    token = await firebaseMessaging.getToken();
    await databaseService.registrarToken(token);
  }

  @override
  void initState() {
    getToken();
    // TODO: implement initState

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/logo',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
    showNotification();
    streamServices.horariosString.listen((event) {
      setState(() {
        horaParte = event.first;
      });
    });
    super.initState();
  }

  void showNotification() async {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  DatabaseService databaseService = new DatabaseService();

  int _selectedIndex = 0;

  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  String horaParte = "";
  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Container(
        child: StreamBuilder<User?>(
            stream: context.read<Autentication>().autStateChange,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              User? data = snapshot.data;
              String userUIs = data!.uid;
              return StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("personal").doc(userUIs).snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    String json = jsonEncode(snapshot.data!.data());

                    Map<String, dynamic> personal = jsonDecode(json);
                    userModel = new UserModel.fromUserModel(uid: personal["uid"], hasta: personal["hasta"] ?? "", token: personal["token"] ?? "", apellidos: personal["apellidos"], grado: personal["grado"], nombres: personal["nombres"], batallon: personal["batallon"], compania: personal["compania"], cedula: personal["cedula"], email: personal["email"], typeUser: "typeUser");
                    return SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label("Grado:", Color.fromRGBO(218, 0, 55, 1), 18),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  label("Apellidos:", Color.fromRGBO(218, 0, 55, 1), 18),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  label("Nombres:", Color.fromRGBO(218, 0, 55, 1), 18),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  label("Compañia:", Color.fromRGBO(218, 0, 55, 1), 18),
                                  SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    label(personal["grado"], Colors.black, 18),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    label(personal["apellidos"], Colors.black, 18),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    label(personal["nombres"], Colors.black, 18),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    label(personal["compania"], Colors.black, 18),
                                    SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Divider(),
                          label("Seleccione el horario del parte", Color.fromRGBO(218, 0, 55, 1), 18),
                          StreamBuilder<List<String>>(
                            stream: streamServices.horariosStringPersonal,
                            builder: (context, AsyncSnapshot<List<String>> snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                                return Container(
                                  alignment: Alignment.center,
                                  color: Colors.black12,
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.all(0),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    value: horaParte,
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
                                      setState(() {
                                        horaParte = newValue;
                                      });
                                    },
                                    items: snapshot.data!.map<DropdownMenuItem>((String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                          Divider(),
                          label("Estado actual al momento del parte:", Color.fromRGBO(218, 0, 55, 1), 18),
                          SizedBox(
                            height: 8,
                          ),
                          StreamProvider<List<Estados>>.value(
                            initialData: [],
                            value: streamServices.estados,
                            child: EstadosParte(usuario: userModel, horaParte: horaParte),
                          )
                        ]));
                  });
            }),
      ),
      Notificaciones(context, databaseService)
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                badgeContent: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: databaseService.notificacionesExistentesUser(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('...');
                    }
                    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>> lista = snapshot.data!.docs;
                      lista.removeWhere((element) => element["atendido"] == true);
                      return Text(lista.length.toString());
                    }

                    return Text('...');
                  },
                ),
                child: Icon(Icons.settings),
              ),
              label: 'Notificaciones',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black12,
          elevation: 0.0,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.pink], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
          title: Text(
            'Personal',
            style: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.w900, color: Colors.white),
          ),
          leading: IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/img/logo.png',
              width: 100.0,
              height: 100.0,
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.logout_outlined,
                color: Colors.black,
              ),
              label: label("", Color.fromRGBO(218, 0, 55, 1), 14),
              onPressed: () async {
                await context.read<Autentication>().signOut();
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
        body: Container(
            color: Colors.black12,
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            )));
  }
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
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

Widget Notificaciones(context, databaseService) {
  return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: databaseService.notificacionesExistentesUser(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: Text("Cargango"),
        );
      }
      if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> lista = snapshot.data!.docs;

        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(bottom: 150),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> dataNoti = lista[index].data();

              return Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(dataNoti["name"].toString()),
                        subtitle: Text(dataNoti["subject"].toString()),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 24),
                        child: Text(
                          "Fecha: " + dataNoti["create"].toDate().toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      if (dataNoti["atendido"] == false)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 200,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(218, 0, 55, 1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  )),
                              child: TextButton(
                                child: Text(
                                  "Marcar como leída",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  await databaseService.cambiarEstadoNotiUser(lista[index].id);
                                },
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
      return Center(
        child: Text("Cargango"),
      );
    },
  ));
}
