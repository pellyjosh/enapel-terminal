import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/models/reports_model.dart';
import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  late final EnapelDatabase database;
  late final ApiService apiService;
  late final bool isServerMode;

  var salesList = <SalesModel>[].obs;
  // var expensesList = <ExpenseModel>[].obs;
  var financeSummaryList = <FinanceSummaryModel>[].obs;
  var isLoading = false.obs;
  final hasError = false.obs;

  AnalyticsController() {
    _initialize();
  }

  Future<void> _initialize() async {
    isServerMode = await ConnectionHelper.isServerConnection();

    if (isServerMode) {
      apiService = Get.put(ApiService());
      await fetchSales();
      await fetchFinanceSummary();
    } else {
      database = Get.put(EnapelDatabase(openLocalConnection()));
    }
  }


Future<void> fetchSales() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      if (isServerMode) {
        final response = await apiService.get(Config.getSales);

        if (response is Map && response.containsKey('data')) {
          List<dynamic> data = response['data'];

          try {
            List<SalesModel> list =
                data.map((e) => SalesModel.fromJson(e)).toList();
            salesList.assignAll(list);
          } catch (e) {
            print("SalesModel.fromJson error: $e");
            hasError.value = true;
          }
        } else {
          print("Invalid response structure: $response");
          hasError.value = true;
        }
      }
    } catch (e) {
      print("fetchSales error: $e");
      hasError.value = true;
      Get.snackbar(
        "Sales Error",
        "Failed to load sales data",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

Future<void> fetchFinanceSummary() async {
  isLoading.value = true;
   hasError.value = false;
  try {
    if (isServerMode) {
      final response = await apiService.get(Config.dailysummary);
      if (response.containsKey('data')) {
        List data = response['data'];
        financeSummaryList.value =
            data.map((e) => FinanceSummaryModel.fromJson(e)).toList();
      }
    }
  } catch (e) {
    Get.snackbar(
      "Finance Error",
      "Failed to load finance summary",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  } finally {
    isLoading.value = false;
  }
}

  // Future<void> addExpense(String type, double amount) async {
  //   isLoading.value = true;
  //   try {
  //     if (isServerMode) {
  //       final response = await apiService.post(Config.expenses, {
  //         'type': type,
  //         'amount': amount.toString(),
  //       });

  //       if (response.containsKey('data')) {
  //         final data = response['data'];
  //         expensesList.add(ExpenseModel.fromJson(data));
  //         print("✅ Expense added.");
  //       } else {
  //         print("⚠️ Failed to add expense: no data key.");
  //       }
  //     } else {
  //       print("📴 Local expense add not implemented.");
  //     }
  //   } catch (e) {
  //     print("❌ Error adding expense: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
