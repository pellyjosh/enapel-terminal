import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/models/reports_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:get/get.dart';

class PatientController extends GetxController {
  late final ApiService apiService;
  bool isServerMode = false;
  bool _isInitialized = false;

  RxList<PatientModel> patientList = <PatientModel>[].obs;
  var filteredList = <PatientModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      isServerMode = await ConnectionHelper.isServerConnection();
      _isInitialized = true;

      if (isServerMode) {
        apiService = Get.put(ApiService());
        print("🌐 Server mode enabled");
      } else {
        throw Exception("Server mode disabled");
      }

      // Fetch initial patient data
      await fetchPatients();
    } catch (e) {
      errorMessage.value = 'Initialization error: $e';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: AppColor.danger, colorText: AppColor.white);
      print('❌ Initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPatient({
    required String name,
    required String medication,
    required String dosage,
    required String prescriptionStatus,
    required DateTime firstVisit,
    required DateTime lastVisit,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final Map<String, dynamic> data = {
        'name': name,
        'medication': medication,
        'dosage': dosage,
        'prescription_status': prescriptionStatus,
        'first_visit': firstVisit.toIso8601String(),
        'last_visit': lastVisit.toIso8601String(),
      };

      final response = await apiService.post(Config.patients, data);

      if (response['success'] == true) {
        Get.snackbar('Success', response['message'],
            backgroundColor: AppColor.success, colorText: AppColor.white);
        print('✅ Patient added successfully');
        await fetchPatients();
      } else {
        throw Exception(response['message'] ?? 'Failed to add patient');
      }
    } catch (e) {
      errorMessage.value = 'Error adding patient: $e';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: AppColor.danger, colorText: AppColor.white);
      print('❌ Exception adding patient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPatients() async {
    if (!_isInitialized) await _initialize();
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.get(Config.patientRecords);

      if (response['success'] == true && response.containsKey('data')) {
        List<dynamic> data = response['data'];
        patientList
            .assignAll(data.map((e) => PatientModel.fromJson(e)).toList());
        print('✅ Fetched patients from server');
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching patients: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onError,
      );
      print('❌ Exception fetching patients: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
