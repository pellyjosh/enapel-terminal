import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as drift;
import 'package:enapel/database/database.dart';
import 'package:enapel/utils/notification.dart';

class UserController {
  final EnapelDatabase database;

  UserController(this.database);

  Future<void> createSuperUser(
      String name, String email, String password) async {
    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      await database.into(database.users).insert(
            UsersCompanion(
              name: drift.Value(name),
              email: drift.Value(email),
              password: drift.Value(hashedPassword),
              isAdmin: const drift.Value(true),
            ),
          );
      NotificationService.showSuccess(
        title: 'Success',
        message: "Super user created successfully!",
      );
    } catch (e) {
      NotificationService.showError(
        title: 'Error',
        message: "Failed to create super user: ${e.toString()}",
      );
    }
  }
}
