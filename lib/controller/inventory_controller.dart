import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/models/database/inventory_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  late final EnapelDatabase database;
  late final ApiService apiService;
  bool isServerMode = false;
  bool _isInitialized = false;

  var inventoryData = <InventoryModel>[].obs;
  var filteredInventory =
      <InventoryModel>[].obs; // ✅ added missing filtered list
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxList<InventoryModel> inventoryDataOriginal =
      <InventoryModel>[].obs; // 👈 store original unfiltered list

  InventoryController() {
    _initialize();
  }

  Future<void> _initialize() async {
    isServerMode = await ConnectionHelper.isServerConnection();
    _isInitialized = true;
    if (isServerMode) {
      apiService = Get.put(ApiService());
      await getInventory();
    } else {
      database = Get.put(EnapelDatabase(openLocalConnection()));
    }
  }

  Future<void> getInventory() async {
    if (!_isInitialized) {
      await _initialize();
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isServerMode) {
        final response = await apiService.get(Config.getInventory);
        if (response['success'] == true) {
          List<dynamic> data = response['data'];
          List<InventoryModel> inventoryItems =
              data.map((item) => InventoryModel.fromApi(item)).toList();
          inventoryData.assignAll(inventoryItems);
          inventoryDataOriginal.assignAll(inventoryItems); // 👈 store original for search
          filteredInventory.assignAll(inventoryItems);
          print('✅ Inventory loaded from server');
        } else {
          errorMessage.value =
              response['message'] ?? 'Failed to fetch inventory';
          print("⚠️ API error: ${response['message']}");
        }
      } else {
        final query = await database.select(database.inventory).get();
        List<InventoryModel> inventoryItems =
            query.map((item) => InventoryModel.fromDrift(item)).toList();
        inventoryData.assignAll(inventoryItems);
        inventoryDataOriginal.assignAll(inventoryItems); // 👈 store original for search
        filteredInventory.assignAll(inventoryItems);
        print('✅ Inventory loaded from local database');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print("❌ Exception loading inventory: $e");
    } finally {
      isLoading.value = false;
    }
  }

Future<void> addItem(InventoryModel item) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = KeyStorage.getMap('user');
      final userId = user?['id'];

      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        print('❌ Add item failed: user not authenticated');
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: AppColor.danger, colorText: AppColor.white);
        return;
      }

      final payload = item.toApiPayloadForAdd(userId);
      print('🚀 Sending ADD payload: $payload');

      final response = await apiService.post(Config.addItem, payload);
      print('API Response: $response');

      if (response['success'] == true) {
        print('✅ Item added successfully');
        Get.snackbar('Success', response['message'],
            backgroundColor: AppColor.success, colorText: AppColor.white);
        await getInventory();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to add item';
        print('⚠️ Add item error: ${response['message']}');
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: AppColor.danger, colorText: AppColor.white);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Exception adding item: $e');
      Get.snackbar('Exception', errorMessage.value,
          backgroundColor: AppColor.danger, colorText: AppColor.white);
    } finally {
      isLoading.value = false;
    }
  }
Future<void> updateItem(InventoryModel item) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final payload = item.toApiPayloadForUpdate();
      print('🚀 Sending UPDATE payload: $payload');

      final response =
          await apiService.post('${Config.updateItem}/${item.id}', payload);
      print('API Response: $response');

      if (response['success'] == true) {
        errorMessage.value = '';
        Get.snackbar('Success', response['message'],
            backgroundColor: AppColor.success, colorText: AppColor.white);
        await getInventory();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to update item';
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: AppColor.danger, colorText: AppColor.white);
        await getInventory(); // optional refresh
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Exception updating item: $e');
      Get.snackbar('Exception', errorMessage.value,
          backgroundColor: AppColor.danger, colorText: AppColor.white);
    } finally {
      isLoading.value = false;
    }
  }

Future<void> deleteItem(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await apiService.post('${Config.deleteItem}/$id', {}); // ✅ ID in URL

      if (response['success'] == true) {
        print('✅ Item deleted successfully');
        await getInventory();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to delete item';
        print('⚠️ Delete item error: ${response['message']}');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('❌ Exception deleting item: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // void applyInventoryFilters(Map<String, dynamic> filters) {
  //   try {
  //     var filtered = inventoryData.where((item) {
  //       bool matches = true;
  //       if (filters.containsKey('minPrice')) {
  //         matches &= item.price >= filters['minPrice'];
  //       }
  //       if (filters.containsKey('maxPrice')) {
  //         matches &= item.price <= filters['maxPrice'];
  //       }
  //       if (filters.containsKey('name')) {
  //         matches &=
  //             item.name.toLowerCase().contains(filters['name'].toLowerCase());
  //       }
  //       return matches;
  //     }).toList();

  //     filteredInventory
  //         .assignAll(filtered); // ✅ update observable filtered list
  //     print('✅ Filter applied: ${filters.length} criteria');
  //   } catch (e) {
  //     errorMessage.value = 'An error occurred during filtering: $e';
  //     print('❌ Exception applying filter: $e');
  //   }
  // }
 
 
  void searchInventory(String query) {
    final allItems = inventoryDataOriginal; // 👈 store original unfiltered list
    if (query.isEmpty) {
      inventoryData.assignAll(allItems);
    } else {
      inventoryData.assignAll(
        allItems.where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            (item.barcode != null &&
                item.barcode!.toLowerCase().contains(query.toLowerCase()))),
      );
    }
  }

}
