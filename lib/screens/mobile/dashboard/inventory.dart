import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/mobile/header.dart';
import 'package:enapel/widget/mobile/listview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  var inventoryList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

List<Map<String, dynamic>> fakeInventory = [
    {'product': 'Laptop', 'category': 'Electronics', 'price': 50000},
    {'product': 'Chair', 'category': 'Furniture', 'price': 15000},
    {'product': 'Shirt', 'category': 'Clothing', 'price': 2000},
    {'product': 'Refrigerator', 'category': 'Appliance', 'price': 60000},
    {'product': 'Washing Machine', 'category': 'Appliance', 'price': 35000},
    {'product': 'Headphones', 'category': 'Electronics', 'price': 8000},
    {'product': 'Coffee Table', 'category': 'Furniture', 'price': 12000},
    {'product': 'Sofa', 'category': 'Furniture', 'price': 45000},
    {'product': 'TV', 'category': 'Electronics', 'price': 70000},
    {'product': 'Jacket', 'category': 'Clothing', 'price': 8000},
    {'product': 'Microwave', 'category': 'Appliance', 'price': 25000},
    {'product': 'Smartphone', 'category': 'Electronics', 'price': 45000},
    {'product': 'Blender', 'category': 'Appliance', 'price': 10000},
    {'product': 'Shoes', 'category': 'Clothing', 'price': 4000},
    {'product': 'Dining Table', 'category': 'Furniture', 'price': 30000},
    {'product': 'Fan', 'category': 'Appliance', 'price': 5000},
    {'product': 'Air Conditioner', 'category': 'Appliance', 'price': 80000},
    {'product': 'Watch', 'category': 'Electronics', 'price': 15000},
    {'product': 'Bookshelf', 'category': 'Furniture', 'price': 18000},
  ];


  // Simulating an async data fetch
  Future<void> getInventory() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulate delay
    inventoryList.value = fakeInventory; // Assign fake data
    isLoading.value = false;
  }
}

class InventoryScreenMobile extends StatefulWidget {
  const InventoryScreenMobile({Key? key}) : super(key: key);

  @override
  State<InventoryScreenMobile> createState() => _InventoryScreenMobileState();
}

class _InventoryScreenMobileState extends State<InventoryScreenMobile> {
  late InventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryController()); // Initialize the controller
    controller.getInventory(); // Fetch inventory
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBarWidget(
            title: 'Inventory',
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
            }),
        // InventoryScreenMobile Table with Scrollable Content
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.inventoryList.isEmpty) {
              return const Center(child: Text('No items in inventory.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: controller.inventoryList.length,
              itemBuilder: (context, index) {
                final item = controller.inventoryList[index];

                return DynamicListItem(
                  backgroundColor: index.isEven ? Colors.white : Colors.black,
                  leading: const Icon(Icons.inventory, color: Colors.blue),
                  title: Text(
                    item['product'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: index.isEven ? Colors.black : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    item['category'] ?? 'Unknown',
                    style: TextStyle(
                      color: index.isEven ? Colors.black : Colors.white,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₦${item['price'] ?? '0'}',
                        style: TextStyle(
                          color: index.isEven ? Colors.black : Colors.white,
                        ),
                      ),
                      const Icon(Icons.more_vert, color: Colors.grey),
                    ],
                  ),
                  isEven: index.isEven,
                  onTap: () {
                    _showItemDetails(context, item); // Pass context here
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allow the bottom sheet to be sized as per the content
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.5, // Set the height to 50% of the screen height
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product: ${item['product']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
               const SizedBox(
                  height: 24),
              Text('Category: ${item['category']}'),
               const SizedBox(
                  height: 24),
              Text('Price: ₦${item['price']}'),

               Expanded(child: Container()), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    onPressed: () {
                      // Implement edit functionality here
                      print("Edit button pressed");
                    },
                    child: const Text('Edit'),
                  ),
                  CustomButton(
                    onPressed: () {
                      // Implement delete functionality here
                      print("Delete button pressed");
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
