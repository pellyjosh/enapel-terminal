import 'package:enapel/utils/app_color.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../helper/db_connection_helper.dart';
import '../models/staff_model.dart';

class StaffController extends GetxController {
  late final ApiService apiService;
  late final bool isServerMode;

  var staffList = <StaffModel>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;

  StaffController() {
    _initialize();
  }

  Future<void> _initialize() async {
    isServerMode = await ConnectionHelper.isServerConnection();

    if (isServerMode) {
      apiService = Get.put(ApiService());
      await getStaffs();
    } else {
      print("Local mode is not supported (Drift removed)");
    }
  }

Future<void> getStaffs() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (isServerMode) {
        final response = await apiService.get('staffData');

        if (response['success'] == true &&
            response['data'] != null &&
            response['data'] is List) {
             print("response success");
          List<StaffModel> staffData = (response['data'] as List).map((item) {
            if (item is Map<String, dynamic>) {
              return StaffModel.fromApi(item);
            } else {
              print("Unexpected item format: $item");
              return StaffModel.fromApi({});
            }
          }).toList();

          staffList.assignAll(staffData);
        } else {
          hasError.value = true;
          print("Invalid response format or success=false");
        }
      }
    } catch (e) {
      hasError.value = true;
      print("Error loading staff: $e");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> addStaff(
    String name,
    String phone,
    String dob,
    String designation,
    String role,
    String salary,
  ) async {
    try {
      final body = {
        'name': name,
        'phone': phone,
        'dob': dob,
        'designation': designation,
        'role': role,
        'salary': salary,
      };

      final response = await apiService.post('addStaff', body);

      if (response['success']) {
        await getStaffs();
        Get.snackbar("Success", response['message'], backgroundColor: AppColor.success);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Update failed', backgroundColor: AppColor.danger);
      }
    } catch (e) {
      print("Error updating staff: $e");
      Get.snackbar('Error', 'Failed to update staff');
    }
  }

  Future<void> updateStaff(
    int id,
    String name,
    String phone,
    String dob,
    String designation,
    String role,
    String salary,
  ) async {
    try {
      final body = {
        'id': id.toString(),
        'name': name,
        'phone': phone,
        'dob': dob,
        'designation': designation,
        'role': role,
        'salary': salary,
      };

      final response = await apiService.post('updateStaff', body);

      if (response['success']) {
        await getStaffs();
        Get.snackbar('Success', 'Staff updated successfully');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Update failed');
      }
    } catch (e) {
      print("Error updating staff: $e");
      Get.snackbar('Error', 'Failed to update staff');
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      final response =
          await apiService.post('deleteStaff', {'id': id.toString()});

      if (response['success']) {
        staffList.removeWhere((staff) => staff.id == id);
        Get.snackbar('Deleted', 'Staff deleted');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Delete failed');
      }
    } catch (e) {
      print("Error deleting staff: $e");
      Get.snackbar('Error', 'Failed to delete staff');
    }
  }
}
