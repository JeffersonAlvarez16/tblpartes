class Horarios {
  String uid = "";
  String hora = "";
  bool estado = false;
  DateTime createAt = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Horarios({
    required this.hora,
    required this.uid,
    required this.createAt,
    required this.estado,
  });
}
