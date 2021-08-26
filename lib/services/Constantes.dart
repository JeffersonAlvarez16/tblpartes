import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class Medidas {
  static late double _width;
  static late double _heigth;
  late FirebaseApp secondaryApp;

  Medidas(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _heigth = MediaQuery.of(context).size.height;
  }

  static double width(double porsentaje) {
    return _width * (porsentaje / 100);
  }

  static double heigth(double porsentaje) {
    return _heigth * (porsentaje / 100);
  }
}
