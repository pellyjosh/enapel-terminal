import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/models/cart_item_model.dart';
import 'package:enapel/models/product_model.dart';
import 'package:enapel/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class PosController extends GetxController {
  late final EnapelDatabase database;
  static Future<bool> isServerMode = ConnectionHelper.isServerConnection();
  late final ApiService apiService;

  TextEditingController cashAmountPaidController = TextEditingController();
  var productData = <Product>[].obs;
  final double vat = 10.00;
  var vatAmount = 0.00.obs;
  final RxList<CartItem> cart = <CartItem>[].obs;
  var totalAmount = 0.00.obs;
  var subtotalAmount = 0.00.obs;
  var posCode = "".obs;
  var paymentMethod = "";
  var change = 0.0.obs;
  final RxList<String> pendingReceiptNumbers = <String>[].obs;


  // PosController(String databaseMode) {
  //   if (databaseMode == 'local') {
  //     database = Get.put(EnapelDatabase(openLocalConnection()));
  //   } else {
  //     throw Exception("Only local database mode is supported for now.");
  //   }
  // }

  PosController(String databaseMode) {
    print('Database mode: $databaseMode');

    if (databaseMode == 'local') {
      if (!Get.isRegistered<EnapelDatabase>()) {
        Get.put(EnapelDatabase(openLocalConnection()));
      }
      database = Get.find<EnapelDatabase>();
    } else {
      apiService = Get.put(ApiService());
    }
    generatePosCode();
  }

  void generatePosCode() async {
    // if (posCode.value.isEmpty) {
    if (await isServerMode) {
      try {
        final response = await apiService.get(Config.generatePosCode);
        if (response['success'] == true) {
          posCode.value = response['posCode'];
        } else {
          print(
              "Error generating POS code from server: ${response['message']}");
          posCode.value = "POS-${const Uuid().v4().substring(0, 8)}";
        }
      } catch (e) {
        print("Server POS code generation failed: $e");
        posCode.value = "POS-${const Uuid().v4().substring(0, 8)}"; // Fallback
      }
    } else {
      posCode.value =
          "POS-${const Uuid().v4().substring(0, 8)}"; // Client-generated
    }
  }

  Future<void> checkDatabaseConnection() async {
    try {
      final testQuery = await database.select(database.inventory).get();
      print(
          'Database connection successful. Found ${testQuery.length} products in inventory.');
    } catch (e) {
      print('Database connection failed: $e');
    }
  }

  Future<void> checkout() async {
    if (await isServerMode) {
      try {
        final orderData = {
          "posCode": posCode.value,
          "total": totalAmount.value.toDouble(),
          "method": paymentMethod,
          "cashPaid": cashAmountPaidController.text ?? 0.00,
          "change": change.toDouble(),
          "items": cart
              .map((item) => {
                    "productId": item.product.id,
                    "name": item.product.name,
                    "quantity": item.quantity,
                    "price": item.product.price
                  })
              .toList(),
          "date": DateTime.now().toIso8601String(),
        };

        final response = await apiService.post(Config.checkOut, orderData);

        if (response['success'] == true) {
          print("Checkout successful! Order ID: ${response['orderId']}");
          NotificationService.showSuccess(
              title: 'Success', message: 'Checkout Successful');
          clearCart();
        } else {
          print("Checkout failed: ${response['error']}");
        }
      } catch (e) {
        print("Error during server checkout: $e");
      }
    } else {
      try {
        final saleId = await database.into(database.sales).insert(
              SalesCompanion.insert(
                posCode: posCode.value,
                total: totalAmount.value,
                paymentMethod:
                    drift.Value(paymentMethod), // Default payment method
                amountPaid: drift.Value(
                    totalAmount.value), // Assume full payment for now
                change: drift.Value(
                    change.toDouble()), // No change for POS transactions
                date: drift.Value(DateTime.now()),
              ),
            );

        for (var item in cart) {
          await database.into(database.saleItems).insert(
                SaleItemsCompanion.insert(
                  saleId: saleId,
                  productId: item.product.id,
                  productName: item.product.name,
                  price: item.product.price,
                  quantity: item.quantity,
                ),
              );
        }

        clearCart();
      } catch (e) {
        print("Error during local checkout: $e");
      }
    }
  }
  Future<void> savePendingReceipt() async {
  try {
    final posCodeValue = "POS-${DateTime.now().millisecondsSinceEpoch}";
    final now = DateTime.now();

    final payload = {
      'posCode': posCodeValue,
      'total': totalAmount.value,
      'method': paymentMethod.isEmpty ? 'pending' : paymentMethod,
      'cashPaid': 0.0,
      'change': 0.0,
      'date': now.toIso8601String(),
      'items': cart
          .map((item) => {
                "productId": item.product.id,
                "name": item.product.name,
                "quantity": item.quantity,
                "price": item.product.price
              })
          .toList()
    };

    final response = await apiService.post(Config.checkOut, payload);

    if (response['success'] == true) {
      pendingReceiptNumbers.add(posCodeValue); // Update list for UI
      NotificationService.showSuccess(
          title: 'Saved', message: 'Receipt saved as pending');
      clearCart(); // Optionally clear POS
    } else {
      print("❌ Error saving pending receipt: ${response['message']}");
    }
  } catch (e) {
    print("❌ Exception saving pending receipt: $e");
  }
}

Future<Receipt> getReceiptDetails(String receiptNumber) async {
    try {
      final response = await apiService.get('receipts/$receiptNumber');

      if (response['success'] == true && response['receipt'] != null) {
        return Receipt.fromJson(response['receipt']);
      } else {
        throw Exception("Receipt not found");
      }
    } catch (e) {
      print("❌ Failed to fetch receipt: $e");
      rethrow;
    }
  }


  Future<void> products(String query) async {
    if (await isServerMode) {
      try {
        final url = query.isNotEmpty
            ? '${Config.getProduct}?search=$query'
            : Config.getProduct;

        final response = await apiService.get(url);

        if (response['success'] == true) {
          List<dynamic> data = response['data'];
          productData.assignAll(data.map((e) => Product.fromJson(e)).toList());
          print("Products fetched successfully.");
        } else {
          print("Error fetching products: ${response['message']}");
        }
      } catch (e, stackTrace) {
        print("Fetch Products Error: $e");
        print("StackTrace: $stackTrace");
      }
    } else {
      try {
        final products = query.isEmpty
            ? await database.select(database.inventory).get()
            : await (database.select(database.inventory)
                  ..where((tbl) => tbl.name.like('%$query%')))
                .get();
        print("Products fetched: ${products.length}");

        productData.assignAll(
          products
              .map((row) => Product(
                    id: row.id,
                    name: row.name,
                    price: double.parse(row.price.toStringAsFixed(2)),
                    quantity: row.quantity,
                    status: row.quantity >= 10 ? 'Low' : 'Sufficient',
                  ))
              .toList(),
        );
      } catch (e) {
        print("Error fetching products: $e");
      }
    }
  }
void updateCartQuantity(int productId, int newQuantity) {
    final index = cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      cart[index].quantity = newQuantity;
      cart.refresh(); // Trigger UI update
      updateSubTotal(); // If you have subtotal logic
    }
  }


  /// Add a product to the cart
void addToCart(Product product, int quantity) {
    try {
      // Ensure the state update is handled outside the build method
      final int index =
          cart.indexWhere((item) => item.product.id == product.id);

      if (index >= 0) {
        cart[index].quantity += quantity; // Update existing product quantity
      } else {
        cart.add(
            CartItem(product: product, quantity: quantity)); // Add new product
      }

      updateSubTotal(); // Update the subtotal after adding or updating cart item
    } catch (e) {
      print("Error adding product to cart: $e");
    }
  }


  /// Remove a product from the cart
  void removeFromCart(CartItem cartItem) {
    try {
      int index =
          cart.indexWhere((item) => item.product.id == cartItem.product.id);
      if (index >= 0) {
        cart.removeAt(index);
        updateSubTotal();
      } else {
        print("Product not found in cart.");
      }
    } catch (e) {
      print("Error removing product from cart: $e");
    }
  }

  /// Update the subtotal and total amounts
  void updateSubTotal() {
    subtotalAmount.value = double.parse(cart
        .fold(
          0.0,
          (sum, item) => sum + (item.product.price * item.quantity),
        )
        .toStringAsFixed(2));
    updateTotal(); // Ensure the total is updated
  }

  void updateTotal() {
    vatAmount.value =
        double.parse((subtotalAmount.value * (vat / 100)).toStringAsFixed(3));
    totalAmount.value = double.parse(
        (subtotalAmount.value + vatAmount.value).toStringAsFixed(2));
  }

  void clearCart() {
    try {
      cart.clear();
      updateSubTotal();

      totalAmount.value = 0.0;
      change.value = 0.0;
      paymentMethod = '';
      cashAmountPaidController.clear();

      generatePosCode();
    } catch (e) {
      print("Error clearing the cart: $e");
    }
  }

  Future<List<Sale>> fetchSales() async {
    return await database.select(database.sales).get();
  }

  Future<List<SaleItem>> fetchSaleItems(int saleId) async {
    return await (database.select(database.saleItems)
          ..where((tbl) => tbl.saleId.equals(saleId)))
        .get();
  }
}
 