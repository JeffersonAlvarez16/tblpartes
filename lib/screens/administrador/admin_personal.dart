import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/models/batallon.dart';
import 'package:tblpartes/models/user.dart';
import 'package:tblpartes/screens/crud_admin/new_edit_personal.dart';
import 'package:tblpartes/screens/home/person.dart';
import 'package:tblpartes/screens/listas/personallistas.dart';
import 'package:tblpartes/services/database.dart';
import 'package:tblpartes/services/streams.dart';

class AdminPersonal extends StatefulWidget {
  AdminPersonal({Key? key}) : super(key: key);

  @override
  _AdminPersonalState createState() => _AdminPersonalState();
}

class _AdminPersonalState extends State<AdminPersonal> {
  StreamServices streamServices = new StreamServices();
  DatabaseService databaseService = new DatabaseService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<UserModel>>.value(
        initialData: [],
        value: streamServices.personal,
        child: Scaffold(
          floatingActionButton: StreamProvider<List<Batallon>>.value(
            value: streamServices.batallones,
            initialData: [],
            child: TextButton(
                child: Text(
                  "Registrar Personal",
                  style: TextStyle(color: Colors.white, fontFamily: "Lato", fontSize: 14),
                ),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromRGBO(218, 0, 55, 1))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return NewEditPersonal(
                        userModel: new UserModel.fromUserModel(uid: "", hasta: "", grado: "", apellidos: "", nombres: "", batallon: "", compania: "", token: "", email: "", cedula: "", typeUser: "", estado: "Falto"),
                      );
                    }),
                  );
                }),
          ),
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.black12,
            elevation: 0.0,
            toolbarHeight: 70,
            flexibleSpace: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)), gradient: LinearGradient(colors: [Colors.red, Colors.red.shade900], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
            ),
            actions: <Widget>[
              StreamBuilder<List<UserModel>>(
                stream: streamServices.personal,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("...");
                  }
                  if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
                    List<UserModel>? lista = snapshot.data;
                    return IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(context: context, delegate: DataSearch(lista));
                        });
                  }
                  return Text("...");
                },
              ),
            ],
            title: Text(
              "Gesti??n de Personal",
              style: TextStyle(color: Colors.white, fontFamily: "Lato", fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, color: Colors.black12, child: PersonalListas()),
        ));
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<UserModel>? lista;

  DataSearch(this.lista);

  @override
  List<Widget> buildActions(BuildContext context) {
    //Actions for app bar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //leading icon on the left of the app bar
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, "null");
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    List<UserModel>? suggestionList = lista;

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList![index].apellidos),
        subtitle: Text(suggestionList![index].nombres),
      ),
      itemCount: suggestionList!.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // show when someone searches for something

    final suggestionList = query.isEmpty ? lista : lista!.where((p) => p.apellidos.contains(RegExp(query, caseSensitive: false))).toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return NewEditPersonal(
                      userModel: suggestionList![index],
                    );
                  }),
                );
              },
              title: RichText(
                text: TextSpan(text: suggestionList![index].apellidos.substring(0, query.length), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), children: [
                  TextSpan(text: (suggestionList[index].apellidos + " " + suggestionList[index].nombres).substring(query.length), style: TextStyle(color: Colors.grey)),
                ]),
              ),
            ),
        itemCount: suggestionList!.length);
  }
}
