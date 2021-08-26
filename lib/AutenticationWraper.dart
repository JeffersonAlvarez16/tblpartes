import 'package:flutter/material.dart';

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}

class SwicthA extends StatelessWidget {
  static const String route = '/details';

  final dynamic? arguments;

  SwicthA(this.arguments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          arguments["clase_semana"] == "clase_semana" ? ClaseSemanaW(context, arguments["compania"]) : Text(""),
          arguments["comandante_compania"] == "comandante_compania" ? ComandanteCompaniaW(context, arguments["compania"]) : Text(""),
        ],
      )),
    );
  }
}

Widget ClaseSemanaW(context, compania) {
  return Center(
    child: GridView.count(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: [
        CardGrid("Ingresar como Clase de semana", () {
          Navigator.pushNamed(context, '/clase_semana', arguments: {"compania": compania});
        }),
        CardGrid("Ingresar como Personal", () {
          Navigator.pushNamed(context, '/personal');
        }),
      ],
    ),
  );
}

Widget ComandanteCompaniaW(context, compania) {
  return Center(
    child: GridView.count(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: [
        CardGrid("Ingresar como comandante de compañia", () {
          Navigator.pushNamed(context, '/comandante_compania', arguments: {"compania": compania});
        }),
        CardGrid("Ingresar como Personal", () {
          Navigator.pushNamed(context, '/personal');
        }),
      ],
    ),
  );
}

Widget label(String text, Color color, double size) {
  return Text(
    text,
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
              padding: EdgeInsets.all(16),
              child: label(title, Colors.black, 16),
            ),
          ],
        )),
    onTap: onTap,
  );
}