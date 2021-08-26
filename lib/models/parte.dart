class Parte {
  String uid = "";
  String uidPersonal = "";

  String nombres = "";
  String apellidos = "";
  int contador = 0;
  String estado = "";
  String rango = "";
  String compania = "";
  String nota = "";
  String desde = "";
  String hasta = "";
  String estado_lista = "";
  DateTime fechaRegistro = new DateTime.now();

  Parte({required this.uid, required this.uidPersonal, required this.estado, required this.apellidos, required this.fechaRegistro, required this.nombres, required this.compania, required this.rango, required this.nota, required this.desde, required this.hasta});
}
