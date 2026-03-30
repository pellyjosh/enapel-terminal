import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/models/cart_item_model.dart';
import 'package:enapel/models/product_model.dart';
import 'package:enapel/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:enapel/services/window_protocol.dart';

class PosController extends GetxController {
  final int windowId;
  late final EnapelDatabase database;
  bool _isServerMode = false;
  Future<bool> get isServerMode async => _isServerMode;
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
  final RxList<int> activeWindowIds = <int>[0].obs; // Master starts at 0
  
  void removeWindowId(int id) {
    if (id != 0) { // Never remove the master window
      activeWindowIds.remove(id);
      print("Removed Window ID: $id. Active IDs: $activeWindowIds");
    }
  }


  final String? injectedServerIp;
  final String? injectedUserToken;


  PosController(String databaseMode, {this.injectedServerIp, this.injectedUserToken, this.windowId = 0}) {
    print('Window ID: $windowId, Database mode: $databaseMode');
    _isServerMode = (databaseMode == 'server');

    if (databaseMode == 'local') {
      if (!Get.isRegistered<EnapelDatabase>()) {
        Get.put(EnapelDatabase(openLocalConnection()));
      }
      database = Get.find<EnapelDatabase>();
    } else {
      // Only initialize ApiService in the primary window (Window ID 0)
      if (windowId == 0) {
        if (!Get.isRegistered<ApiService>()) {
          Get.put(ApiService(
            injectedServerIp: injectedServerIp,
            injectedUserToken: injectedUserToken,
          ));
        }
        apiService = Get.find<ApiService>();
      }
    }
    generatePosCode();
  }

  void generatePosCode() async {
    // if (posCode.value.isEmpty) {
    if (await isServerMode) {
      // MIRROR LOGIC
      if (windowId != 0) {
        final result = await WindowProtocol.invokeMaster('generatePosCode', null);
        if (result != null) {
          posCode.value = result.toString();
          print("POS Code fetched via Mirror Protocol.");
        }
        return;
      }

      // MASTER LOGIC
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

      // MIRROR LOGIC
      if (windowId != 0) {
        final result = await WindowProtocol.invokeMaster('checkout', orderData);
        if (result != null) {
          final response = result as Map<String, dynamic>;
          if (response['success'] == true) {
            NotificationService.showSuccess(title: 'Success', message: 'Checkout Successful (Mirrored)');
            clearCart();
          } else {
            print("Mirror Checkout failed: ${response['error']}");
          }
        }
        return;
      }

      // MASTER LOGIC
      try {
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

    // MIRROR LOGIC
    if (windowId != 0) {
      final result = await WindowProtocol.invokeMaster('savePendingReceipt', payload);
      if (result != null) {
        final response = result as Map<String, dynamic>;
        if (response['success'] == true) {
          pendingReceiptNumbers.add(posCodeValue);
          NotificationService.showSuccess(title: 'Saved', message: 'Receipt saved as pending (Mirrored)');
          clearCart();
        }
      }
      return;
    }

    // MASTER LOGIC
    try {
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
    // MIRROR LOGIC
    if (windowId != 0) {
      final result = await WindowProtocol.invokeMaster('getReceiptDetails', receiptNumber);
      if (result != null) {
        final response = result as Map<String, dynamic>;
        if (response['success'] == true && response['receipt'] != null) {
          return Receipt.fromJson(response['receipt']);
        }
      }
      throw Exception("Mirrored receipt fetch failed");
    }

    // MASTER LOGIC
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
      // MIRROR LOGIC: If we are in a sub-window, request data from the master window
      if (windowId != 0) {
        final result = await WindowProtocol.invokeMaster('searchProducts', query);
        if (result != null) {
          final List<dynamic> data = result as List<dynamic>;
          productData.assignAll(data.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList());
          print("Products fetched via Mirror Protocol.");
        }
        return;
      }

      // MASTER LOGIC: Regular API call
      try {
        final url = query.isNotEmpty
            ? '${Config.getProduct}?search=$query'
            : Config.getProduct;

        final response = await apiService.get(url);

        if (response['success'] == true) {
          List<dynamic> data = response['data'];
          productData.assignAll(data.map((e) => Product.fromJson(e)).toList());
          print("Products fetched successfully from Server.");
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
 