import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class KeyStorage {
  static late SharedPreferences _prefs;
  static bool _isMirror = false;
  static final Map<String, dynamic> _mirrorCache = {};

  static Future<void> init() async {
    if (_isMirror) return; // Mirror mode uses memory cache
    
    print('preference initialized');
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Skip initializing SharedPreferences in secondary windows
      if (const bool.hasEnvironment('FLUTTER_MULTI_WINDOW')) return;
    }
    _prefs = await SharedPreferences.getInstance();
  }

  static void initMirror(Map<String, dynamic> data) {
    _isMirror = true;
    _mirrorCache.addAll(data);
    print("KeyStorage: Initialized in Mirror Mode with ${data.length} keys.");
  }

  /// Save a boolean value
  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
    print("Saved: $key = $value");
  }

  /// Retrieve a boolean value
  static bool getBool(String key, {bool defaultValue = false}) {
    if (_isMirror) {
      final val = _mirrorCache[key];
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      return defaultValue;
    }
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
    if (_isMirror) {
      return _mirrorCache[key]?.toString() ?? defaultValue;
    }
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
    if (_isMirror) {
      final val = _mirrorCache[key];
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return defaultValue;
    }
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
    if (_isMirror) {
      final val = _mirrorCache[key];
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return defaultValue;
    }
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
    if (_isMirror) {
      final val = _mirrorCache[key];
      if (val is Map<String, dynamic>) return val;
      if (val is Map) return Map<String, dynamic>.from(val);
      if (val is String) {
        try {
          return Map<String, dynamic>.from(jsonDecode(val));
        } catch (_) {
          return null;
        }
      }
      return null;
    }
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
