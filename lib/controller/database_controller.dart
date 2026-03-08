import 'package:enapel/database/connection.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  static final DatabaseController instance = Get.find();

  late dynamic database;

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    bool isConfigured = await KeyStorage.getBool('is_configured') ?? false;
    if (!isConfigured) {
      print("App is not configured yet.");
      return;
    }

    String? databaseMode = KeyStorage.getString('database_mode');

    if (databaseMode == 'local') {
      openLocalConnection();
      print("Using local database.");
    } else if (databaseMode == 'server') {
      await openServerConnection();
      print("Using server-based connection.");
    } else {
      throw Exception("Invalid database mode configured.");
    }
  }
}
