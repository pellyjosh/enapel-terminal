import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHelper {
  /// Hash a password using SHA-256
  static String hashPassword(String password) {
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    return hashedPassword;
  }

  /// Compare a plain-text password with a hashed password
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    final hashedInput = hashPassword(plainPassword);
    return hashedInput == hashedPassword;
  }
}
