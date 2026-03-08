import 'key_storage.dart';

class ConfigStorage {
  static const String _isConfiguredKey = 'is_configured';
  static const String _databaseModeKey = 'database_mode';

  static Future<void> setConfigured(bool value1, String value2) async {
    await KeyStorage.saveBool(_isConfiguredKey, value1);
    await KeyStorage.saveString(_databaseModeKey, value2);
  }

  static bool isConfigured() {
    final isConfigured = KeyStorage.getBool(_isConfiguredKey);
    print("Configuration status read: $isConfigured");
    return isConfigured;
  }

  static Future<void> clearConfiguration() async {
    try {
      await KeyStorage.remove(_isConfiguredKey);
      await KeyStorage.remove(_databaseModeKey);
      print("Configuration status cleared.");
    } catch (e) {
      print("Error clearing configuration: $e");
    }
  }
}
