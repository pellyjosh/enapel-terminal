import 'package:enapel/api/api_service.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:get/get.dart';

class ActivityLogger {
  static final ApiService _apiService = Get.isRegistered<ApiService>() ? Get.find<ApiService>() : Get.put(ApiService());

  static Future<void> log({
    required String action,
    String? description,
    String? module,
  }) async {
    try {
      final isServerMode = await ConnectionHelper.isServerConnection();
      if (!isServerMode) return;

      final user = KeyStorage.getMap('user');
      if (user == null) return;

      // In real scenario, we might want to buffer logs if offline
      // For now, just try to send
      await _apiService.post('activity-logs', {
        'action': action,
        'description': description ?? '',
        'module': module ?? KeyStorage.getString('active_module') ?? 'Global',
      });
      
      print('Activity logged: $action');
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }
}
