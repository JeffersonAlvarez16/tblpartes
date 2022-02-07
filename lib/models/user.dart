class UserModel {
  String uid;
  String grado = "";
  String apellidos = "";
  String nombres = "";
  String batallon = "";
  String compania = "";
  String email = "";
  String password = "";
  String typeUser = "";
  String cedula = "";
  String token = "";
  String hasta = "";
  String estado = "";

  UserModel({required this.uid});
  UserModel.fromUserModel({required this.uid, required this.apellidos, required this.grado, required this.nombres, required this.batallon, required this.compania, required this.cedula, required this.email, required this.token, required this.typeUser, required this.hasta, required this.estado});

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = this.uid;
    data['grado'] = this.grado;
    data['apellidos'] = this.apellidos;
    data['nombres'] = this.nombres;
    data['batallon'] = this.batallon;
    data['compania'] = this.compania;
    data['estado'] = this.estado;
    data['email'] = this.email;
    data['password'] = this.password;
    data['typeUser'] = this.typeUser;
    data['token'] = this.token;
    data['hasta'] = this.hasta;

    return data;
  }
}
