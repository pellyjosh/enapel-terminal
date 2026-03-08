import 'package:enapel/database/database.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.isAdmin,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Drift User to Model
  factory UserModel.fromDrift(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      isAdmin: user.isAdmin,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  Map<String, dynamic> toMapWithoutPassword() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}

Map<String, dynamic> userToMap(User user) {
  return {
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'isAdmin': user.isAdmin,
  };
}

