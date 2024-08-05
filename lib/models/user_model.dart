class UserModel {
  final String uid;
  final String email;
  final String role;
  final String name; // Nuevo campo para el nombre del usuario

  UserModel({required this.uid, required this.email, required this.role, this.name = ''});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      name: data['name'] ?? '', // Inicializa el nombre desde el mapa de datos
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name, // Incluye el nombre en el mapa de datos
    };
  }
}