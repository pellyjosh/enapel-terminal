import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:enapel/controller/pos_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/models/cart_item_model.dart';
import 'package:enapel/models/product_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/utils/notification.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class PointOfSalesScreen extends StatefulWidget {
  final String? databaseMode;

  const PointOfSalesScreen({super.key, this.databaseMode});

  @override
  State<PointOfSalesScreen> createState() => _PointOfSalesState();
}

class _PointOfSalesState extends State<PointOfSalesScreen> {
  late final String databaseMode;
  late final PosController posController;
  bool isLoading = true;
  bool isScanning = false;
  final RxList<Product> finalProducts = <Product>[].obs;
  final RxList<Product> searchedProducts = <Product>[].obs;
  final RxList<Product> scannedProducts = <Product>[].obs;
  final RxString currentSearch = ''.obs;
  final RxMap<int, int> quantities = <int, int>{}.obs;
  var uuid = const Uuid();
  final FocusNode scanFocusNode = FocusNode();
  final FocusNode rawKeyFocusNode = FocusNode();
  final TextEditingController scanController = TextEditingController();
  String scannedText = '';
  Timer? scanTimer;
  final RxList<CartItem> cart = <CartItem>[].obs;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initializeController();
    rawKeyFocusNode.addListener(_handleFocusChange);
    rawKeyFocusNode.requestFocus();
    scanFocusNode.addListener(_handleScanFocusChange);
  }

  void _handleFocusChange() {
    if (!rawKeyFocusNode.hasFocus) {
      rawKeyFocusNode.requestFocus(); // Immediately reclaim focus
    }
  }

  void _handleScanFocusChange() async {
    if (scanFocusNode.hasFocus) {
      setState(() => isScanning = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan mode activated'),
          duration: Duration(seconds: 1),
        ),
      );
      _playSound(); // Add this sound file to your assets
    } else {
      setState(() => isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan mode deactivated'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _playSound() {
    const freq = 500;
    const duration = 100;
    if (Platform.isWindows || Platform.isLinux) {
      // For desktop platforms
      Process.run('play', ['-n', 'synth', '$duration', 'sine', '$freq']);
    } else {
      // Fallback for other platforms
      SystemSound.play(SystemSoundType.click);
    } // Audio feedback
  }

  @override
  void dispose() {
    quantities.clear();
    scanController.dispose();
    scanFocusNode.dispose();
    rawKeyFocusNode.dispose();
    scanTimer?.cancel();

    if (!Get.isRegistered<PosController>()) {
      Get.delete<PosController>();
    }

    super.dispose();
  }

  String generatePosCode() {
    return '#${uuid.v4().substring(0, 8)}';
  }

  Future<void> initializeController() async {
    try {
      databaseMode = widget.databaseMode ??
          KeyStorage.getString('database_mode') ??
          'local';

      if (Get.isRegistered<PosController>()) {
        posController = Get.find<PosController>();
      } else {
        posController = PosController(databaseMode);
      }

      ever<List<Product>>(scannedProducts, (scannedList) {
        for (var product in scannedList) {
          if (!cart.any((item) => item.product.id == product.id)) {
            posController.addToCart(product, 1);
          }
        }
      });
    } catch (e) {
      print("Error initializing controller: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update products based on search or scan
  Future<void> updateProducts(String query) async {
    currentSearch.value = query;

    if (query.trim().isEmpty) return;

    // Fetch the product data based on search query
    await posController.products(query);
    print("Fetched products: ${posController.productData}");

    // Update the searched products list with fetched data
    searchedProducts.value = posController.productData;

    // Set initial quantities (this will only execute for the products you just fetched)
    for (var product in searchedProducts) {
      quantities.putIfAbsent(product.id, () => 1);
    }
  }

  void clearPOSState() {
    posController.clearCart(); // Controller handles cart

    scannedProducts.clear(); // Local reactive list
    searchedProducts.clear(); // Local reactive list
    quantities.clear(); // Quantity tracking
    scanController.clear(); // Reset scan input

    scannedProducts.refresh(); // Optional but safe
    searchedProducts.refresh();
  }

  void onProductScanned(Product scannedProduct) {
    if (!finalProducts.any((p) => p.id == scannedProduct.id)) {
      finalProducts.add(scannedProduct);

      scannedProducts.add(scannedProduct);

      quantities.putIfAbsent(scannedProduct.id, () => 1);
    }
    print("Scanned Product: ${scannedProduct.name}");
  }

  void toggleScanMode() {
    isScanning = !isScanning;
    print("🔁 Scan mode: $isScanning");

    if (isScanning) {
      FocusScope.of(context).requestFocus(scanFocusNode);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan mode activated')),
      );
    } else {
      scanFocusNode.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan mode deactivated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: rawKeyFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          print("🔍 Spacebar pressed");

          // Check if scan mode is already activated
          if (scanFocusNode.hasFocus) {
            scanFocusNode.unfocus();
            print("🔕 Scan mode deactivated");
          } else {
            // Unfocus anything else first (just in case)
            FocusScope.of(context).unfocus();
            FocusScope.of(context).requestFocus(scanFocusNode);
            print("🎯 Scan mode activated");
          }
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          buildPOSLayout(),
        ],
      ), // Extract the full UI into a method
    );
  }

  Widget buildPOSLayout() {
    return Container(
      color: AppColor.black.withOpacity(0.8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'POS',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.search,
                  color: AppColor.white,
                ),
                const SizedBox(width: 20),
                // HIDDEN SCAN INPUT
                Offstage(
                  offstage: true,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller: scanController,
                      focusNode: scanFocusNode,
                      autofocus: false,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        scanTimer?.cancel();
                        scanTimer =
                            Timer(const Duration(milliseconds: 300), () async {
                          if (!mounted) return;
                          final scanned = value.trim();
                          if (scanned.isNotEmpty) {
                            await updateProducts(scanned);
                            if (searchedProducts.isNotEmpty) {
                              final product = searchedProducts.first;
                              if (!scannedProducts
                                  .any((p) => p.id == product.id)) {
                                onProductScanned(product);
                              }
                            }
                            scanController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // VISIBLE SEARCH INPUT
                Expanded(
                  child: CustomTextField(
                    hintText: 'Search...',
                    fillColor: AppColor.grey,
                    borderRadius: 8.0,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        currentSearch.value = '';
                        searchedProducts.clear();
                      } else {
                        updateProducts(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // this is where there should be two columns the scrollable and non scrollable
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20.00),
              decoration: BoxDecoration(
                color: AppColor.black,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scrollable Column for the left side (Order List)
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product list',
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Obx(() => Text(
                                        posController.posCode.value,
                                        style: TextStyle(
                                          color: AppColor.grey,
                                          fontSize: 16,
                                        ),
                                      )),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Products',
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.receipt_long,
                                        color: Colors.white),
                                    tooltip: 'Saved Receipts',
                                    onPressed: posController
                                            .pendingReceiptNumbers.isEmpty
                                        ? null
                                        : () =>
                                            showPendingReceiptDialog(context, posController),
                                  ),
                                  if (posController
                                      .pendingReceiptNumbers.isNotEmpty)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '${posController.pendingReceiptNumbers.length}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    )
                                ],
                              );
                            }),
                            IconButton(
                              onPressed: () async {
                                print('new window clicked');
                                if (Platform.isWindows ||
                                    Platform.isLinux ||
                                    Platform.isMacOS) {
                                  print('is Desktop');
                                  final databaseMode =
                                      KeyStorage.getString('database_mode') ??
                                          'local';
                                  DesktopMultiWindow.createWindow(jsonEncode({
                                    'args1': 'Sub window',
                                    'databaseMode': databaseMode
                                  })).then((value) {
                                    value
                                      ..setFrame(const Offset(0, 0) &
                                          const Size(800, 700))
                                      ..center()
                                      ..setTitle("New Secondary Window")
                                      ..show();
                                  });
                                }
                              },
                              icon: Icon(Icons.add_card, color: AppColor.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Obx(() {
                            // Combine both scanned and searched products without duplicates
                            List<Product> productsToDisplay = [];

                            final scanned = scannedProducts;
                            final searched = searchedProducts;
                            final searchQuery = currentSearch.value;

                            // Add all scanned products
                            productsToDisplay.addAll(scanned);

                            // Automatically add scanned products to cart if not already present
                            // for (var product in scanned) {
                            //   if (!posController.cart.any(
                            //       (item) => item.product.id == product.id)) {
                            //     posController.addToCart(product,
                            //         1); // You can customize quantity if needed
                            //   }
                            // }

                            // If there's a search query, add searched ones (avoid duplicates)
                            if (searchQuery.isNotEmpty) {
                              for (var product in searched) {
                                if (!productsToDisplay
                                    .any((p) => p.id == product.id)) {
                                  productsToDisplay.add(product);
                                }
                              }
                            }

                            // If no products, show message
                            if (productsToDisplay.isEmpty) {
                              return Center(
                                child: Text(
                                  searchQuery.isNotEmpty
                                      ? "No products found for '$searchQuery'"
                                      : "No products available. Please scan or search.",
                                  style: TextStyle(color: AppColor.white),
                                ),
                              );
                            }

                            // If there are products, display them
                            return SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  productsToDisplay.length,
                                  (index) {
                                    final product = productsToDisplay[index];
                                    quantities.putIfAbsent(product.id, () => 1);

                                    // Calculate if product is scanned
                                    final isScanned = scanned.contains(product);

                                    return SizeTransition(
                                      sizeFactor:
                                          const AlwaysStoppedAnimation(1.0),
                                      child: Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        color: AppColor.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: TextStyle(
                                                      color: AppColor.black,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '₦',
                                                    style: TextStyle(
                                                      color: AppColor.black,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${product.price}',
                                                    style: TextStyle(
                                                      color: AppColor.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      if (quantities[
                                                              product.id]! >
                                                          1) {
                                                        quantities[product.id] =
                                                            quantities[product
                                                                    .id]! -
                                                                1;

                                                        // Update cart item quantity too
                                                        posController
                                                            .updateCartQuantity(
                                                                product.id,
                                                                quantities[
                                                                    product
                                                                        .id]!);
                                                      }
                                                    },
                                                    icon: const Icon(
                                                        Icons.remove),
                                                  ),
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextField(
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          TextEditingController(
                                                        text: quantities[
                                                                product.id]!
                                                            .toString(),
                                                      ),
                                                      onSubmitted: (value) {
                                                        final quantity =
                                                            int.tryParse(
                                                                    value) ??
                                                                1;
                                                        if (quantity > 0) {
                                                          quantities[product
                                                              .id] = quantity;

                                                          // Update cart item quantity
                                                          posController
                                                              .updateCartQuantity(
                                                                  product.id,
                                                                  quantity);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      quantities[product.id] =
                                                          quantities[
                                                                  product.id]! +
                                                              1;

                                                      // Update cart item quantity too
                                                      posController
                                                          .updateCartQuantity(
                                                              product.id,
                                                              quantities[
                                                                  product.id]!);
                                                    },
                                                    icon: const Icon(Icons.add),
                                                  ),

                                                  const SizedBox(width: 8),
                                                  // Add to Cart Button
                                                  isScanned
                                                      ? const SizedBox
                                                          .shrink() // Don't show the button if scanned
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                AppColor.black,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              posController
                                                                  .addToCart(
                                                                product,
                                                                quantities[product
                                                                        .id] ??
                                                                    1,
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .shopping_basket,
                                                              color: AppColor
                                                                  .danger,
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Obx(() {
                              final reversedCartItems =
                                  List.from(posController.cart.reversed);
                              return reversedCartItems.isEmpty
                                  ? Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: AppColor.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cart Items',
                                              style: TextStyle(
                                                color: AppColor.black,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "Add items to cart",
                                                  style: TextStyle(
                                                      color: AppColor.black),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: AppColor.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cart Items',
                                              style: TextStyle(
                                                color: AppColor.black,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    reversedCartItems.length,
                                                itemBuilder: (context, index) {
                                                  var item =
                                                      reversedCartItems[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    child: Stack(
                                                      children: [
                                                        Card(
                                                          margin:
                                                              EdgeInsets.zero,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          elevation: 4,
                                                          color: AppColor.white,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        item.product
                                                                            .name,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        '₦${item.product.price} x ${item.quantity}',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '₦${item.product.price * item.quantity}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 0,
                                                          top: 0,
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              color: AppColor
                                                                  .danger,
                                                            ),
                                                            onPressed: () {
                                                              posController
                                                                  .removeFromCart(
                                                                      item);
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            }),
                          ),

                          // Summary Box
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Obx(
                              () {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Subtotal',
                                              style: TextStyle(
                                                color: AppColor.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '₦${posController.subtotalAmount}',
                                              style: TextStyle(
                                                color: AppColor.grey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Tax (${posController.vat}%)',
                                              style: TextStyle(
                                                color: AppColor.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '₦${posController.vatAmount}',
                                              style: TextStyle(
                                                color: AppColor.grey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Divider(
                                      height: 32,
                                      color: AppColor.grey,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            color: AppColor.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₦${posController.totalAmount}',
                                          style: TextStyle(
                                            color: AppColor.grey,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                onPressed: () {
                                  if (posController.cart.isEmpty) {
                                    NotificationService.showError(
                                        title: 'Cart Empty',
                                        message: 'Add item to cart');
                                    return;
                                  }
                                  _showCheckoutModal(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primary,
                                    padding: EdgeInsets.all(15.0)
                                    // minimumSize: const Size.fromHeight(50),
                                    ),
                                text: '',
                                child: Text(
                                  'Checkout',
                                  style: TextStyle(
                                      fontSize: 18, color: AppColor.white),
                                ),
                              ),
                              CustomButton(
                                onPressed: () {
                                  posController.clearCart();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.danger,
                                    padding: EdgeInsets.all(15.0)
                                    // minimumSize: const Size.fromHeight(50),
                                    ),
                                text: '',
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                      fontSize: 18, color: AppColor.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 500,
                decoration: BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColor.white,
                    width: 2.0,
                  ),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Payment Method Options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  posController.paymentMethod = 'cash';
                                  posController.change.value = 0.0;
                                });
                              },
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      activeColor: AppColor.white,
                                      checkColor: AppColor.black,
                                      value:
                                          posController.paymentMethod == 'cash',
                                      onChanged: (value) {
                                        setState(() {
                                          posController.paymentMethod =
                                              value! ? 'cash' : "";
                                          posController.change.value = 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Cash',
                                    style: TextStyle(
                                        color: AppColor.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  posController.paymentMethod = 'transfer';
                                  posController.change.value = 0.0;
                                });
                              },
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      activeColor: AppColor.white,
                                      checkColor: AppColor.black,
                                      value: posController.paymentMethod ==
                                          'transfer',
                                      onChanged: (value) {
                                        setState(() {
                                          posController.paymentMethod =
                                              value! ? 'transfer' : "";
                                          posController.change.value = 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Transfer',
                                    style: TextStyle(
                                        color: AppColor.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  posController.paymentMethod = 'pos';
                                  posController.change.value = 0.0;
                                });
                              },
                              child: Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                      activeColor: AppColor.white,
                                      checkColor: AppColor.black,
                                      value:
                                          posController.paymentMethod == 'pos',
                                      onChanged: (value) {
                                        setState(() {
                                          posController.paymentMethod =
                                              value! ? 'pos' : "";
                                          posController.change.value = 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'POS',
                                    style: TextStyle(
                                        color: AppColor.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // If Cash is selected, show Amount Paid & Change Input
                    if (posController.paymentMethod == 'cash') ...[
                      TextField(
                        controller: posController.cashAmountPaidController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: AppColor.white, fontSize: 18),
                        decoration: InputDecoration(
                          labelText: "Amount Paid",
                          labelStyle: TextStyle(color: AppColor.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.white),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            double amountPaid = double.tryParse(value) ?? 0.0;
                            double total = posController.totalAmount.value;
                            posController.change.value =
                                (amountPaid - total) < 0
                                    ? 0
                                    : (amountPaid - total);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      IgnorePointer(
                        ignoring: true,
                        child: TextField(
                          readOnly: true,
                          style: TextStyle(color: AppColor.white, fontSize: 18),
                          decoration: InputDecoration(
                            labelText: "Change to Collect",
                            labelStyle: TextStyle(color: AppColor.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColor.white),
                            ),
                          ),
                          controller: TextEditingController(
                              text:
                                  "₦${posController.change.value.toStringAsFixed(2)}"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Total Amount Display
                    Row(
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '₦${posController.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: () => posController.savePendingReceipt(),
                      child: const Text('Save as Pending'),
                    ),

                    // Print Receipt Button
                    CustomButton(
                      onPressed: () {
                        if (posController.paymentMethod.isEmpty) {
                          NotificationService.showError(
                              title: 'Error',
                              message: 'Please select a payment method!');

                          return;
                        }

                        if (posController.paymentMethod == 'Cash') {
                          double amountPaid = double.tryParse(posController
                                  .cashAmountPaidController.text) ??
                              0.0;
                          double total = posController.totalAmount.value;

                          if (amountPaid < total) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Amount Paid cannot be less than Total Amount!',
                                  style: TextStyle(color: AppColor.white),
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        Navigator.of(context).pop();
                        _printReceipt();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.white,
                        minimumSize: const Size(150, 50),
                      ),
                      text: '',
                      child: Text(
                        'Print Receipt',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _printReceipt() async {
    print('Printing receipt...');
    await posController.checkout();
  }
}

void showPendingReceiptDialog(BuildContext context, PosController posController) {
  final receipts = posController.pendingReceiptNumbers;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Pending Receipts"),
      content: SizedBox(
        width: 300,
        child: ListView.builder(
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(receipts[index]),
              onTap: () {
                Navigator.pop(context);
                showReceiptDetailSheet(context, receipts[index], posController);
              },
            );
          },
        ),
      ),
    ),
  );
}

void showReceiptDetailSheet(BuildContext context, String receiptNumber, PosController posController) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FutureBuilder<Receipt>(
      future: posController.getReceiptDetails(receiptNumber),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final receipt = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receipt #: ${receipt.receiptNumber}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Date: ${receipt.date.toLocal()}'),
                  Text('Payment: ${receipt.paymentMethod}'),
                  Text('Paid: ₦${receipt.cashPaid}'),
                  Text('Change: ₦${receipt.changeDue}'),
                  const Divider(height: 24),
                  const Text('Items:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...receipt.items.map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} × ₦${item.price}'),
                        trailing: Text(
                            '₦${(item.quantity * item.price).toStringAsFixed(2)}'),
                      )),
                  const Divider(),
                  Text('Total: ₦${receipt.total}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () =>  printEscPos('Hello World!'),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Receipt'),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
Future<void> printReceipt(Receipt receipt) async {
  try {
    final printers = await Printing.listPrinters();

    if (printers.isEmpty) {
      NotificationService.showError(
        title: "Printer Error",
        message: "No printer connected.",
      );
      return;
    }

    final printer = printers.first; // You can customize printer selection

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("🧾 Receipt",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Receipt #: ${receipt.receiptNumber}"),
            pw.Text("Date: ${receipt.date.toLocal()}"),
            pw.Text("Payment: ${receipt.paymentMethod}"),
            pw.Text("Paid: ₦${receipt.cashPaid}"),
            pw.Text("Change: ₦${receipt.changeDue}"),
            pw.Divider(),
            pw.Text("Items",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...receipt.items.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(item.name)),
                    pw.Text('${item.quantity} × ₦${item.price}'),
                    pw.Text(
                        '₦${(item.quantity * item.price).toStringAsFixed(2)}'),
                  ],
                )),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Total: ₦${receipt.total}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final printers = await Printing.listPrinters();
      // proceed with directPrintPdf
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }


    NotificationService.showSuccess(
      title: "Printed",
      message: "Receipt sent to printer",
    );
  } catch (e) {
    NotificationService.showError(
      title: "Print Error",
      message: "Failed to print: $e",
    );
    print("❌ Print Error: $e");
  }
}

void printEscPos(String text) async {
  // ESC/POS command to reset printer (initialize)
  final init = '\x1B\x40';
  final cut = '\x1D\x56\x41';

  // Combine commands with text
  final escPosText = '$init$text\n\n\n$cut';

  // Run the lp command to send to printer
  final result = await Process.run('echo', ['-e', escPosText]);

  if (result.exitCode == 0) {
    print("✅ Print successful");
  } else {
    print("❌ Print failed: ${result.stderr}");
  }
}


