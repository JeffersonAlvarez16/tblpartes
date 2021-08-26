class Estados {
  String uid = "";
  String nombre = "";
  bool nota = false;
  bool fechas = false;
  bool estado = false;
  bool listado = false;
  dynamic lista = [];

  Estados({required this.nombre, required this.uid, required this.nota, required this.estado, required this.lista, required this.listado, required this.fechas});
}
