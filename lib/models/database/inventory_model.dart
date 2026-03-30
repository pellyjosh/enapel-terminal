import 'package:enapel/database/database.dart';

class InventoryModel {
  final int? id; // nullable for new items
  final String name;
  final String? barcode;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? staffId; // optional: set when needed

  InventoryModel({
    this.id,
    required this.name,
    this.barcode,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    this.staffId,
  });

factory InventoryModel.fromApi(Map<String, dynamic> apiData) {
    return InventoryModel(
      id: apiData['id'] != null ? int.tryParse(apiData['id'].toString()) : null,
      name: apiData['name'] ?? '',
      barcode: apiData['barcode']?.toString(),
      quantity: apiData['quantity'] != null
          ? int.tryParse(apiData['quantity'].toString()) ?? 0
          : 0,
      price: apiData['price'] != null
          ? double.tryParse(apiData['price'].toString()) ?? 0.0
          : 0.0,
      createdAt:
          DateTime.tryParse(apiData['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(apiData['updated_at'] ?? '') ??DateTime.now(),
      staffId: apiData['user_id'] != null
          ? int.tryParse(apiData['user_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toApiPayloadForAdd(int userId) {
    return {
      'name': name,
      'qty': quantity,
      'price': price,
      'user_id': userId,
      // ✅ omit 'barcode' if not used
    };
  }

  Map<String, dynamic> toApiPayloadForUpdate() {
    return {
      'name': name,
      'qty': quantity,
      'price': price,
      // ✅ omit 'user_id' on update unless needed
    };
  }



  // Convert Drift InventoryItem to Model
  factory InventoryModel.fromDrift(InventoryItem item) {
    return InventoryModel(
      id: item.id,
      name: item.name,
      // barcode: item.barcode, // Add this when drift table is updated
      quantity: item.quantity,
      price: item.price,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }
  
}
