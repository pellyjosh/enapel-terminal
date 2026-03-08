import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:enapel/controller/pos_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/mobile/header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointOfSalesScreenMobile extends StatefulWidget {
  final PosController? posController;
  const PointOfSalesScreenMobile({super.key , this.posController});

  @override
  State<PointOfSalesScreenMobile> createState() => _PointOfSalesScreenMobileState();
}

class _PointOfSalesScreenMobileState extends State<PointOfSalesScreenMobile> {
    late final String databaseMode;
  late final PosController posController;
  bool isLoading = true;
  final RxMap<int, int> quantities = <int, int>{}.obs;
  // final RxList<CartItem> cartItems = <CartItem>[].obs;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void dispose() {
    quantities.clear();

    if (widget.posController == null) {
      Get.delete<PosController>();
    }

    super.dispose();
  }

  Future<void> initializeController() async {
    try {
      // Use the provided PosController if available; otherwise, initialize a new one
      if (widget.posController != null) {
        posController = widget.posController!;
        KeyStorage.init();
      } else {
        final databaseMode = KeyStorage.getString('database_mode') ?? 'local';
        posController = Get.put(PosController(databaseMode));
      }

      await posController.products('');
      // Initialize quantities for each product
      for (var product in posController.productData) {
        quantities[product.id] = 1;
      }
    } catch (e) {
      print("Error initializing controller: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
   Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = Get.width;

    return Container(
      color: AppColor.black.withOpacity(0.8),
      child: Column(
        children: [
          CustomAppBarWidget(
            title: 'Sales',
            menuIcon: Icons.menu,
            searchIcon: Icons.search,
            barcodeIcon: Icons.qr_code_scanner,
            listIcon: Icons.list,
            onMenuTap: () {
              print('Menu tapped');
            },
            onSearchTap: () {
              // Trigger search logic
            },
            onBarcodeTap: () {
              print('Barcode tapped');
            },
            onListTap: () {
              print('List tapped');
            }
          ),
          // this is where there should be two columns the scrollable and non scrollable
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20.00),
              decoration: BoxDecoration(
                color: AppColor.black,

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scrollable Column for the left side (Order List)
                  Expanded(
                    flex: 2,
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
                                  Text(
                                    '#647687564',
                                    style: TextStyle(
                                      color: AppColor.grey,
                                      fontSize: 16,
                                    ),
                                  ),
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
                            IconButton(
                              onPressed: () async {
                                print('new window clicked');
                                if (Platform.isWindows ||
                                    Platform.isLinux ||
                                    Platform.isMacOS) {
                                  print('is Desktop');
                                  DesktopMultiWindow.createWindow(
                                          jsonEncode({'args1': 'Sub window'}))
                                      .then((value) {
                                    value
                                      ..setFrame(const Offset(0, 0) &
                                          const Size(700, 700))
                                      ..center()
                                      ..setTitle("New Secondary Window")
                                      ..show();
                                  });
                                }
                              },
                              icon: Icon(Icons.add_card, color: AppColor.white),
                            ),
                             Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.shopping_cart,
                                        color: AppColor.white),
                                    onPressed: () {
                                      _showCheckoutBottomSheet(context);
                                    },
                                  ),
                                  Obx(() {
                                    final cartItemCount =
                                        posController.cart.length;
                                    return cartItemCount > 0
                                        ? Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColor.danger,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                cartItemCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox
                                            .shrink(); // No badge if the cart is empty
                                  }),
                                ],
                              ),

                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Obx(() {
                            final products = posController.productData;
                            return products.isEmpty
                                ? Center(
                                    child: Text(
                                    "No data available",
                                    style: TextStyle(color: AppColor.white),
                                  ))
                      : SingleChildScrollView(
  child: Column(
    children: List.generate(products.length, (index) {
      final product = products[index];
      return SizeTransition(
        sizeFactor: const AlwaysStoppedAnimation(1.0),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: AppColor.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Product information column with flexible width
                Flexible(
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: AppColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₦',
                            style: TextStyle(
                              color: AppColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${product.price}',
                              style: TextStyle(
                                color: AppColor.grey,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Decrease quantity button
                    IconButton(
                      onPressed: () {
                        if (quantities[product.id]! > 1) {
                          quantities[product.id] = quantities[product.id]! - 1;
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    // Quantity TextField
                    SizedBox(
                      width: 50,
                      child: TextField(
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8),
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: quantities[product.id].toString(),
                        ),
                        onSubmitted: (value) {
                          final quantity = int.tryParse(value) ?? 1;
                          if (quantity > 0) {
                            quantities[product.id] = quantity;
                          }
                        },
                      ),
                    ),
                    // Increase quantity button
                    IconButton(
                      onPressed: () {
                        quantities[product.id] = quantities[product.id]! + 1;
                      },
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 8),
                    // Add to cart button
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          posController.addToCart(
                            product,
                            quantities[product.id] ?? 1,
                          );
                        },
                        icon: Icon(
                          Icons.shopping_basket,
                          color: AppColor.danger,
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
    }),
  ),
);

                      }),
                        ),
                      ],
                    ),
                  ),

                 // Non-Scrollable Column for Summary and Action Buttons
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
void _showCheckoutBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (_, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Checkout",
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: AppColor.black),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    final cartItems = posController.cart;
                    return cartItems.isEmpty
                        ? Center(
                            child: Text(
                              "No items in the cart",
                              style: TextStyle(color: AppColor.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return ListTile(
                                title: Text(item.product.name),
                                subtitle: Text(
                                  '₦${item.product.price} x ${item.quantity}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₦${item.product.price * item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: AppColor.danger,
                                      ),
                                      onPressed: () {
                                        posController.removeFromCart(item);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  }),
                ),

                // Summary Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    color: AppColor.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Tax (${posController.vat}%)',
                                  style: TextStyle(
                                    color: AppColor.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                        const SizedBox(height: 5),
                        Divider(
                          height: 32,
                          color: AppColor.grey,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                      ],
                    );
                  }),
                ),

                // Checkout and Clear Buttons
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showCheckoutModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding: const EdgeInsets.all(15.0),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        posController.clearCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.danger,
                        padding: const EdgeInsets.all(15.0),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showCheckoutModal(BuildContext context) {
    String? selectedPaymentMethod;
    double totalAmount = 1234.56;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Responsive width
                  decoration: BoxDecoration(
                    color: AppColor.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColor.white,
                      width: 2.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Payment Method Section
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
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 10.0,
                        children: ['Cash', 'Transfer', 'POS'].map((method) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedPaymentMethod = method;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    activeColor: AppColor.white,
                                    checkColor: AppColor.black,
                                    value: selectedPaymentMethod == method,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaymentMethod =
                                            value! ? method : null;
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  method,
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Total Amount Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.white,
                            ),
                          ),
                          Text(
                            '\$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Print Receipt Button
                      Center(
                        child: CustomButton(
                          onPressed: () {
                            if (selectedPaymentMethod == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColor.white,
                                  content: Text(
                                    'Please select a payment method!',
                                    style: TextStyle(color: AppColor.black),
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).pop();
                            _printReceipt();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.white,
                            minimumSize: const Size(200, 50),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _printReceipt() {
    print('Printing receipt...');
  }

}