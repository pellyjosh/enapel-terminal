import 'package:enapel/controller/hotel/hotel_controller.dart';
import 'package:enapel/models/category_model.dart';
import 'package:enapel/models/room_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/bottomnav.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/staff/filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
final HotelController hotelController = Get.put(HotelController());


  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
Map<String, String?> activeFilters = {};
  bool isFilterActive = false;

  final Map<String, List<String>> tableHeaders = {
    'Rooms': ['Room', 'Category', 'Price', 'Status', 'Action'],
    'Categories': ['Category', 'Description', 'Price', 'Actions'],
  };

  late Map<String, List<Map<String, String>>> tableData;

  String currentTable = 'Rooms';
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRoom();
    _fetchCategories();
    // tableData = {
    //   'Rooms': roomData,
    //   'Categories': categoryData,
    // };
    // filtedangerData = tableData[currentTable]!;
  }

  Future<void> _fetchRoom() async {
    await hotelController.getRooms();
  }

  Future<void> _fetchCategories() async {
    await hotelController.getCategories();
  }


  void _showFilterDialog() async {
    final isRoomTable = currentTable == 'Rooms';

    final filterOptions = isRoomTable
        ? {
            'Category': hotelController.categories
                .map((cat) => cat.name)
                .toSet()
                .toList(),
            'Status': ['available', 'occupied', 'maintenance'],
          }
        : {
            'Description': hotelController.categories
                .map((cat) => cat.description ?? '')
                .where((desc) => desc.isNotEmpty)
                .toSet()
                .toList(),
          };

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => FilterPopup(
        filterOptions: filterOptions,
        initialSelectedValues: {
          for (var key in filterOptions.keys) key: null,
        },
        title: isRoomTable ? 'Room Filters' : 'Category Filters',
      ),
    );

    if (result != null) {
      setState(() {
        activeFilters = result;
         isFilterActive = true; 
      });

      if (currentTable == "Rooms") {
        hotelController.applyRoomSearchAndFilter(searchQuery, activeFilters);
      } else {
        hotelController.applyCategorySearchAndFilter(
            searchQuery, activeFilters);
      }
    }
  }

  void switchTable(int index) {
    setState(() {
      currentIndex = index;
      currentTable = index == 0 ? 'Rooms' : 'Categories';
      // filtedangerData = tableData[currentTable]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          child: Container(
            width: double.infinity,
            color: AppColor.black.withOpacity(0.8),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "$currentTable Table",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
              onPressed: () => _showFilterDialog(),
              icon: const Icon(Icons.filter_list),
              label: "Filter",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
              ),
            ),
             if (isFilterActive)
              CustomButton(
                 onPressed: () {
                  setState(() {
                    activeFilters = {};
                    searchQuery = '';
                    isFilterActive = false; 
                    searchController.clear();
                  });
                  if (currentTable == "Rooms") {
                    hotelController.applyRoomSearchAndFilter('', {});
                  } else {
                    hotelController.applyCategorySearchAndFilter('', {});
                  }
                },
                icon: Icon(Icons.clear),
                label: "Clear Filter",
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.danger,
                  foregroundColor: AppColor.white,
                ),
              ),
            const SizedBox(width: 8),
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
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });

                  if (currentTable == "Rooms") {
                    hotelController.applyRoomSearchAndFilter(
                        searchQuery, activeFilters);
                  } else {
                   hotelController.applyCategorySearchAndFilter(
                        searchQuery, activeFilters);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              onPressed: () => showAddRowDialog(context, currentTable),
              icon: const Icon(Icons.add),
              label: "Add",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              Container(
                color: AppColor.black.withOpacity(0.9),
                child: Row(
                  children: tableHeaders[currentTable]!
                      .map(
                        (header) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              header,
                              style: TextStyle(
                                color: AppColor.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
             Expanded(
                child: Column(
                  children: [
                    // Static Header
                    // Container(
                    //   color: AppColor.black.withOpacity(0.9),
                    //   child: Row(
                    //     children: tableHeaders[currentTable]!
                    //         .map(
                    //           (header) => Expanded(
                    //             child: Padding(
                    //               padding: const EdgeInsets.all(8.0),
                    //               child: Text(
                    //                 header,
                    //                 style: TextStyle(
                    //                   color: AppColor.white,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         )
                    //         .toList(),
                    //   ),
                    // ),

                    // Table Body
                  Expanded(
                      child: Obx(() {
                        final isRoomTable = currentTable == 'Rooms';
                        final isLoading = isRoomTable
                            ? hotelController.isRoomLoading.value
                            : hotelController.isCategoryLoading.value;
                        final hasError = isRoomTable
                            ? hotelController.roomError.value
                            : hotelController.categoryError.value;
                        final dataList = isRoomTable
                            ? hotelController.filteredRooms
                            : hotelController.filteredCategories;

                        if (isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Server connection error",
                                  style: TextStyle(color: AppColor.danger),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Retry"),
                                  onPressed: () {
                                    if (isRoomTable) {
                                      hotelController.getRooms();
                                    } else {
                                      hotelController.getCategories();
                                    }
                                  },
                                )
                              ],
                            ),
                          );
                        }

                        if (dataList.isEmpty) {
                          return const Center(child: Text("No data found."));
                        }

                        return ListView.builder(
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            final isBlackRow = index % 2 == 0;

                            if (isRoomTable) {
                              final room = dataList[index]
                                  as RoomModel; // Cast to RoomModel
                              return _buildRoomRow(room, isBlackRow);
                            } else {
                              final category = dataList[index]
                                  as CategoryModel; // Cast to CategoryModel
                              return _buildCategoryRow(category, isBlackRow);
                            }   
                          },
                        );
                      }),
                    ),

                  ],
                ),
              ),

              // Expanded(
              //   child: Obx(() =>
              // )
            ],
          ),
        ),
        Container(
          color: AppColor.black, // Overall background color
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BottomNavItem(
                icon: Icons.meeting_room,
                label: 'Rooms',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => switchTable(0),
              ),
              BottomNavItem(
                icon: Icons.category,
                label: 'Categories',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => switchTable(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Show Add/Edit Modal for Rooms or Categories
void showEditModal(dynamic model, String tableType) {
    final Map<String, TextEditingController> controllers = {
      'Name': TextEditingController(text: model.name),
    };

    // Add Room-specific controllers
    String selectedStatus = model is RoomModel ? model.status : 'available';
    if (model is RoomModel) {
      controllers['Price'] =
          TextEditingController(text: model.price.toString());
    }

    // Add Category-specific controllers
    if (model is CategoryModel) {
      controllers['Description'] =
          TextEditingController(text: model.description ?? '');
      controllers['Base Price'] =
          TextEditingController(text: model.basePrice.toString());
    }

    // Handle category selection for Room only
    CategoryModel? selectedCategory = model is RoomModel
        ? hotelController.categories.firstWhere(
            (cat) => cat.name == model.category,
            orElse: () => hotelController.categories.first)
        : null;

    // Dropdown values
    List<String> categoryDropdownItems =
        hotelController.categories.map((cat) => cat.name).toList();
    String selectedCategoryDisplay = selectedCategory != null
        ? selectedCategory.name
        : categoryDropdownItems.first;

    List<String> statusOptions = ['available', 'occupied', 'maintenance'];

    showDialog(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColor.white),
          ),
          backgroundColor: AppColor.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Edit $tableType Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          ...controllers.entries.map((entry) {
                            return SizedBox(
                              width: 250,
                              child: CustomTextField(
                                hintText: entry.key,
                                controller: entry.value,
                                labelTextColor: AppColor.white,
                              ),
                            );
                          }),
                          if (tableType == "Rooms") ...[
                            // Category Dropdown
                            SizedBox(
                              width: 250,
                              child: CustomTextField(
                                labelText: 'Category',
                                backgroundColor: AppColor.white,
                                hintText: 'Select category',
                                dropdownItems: categoryDropdownItems,
                                selectedDropdownValue: selectedCategoryDisplay,
                                onDropdownChanged: (value) {
                                  setState(() {
                                    selectedCategoryDisplay = value!;
                                    selectedCategory =
                                        hotelController.categories.firstWhere(
                                      (cat) => cat.name == value,
                                      orElse: () =>
                                          hotelController.categories.first,
                                    );
                                    controllers['Price']!.text =
                                        selectedCategory!.basePrice.toString();
                                  });
                                },
                              ),
                            ),
                            // Status Dropdown
                            SizedBox(
                              width: 250,
                              child: CustomTextField(
                                labelText: 'Status',
                                hintText: 'Select status',
                                dropdownItems: statusOptions,
                                selectedDropdownValue: selectedStatus,
                                onDropdownChanged: (value) {
                                  setState(() {
                                    selectedStatus = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          CustomButton(
                            onPressed: () async {
                              if (model is RoomModel) {
                                model = model.copyWith(
                                  name: controllers['Name']!.text,
                                  price: double.tryParse(
                                          controllers['Price']!.text) ??
                                      model.price,
                                  status: selectedStatus,
                                  category:
                                      selectedCategory?.name ?? model.category,
                                      
                                );
                                final categoryIdToSend = selectedCategory?.id;
                                await hotelController.updateRoom(model, categoryIdToSend);
                                hotelController.applyRoomSearchAndFilter(
                                    searchQuery, activeFilters);

                              } else if (model is CategoryModel) {
                                model = model.copyWith(
                                  name: controllers['Name']!.text,
                                  description: controllers['Description']!.text,
                                  basePrice: double.tryParse(
                                          controllers['Base Price']!.text) ??
                                      model.basePrice,
                                );

                                await hotelController.editCategory(
                                  model.id,
                                  model.name,
                                  model.description,
                                  model.basePrice,
                                );
                                hotelController.applyRoomSearchAndFilter(
                                    searchQuery, activeFilters);

                              }

                              Navigator.of(context).pop();
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   // SnackBar(
                              //   //   content:
                              //   //       Text("Changes saved for ${model.name}"),
                              //   //   backgroundColor: AppColor.success,
                              //   // ),
                              // );
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

// Delete Room or Category
  void deleteRow(dynamic model, String tableType) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          title: Text(
            "Delete $tableType",
            style: TextStyle(color: AppColor.white),
          ),
          content: Text(
            "Are you sure you want to delete ${model.name}?",
            style: TextStyle(color: AppColor.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: AppColor.white)),
            ),
            CustomButton(
              onPressed: () async {
                if (model is RoomModel) {
                  await hotelController.deleteRoom(model);
                  hotelController.applyRoomSearchAndFilter(
                      searchQuery, activeFilters);

                } else if (model is CategoryModel) {
                  await hotelController.deleteCategory(model.id);
                  hotelController.applyRoomSearchAndFilter(
                      searchQuery, activeFilters);

                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${model.name} has been deleted."),
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

// Show Add Room or Category Dialog
  void showAddRowDialog(BuildContext context, String tableType) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController basePriceController = TextEditingController();

    String selectedCategory = '';
    String selectedStatus = 'Available'; // Default status
    double selectedCategoryPrice = 0.0;
    CategoryModel? selectedCategoryModel;

    if (tableType == "Rooms" && hotelController.categories.isNotEmpty) {
      selectedCategory = hotelController.categories.first.name;
      selectedCategoryModel = hotelController.categories.first;
      selectedCategoryPrice = selectedCategoryModel!.basePrice;
      priceController.text = selectedCategoryPrice.toString();
    } else if (tableType == "Categories") {
      selectedCategory = 'Category A'; // fallback
    }

    await showDialog(
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
                  "Add ${tableType == "Rooms" ? "Room" : "Category"}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Room/Category Name input
                CustomTextField(
                  hintText:
                      tableType == "Rooms" ? "Room Name" : "Category Name",
                  controller: nameController,
                ),
                const SizedBox(height: 10),

                // Room Price
                if (tableType == "Rooms")
                  CustomTextField(
                    hintText: "Price",
                    controller: priceController,
                    enabled: false,
                  ),
                const SizedBox(height: 16),
                // Room Category dropdown
                if (tableType == "Rooms")
                  CustomTextField(
                    hintText: "Category",
                    selectedDropdownValue: selectedCategory,
                    dropdownItems: hotelController.categories
                        .map((cat) => cat.name)
                        .toList(),
                    onDropdownChanged: (value) {
                      selectedCategory = value!;
                      selectedCategoryModel = hotelController.categories
                          .firstWhere((cat) => cat.name == selectedCategory);
                      selectedCategoryPrice = selectedCategoryModel!.basePrice;
                      priceController.text = selectedCategoryPrice.toString();
                    },
                  ),
                  const SizedBox(height: 16),
                // Room Status dropdown
                if (tableType == "Rooms")
                  CustomTextField(
                    hintText: "Status",
                    selectedDropdownValue: selectedStatus,
                    dropdownItems: [
                      'Available',
                      'Occupied',
                      'Maintenance'
                    ],
                    onDropdownChanged: (value) {
                      selectedStatus = value!;
                    },
                  ),

                const SizedBox(height: 16),

                // Category description and base price
                if (tableType == "Categories") ...[
                  CustomTextField(
                    hintText: "Description",
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hintText: "Base Price",
                    controller: basePriceController,
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
          actions: [
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            CustomButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    (tableType == "Rooms" && priceController.text.isEmpty) ||
                    (tableType == "Categories" &&
                        (descriptionController.text.isEmpty ||
                            basePriceController.text.isEmpty))) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("All fields must be filled!"),
                      backgroundColor: AppColor.danger,
                    ),
                  );
                  return;
                }

                if (tableType == "Rooms") {
                  await hotelController.addRoom(
                    name: nameController.text,
                    category: selectedCategoryModel!.id,
                    price: selectedCategoryPrice,
                    status: selectedStatus,
                    tableType: tableType,
                  );
                } else {
                  final basePrice =
                      double.tryParse(basePriceController.text) ?? 0.0;
                  await hotelController.addCategory(
                    nameController.text,
                    descriptionController.text,
                    basePrice,
                  );
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$tableType added successfully!"),
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
 
  Widget _buildRoomRow(RoomModel room, bool isBlackRow) {
    return Container(
      color: isBlackRow ? AppColor.black.withOpacity(0.9) : AppColor.white,
      child: Row(
        children: [
          _buildCell(room.name, isBlackRow),
          _buildCell(room.category, isBlackRow),
          _buildCell('₦${room.price}', isBlackRow),
          _buildCell(room.status, isBlackRow),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColor.primary),
                  onPressed: () => showEditModal(room, currentTable),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColor.danger),
                  onPressed: () => deleteRow(room, currentTable),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryModel category, bool isBlackRow) {
    return Container(
      color: isBlackRow ? AppColor.black.withOpacity(0.9) : AppColor.white,
      child: Row(
        children: [
          _buildCell(category.name, isBlackRow),
          _buildCell(category.description, isBlackRow),
          _buildCell('₦${category.basePrice.toStringAsFixed(2)}', isBlackRow),
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColor.primary),
                  onPressed: () => showEditModal(category, currentTable),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColor.danger),
                  onPressed: () => deleteRow(category, currentTable),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, bool isBlackRow) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            color: isBlackRow ? AppColor.white : AppColor.black,
          ),
        ),
      ),
    );
  }

}
