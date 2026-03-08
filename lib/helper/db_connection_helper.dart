import 'package:enapel/database/storage/key_storage.dart';

class ConnectionHelper {
  static Future<bool> isServerConnection() async {
    final databaseMode = KeyStorage.getString('database_mode');
    return databaseMode == 'server';
  }

  static Future<bool> isLocalConnection() async {
    final databaseMode = KeyStorage.getString('database_mode');
    return databaseMode == 'local';
  }
}
