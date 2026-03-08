import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class KeyStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    print('preference initialized');
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Skip initializing SharedPreferences in secondary windows
      if (const bool.hasEnvironment('FLUTTER_MULTI_WINDOW')) return;
    }
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a boolean value
  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    print("Saved: $key = $value");
  }

  /// Retrieve a boolean value
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = _prefs.getBool(key) ?? defaultValue;
    print("Retrieved: $key = $value");
    return value;
  }

  /// Save a string value
  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
    print("Saved: $key = $value");
  }

  /// Retrieve a string value
  static String? getString(String key, {String? defaultValue}) {
    final value = _prefs.getString(key) ?? defaultValue;
    print("Retrieved: $key = $value");
    return value;
  }

  /// Save an integer value
  static Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
    print("Saved: $key = $value");
  }

  /// Retrieve an integer value
  static int? getInt(String key, {int? defaultValue}) {
    final value = _prefs.getInt(key) ?? defaultValue;
    print("Retrieved: $key = $value");
    return value;
  }

  /// Save a double value
  static Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
    print("Saved: $key = $value");
  }

  /// Retrieve a double value
  static double? getDouble(String key, {double? defaultValue}) {
    final value = _prefs.getDouble(key) ?? defaultValue;
    print("Retrieved: $key = $value");
    return value;
  }

  /// Save a map (converted to JSON string)
  static Future<void> saveMap(String key, Map<String, dynamic> map) async {
    String jsonString = jsonEncode(map);
    await _prefs.setString(key, jsonString);
    print("Saved map: $key = $jsonString");
  }

  /// Retrieve a map (parse from JSON string)
  static Map<String, dynamic>? getMap(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    }
    print("No map found for key: $key");
    return null;
  }

  /// Remove a key
  static Future<void> remove(String key) async {
    await _prefs.remove(key);
    print("Removed: $key");
  }

  /// Clear all keys (Use with caution)
  static Future<void> clearAll() async {
    await _prefs.clear();
    print("Cleared all keys.");
  }
}
