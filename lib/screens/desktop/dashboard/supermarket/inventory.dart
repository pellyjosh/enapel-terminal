import 'package:enapel/controller/auth_controller.dart';
import 'package:enapel/controller/inventory_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/helper/date_time_helper.dart';
import 'package:enapel/models/database/inventory_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryState();
}

class _InventoryState extends State<InventoryScreen> {
  late final InventoryController controller;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();


  @override
  void initState() {
    super.initState();
    controller = Get.put(InventoryController());
    controller.getInventory();
  }

@override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        SafeArea(
          child: Container(
            width: double.infinity,
            color: AppColor.black.withOpacity(0.8),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "INVENTORY",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Filter + Search Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CustomButton(
            //   onPressed: () => showInventoryFilterDialog(
            //       context), // ✅ now opens filter dialog
            //   icon: const Icon(Icons.filter_list),
            //   label: "Filter",
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColor.black.withOpacity(0.8),
            //     foregroundColor: AppColor.white,
            //     minimumSize: const Size(100, 40),
            //   ),
            // ),
            const SizedBox(width: 5),
            Expanded(
              child: CustomTextField(
                hintText: 'Search...',
                isSearchField: true,
                fillColor: AppColor.white,
                borderRadius: 8.0,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                onChanged: (value) {
                  controller.searchInventory(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            CustomButton(
              onPressed: () => showAddInventoryDialog(context),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Inventory Table
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(), // ✅ loading indicator
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(
                 "Server connection error",
                  style: TextStyle(color: AppColor.danger),
                ),
                 const SizedBox(height: 12),
                  CustomButton(
                    onPressed: ()=> controller.getInventory(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary),
                    child:
                        Text("Retry", style: TextStyle(color: AppColor.white)),
                  )],
                ),
              );
            }

            final inventory = controller.inventoryData;

            if (inventory.isEmpty) {
              return const Center(
                child: Text("No inventory data found."),
              );
            }

            return Column(
              children: [
                // Header Row
                Container(
                  color: AppColor.black,
                  child: Row(
                    children: [
                      _buildCell('ID', true),
                      _buildCell('Name', true),
                      _buildCell('Price', true),
                      _buildCell('Stock Level', true),
                      _buildCell('Reorder Status', true),
                      _buildCell('Last Updated', true),
                      _buildCell('Actions', true),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(
                        inventory.length,
                        (index) {
                          final item = inventory[index];
                          final isEvenRow = index % 2 == 0;

                          return Container(
                            color: isEvenRow ? AppColor.black : AppColor.white,
                            child: Row(
                              children: [
                                _buildCell('${index + 1}', isEvenRow),
                                _buildCell(item.name, isEvenRow),
                                _buildCell('\₦${item.price.toStringAsFixed(2)}',
                                    isEvenRow),
                                _buildCell('${item.quantity} pcs', isEvenRow),
                                _buildCell(
                                  item.quantity < 10 ? 'Reorder' : 'Sufficient',
                                  isEvenRow,
                                  textColor: item.quantity < 10
                                      ? AppColor.danger
                                      : AppColor.success,
                                ),
                                _buildCell(
                                  DateHelper.formatDate(item.updatedAt),
                                  isEvenRow,
                                ),
                                _buildCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: AppColor.primary),
                                        onPressed: () {
                                          showEditInventoryDialog(
                                              context, item);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: AppColor.danger),
                                        onPressed: () {
                                          showDeleteInventoryDialog(
                                              context, item);
                                        },
                                      ),
                                    ],
                                  ),
                                  isEvenRow,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }


 Widget _buildCell(dynamic text, bool isEvenRow, {Color? textColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: isEvenRow ? AppColor.black.withOpacity(0.1) : AppColor.white,
        child: text is String
            ? Text(
                text,
                style: TextStyle(
                  color: textColor ?? (isEvenRow ? AppColor.white : AppColor.black),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : text, // If it's a widget, render it directly
      ),
    );
  }

  void showAddInventoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColor.white, width: 2),
          ),
          contentPadding: const EdgeInsets.all(40),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add Inventory Item",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.white,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(hintText: "Name", controller: nameController),
                const SizedBox(height: 10),
                CustomTextField(
                    hintText: "Quantity", controller: quantityController),
                const SizedBox(height: 10),
                CustomTextField(hintText: "Price", controller: priceController),
                const SizedBox(height: 10),
               
              ],
            ),
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            CustomButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    quantityController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("All fields must be filled!"),
                      backgroundColor: AppColor.danger,
                    ),
                  );
                  return;
                }

                await controller.addItem(
                  InventoryModel(
                    id: 0, // or generate a suitable ID based on your logic
                    name: nameController.text,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );


                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Inventory item added!"),
                    backgroundColor: AppColor.success,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  
  void showDeleteInventoryDialog(BuildContext context, InventoryModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColor.white, width: 2),
          ),
          title: Text(
            "Delete Inventory Item",
            style: TextStyle(color: AppColor.white),
          ),
          content: Text(
            "Are you sure you want to delete '${item.name}'?",
            style: TextStyle(color: AppColor.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: AppColor.white)),
            ),
            CustomButton(
              onPressed: () async {
                if (item.id != null) {
                  await controller.deleteItem(item.id!);
                } else {
                  print('⚠️ Cannot delete: item has no ID');
                  // Optionally show an error/snackbar
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item.name} has been deleted."),
                    backgroundColor: AppColor.success,
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
void showEditInventoryDialog(BuildContext context, InventoryModel item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColor.white, width: 2),
          ),
          contentPadding: const EdgeInsets.all(40),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Inventory Item",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.white,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(hintText: "Name", controller: nameController),
                const SizedBox(height: 10),
                CustomTextField(
                    hintText: "Quantity", controller: quantityController),
                const SizedBox(height: 10),
                CustomTextField(hintText: "Price", controller: priceController),
                const SizedBox(height: 10),
                
              ],
            ),
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            CustomButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    quantityController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("All fields must be filled!"),
                      backgroundColor: AppColor.danger,
                    ),
                  );
                  return;
                }

               final updatedItem = InventoryModel(
                  id: item.id,
                  name: nameController.text,
                  quantity:
                      int.tryParse(quantityController.text) ?? item.quantity,
                  price: double.tryParse(priceController.text) ?? item.price,
                  createdAt: item.createdAt,
                  updatedAt: DateTime.now(), // or item.updatedAt
                  staffId: item.staffId,
                );
                await controller.updateItem(updatedItem);


                await controller.updateItem(updatedItem);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Inventory item updated!"),
                    backgroundColor: AppColor.success,
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


}
