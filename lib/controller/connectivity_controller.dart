import 'package:enapel/database/storage/key_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConnectivityController extends GetxController {
  var isServerAvailable = true.obs;
  var isChecking = false.obs;
  String? injectedServerIp;

  ConnectivityController({this.injectedServerIp});

  Future<bool> checkConnection() async {
    isChecking.value = true;
    try {
      String? serverIp = injectedServerIp ?? KeyStorage.getString('serverIp') ?? KeyStorage.getString('server_ip');
      if (serverIp == null || serverIp.isEmpty) {
        isServerAvailable.value = false;
        return false;
      }

      await http.get(Uri.parse('http://$serverIp/api/v1')).timeout(const Duration(seconds: 5));
      // We accept 200 or even other codes as long as the server responded (meaning it's up)
      // Usually the root /api/v1 might return 404 or 200 depending on the Laravel routes
      isServerAvailable.value = true;
      return true;
    } catch (e) {
      isServerAvailable.value = false;
      return false;
    } finally {
      isChecking.value = false;
    }
  }

  void setServerDown() {
    isServerAvailable.value = false;
  }

  void setServerUp() {
    isServerAvailable.value = true;
  }
}
