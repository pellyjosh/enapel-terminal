import 'package:enapel/controller/hotel/hotel_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/models/category_model.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HotelHomeScreen extends StatefulWidget {
  final dynamic navigateToDashboardContent;

  const HotelHomeScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<HotelHomeScreen> createState() => _HotelDashState();
}

class _HotelDashState extends State<HotelHomeScreen> {
  final HotelController hotelController = Get.put(HotelController());
  final TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserInformation();
    await hotelController.getRooms(
        autoAssignToFiltered: false); // ← Don't auto-show rooms
    await Future.wait([
      hotelController.getRooms(),
      hotelController.getCategories(),
      hotelController
          .fetchRoomStatistics(DateTime.now().toIso8601String().split('T')[0]),
    ]);
  }

  void _searchRooms(String query) {
    final lower = query.toLowerCase();
    hotelController.filteredRooms.value = hotelController.rooms.where((room) {
      return room.name.toLowerCase().contains(lower) ||
             room.category.toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> _loadUserInformation() async {
    try {
      final userMap = await KeyStorage.getMap('user');
      if (userMap != null) {
        setState(() {
          user = userMap;
          isAdmin = (userMap['isAdmin'] is bool)
              ? userMap['isAdmin']
              : userMap['isAdmin'] == 1;
        });
      }
    } catch (e) {
      print('Error loading user information: $e');
    }
  }

  void handleMenuSelection(String value) {
    if (value == 'profile') {
      // Handle profile settings action
    } else if (value == 'logout') {
      // Handle log-out action
    }
  }

  Widget _buildShimmerCard(double cardWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: cardWidth,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getPriceFromCategory(String categoryName) {
    final category = hotelController.categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () =>
          CategoryModel(id: 0, name: '', description: '', basePrice: 0),
    );
    return category.basePrice.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Header(
          user: user!,
          onMenuSelected: handleMenuSelection,
        ),
        SizedBox(height: Get.height * 0.02),
        // Card Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double minCardWidth = 300.0;
              double spacing = 16.0;

              int cardsPerRow =
                  (screenWidth / (minCardWidth + spacing)).floor();
              cardsPerRow = cardsPerRow < 1 ? 1 : cardsPerRow;

              double cardWidth =
                  (screenWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

              return Obx(() {
                if (hotelController.roomStatistics.isEmpty) {
                  return Wrap(
                    alignment: WrapAlignment.start,
                    children: List.generate(
                      cardsPerRow,
                      (_) => SizedBox(
                          width: cardWidth,
                          child: _buildShimmerCard(cardWidth)),
                    ),
                  );
                }

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  alignment: WrapAlignment.start,
                  children: hotelController.roomStatistics.map((stat) {
                    final category = stat['category'];

                    return SizedBox(
                      width: cardWidth,
                      child: _buildRoomCard(
                        category,
                        '₦${_getPriceFromCategory(category)}',
                        '${stat['available']}/${stat['total']} Rooms',
                        () {
                          hotelController.filteredRooms.value = hotelController
                              .rooms
                              .where((room) =>
                                  room.category == category &&
                                  room.status.toLowerCase() == 'available')
                              .toList();
                        },
                      ),
                    );
                  }).toList(),
                );
              });
            },
          ),
        ),
        SizedBox(height: Get.height * 0.02),
        // Search Bar and Room List Section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Room List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Search Room',
                              fillColor: AppColor.grey,
                              borderRadius: 8.0,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              onChanged: (value) {
                                final lower = value.toLowerCase();

                                if (lower.isEmpty) {
                                  hotelController.filteredRooms.clear();
                                  return;
                                }

                                hotelController.filteredRooms.value =
                                    hotelController.rooms.where((room) {
                                  return room.name
                                          .toLowerCase()
                                          .contains(lower) ||
                                      room.category
                                          .toLowerCase()
                                          .contains(lower);
                                }).toList();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (hotelController.isRoomLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!hotelController.isRoomLoading.value &&
                        hotelController.filteredRooms.isEmpty &&
                        hotelController.rooms.isNotEmpty) {
                      return const Center(
                        child: Text(
                          '🔍 Enter a room name or category to begin.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    if (hotelController.rooms.isEmpty) {
                      return const Center(
                        child: Text(
                          'No rooms available.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: hotelController.filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = hotelController.filteredRooms[index];
                        return _buildRoomRow(
                          roomNumber: room.name,
                          status: room.status,
                          isAvailable: room.status.toLowerCase() == 'available',
                          roomType: room.category,
                          onCheckIn: room.status.toLowerCase() == 'available'
                              ? () {
                                  hotelController.selectedRoomId.value = room.id!;
                                  hotelController.selectedRoomName.value =
                                      room.name;
                                  widget.navigateToDashboardContent(9);
                                }
                              : null,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(
      String title, String? price, String? available, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.black),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withOpacity(0.9),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: cardWidth * 0.2,
                    height: cardWidth * 0.2,
                    decoration: BoxDecoration(
                      color: AppColor.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.hotel,
                          size: cardWidth * 0.10, color: AppColor.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Price: $price',
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.black)),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Available: $available',
                              style: TextStyle(
                                  fontSize: 14, color: AppColor.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomRow({
    required String roomNumber,
    required String status,
    required bool isAvailable,
    required String roomType,
    final VoidCallback? onCheckIn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAvailable ? AppColor.grey : AppColor.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            roomNumber,
            style: TextStyle(
              color: isAvailable ? AppColor.black : AppColor.white,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                status,
                style: TextStyle(
                  color: isAvailable ? AppColor.black : AppColor.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isAvailable ? AppColor.success : AppColor.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Text(
            roomType,
            style: TextStyle(
              color: isAvailable ? AppColor.black : AppColor.white,
              fontSize: 14,
            ),
          ),
          CustomButton(
            onPressed: isAvailable ? onCheckIn : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable ? AppColor.black : Colors.grey,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Check-In'),
          ),
        ],
      ),
    );
  }
}
