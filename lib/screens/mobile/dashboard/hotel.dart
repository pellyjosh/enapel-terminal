import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/header_widget.dart';
import 'package:enapel/widget/mobile/listview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HotelHomeMobile extends StatefulWidget {
   final Function(int) navigateToDashboardContent;

  const HotelHomeMobile({super.key, required this.navigateToDashboardContent});

  @override
  State<HotelHomeMobile> createState() => _HotelHomeMobileState();
}

class _HotelHomeMobileState extends State<HotelHomeMobile> {
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    // _loadUserInformation();
  }

  void handleMenuSelection(String value) {
    if (value == 'profile') {
      // Handle profile settings action
    } else if (value == 'logout') {
      // Handle log-out action
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         HeaderWidget(
            navigateToDashboardContent: widget.navigateToDashboardContent),
        SizedBox(height: Get.height * 0.02),
        // Card Section
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth =
                constraints.maxWidth / 3 - 20; // 3 cards per row with spacing
            if (constraints.maxWidth < 600) {
              cardWidth = constraints.maxWidth / 2 -
                  16; // 2 cards per row for smaller screens
            }
            if (constraints.maxWidth < 400) {
              cardWidth = constraints.maxWidth -
                  16; // 1 card per row for narrow screens
            }

            return 
            Wrap(
              spacing: 16, // Horizontal space between cards
              runSpacing: 16, // Vertical space between rows
              alignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildRoomCard('NORMAL ROOM', '₦15,000', '5/50 Rooms'),
                ),
                SizedBox(
                  width: cardWidth,
                  child:
                      _buildRoomCard('STANDARD ROOM', '₦15,000', '15/50 Rooms'),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildRoomCard('SUITE', '₦15,000', '20/50 Rooms'),
                ),
              ],
            );
          },
        ),
        SizedBox(height: Get.height * 0.02),
        // Search Bar and Room List Section
       Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Section
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
                              hintText:
                                  'Search Room', // Hint text for the search field
                              fillColor: AppColor.grey, // Custom fill color
                              borderRadius:
                                  8.0, // Matches the rounded corner design
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'search',
                              style: TextStyle(color: AppColor.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // List View Section
                Expanded(
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      bool isOdd = index % 2 == 1;
                      bool isAvailable =
                          !isOdd; // If the room is available (false for unavailable)

                      return DynamicListItem(
                        title: Text(
                          'Room ${index + 101}', // Room number
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isOdd
                                ? AppColor.black
                                : AppColor
                                    .white, // Title color based on background
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Standard Room', // Room type (Standard Room)
                              style: TextStyle(
                                color: isAvailable
                                    ? AppColor.success
                                    : AppColor
                                        .danger, // Green for available, red for unavailable
                              ),
                            ),
                            const SizedBox(
                                height:
                                    4), // Small space between room type and button
                          ],
                        ),
                        backgroundColor: isOdd
                            ? AppColor.white
                            : AppColor.black, // Background color based on index
                        trailing: Icon(
                          Icons.check_circle,
                          color: isAvailable
                              ? AppColor.success
                              : AppColor.danger, // Availability icon
                        ),
                        isEven: index % 2 == 0,
                        children: [
                          Align(
                            alignment: Alignment
                                .center, // Align button to the right
                            child: CustomButton(
                              onPressed: () {
                                if (isAvailable) {
                                  print("Room ${index + 101} is available");
                                } else {
                                  _showRoomUnavailableModal(context,
                                      index + 101); // Show modal if unavailable
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    isOdd ? AppColor.black : AppColor.white),
                                foregroundColor: MaterialStateProperty.all(
                                    isOdd ? AppColor.white : AppColor.black),
                              ),
                              child: Text('Check-In'),
                            ),
                          ),
                        ],
                        onTap: () {
                          if (isAvailable) {
                            print("Room ${index + 101} is available");
                          } else {
                            _showRoomUnavailableModal(context,
                                index + 101); // Show modal if unavailable
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildRoomCard(String title, String? price, String? available) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        return Container(
          decoration: BoxDecoration(
            color: AppColor.white, // White background
            borderRadius: BorderRadius.circular(8), // Rounded corners
            border: Border.all(color: AppColor.black), // Black border
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.9), // Subtle shadow
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Inner padding for content
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Picture Container
                Container(
                  width: cardWidth * 0.35, // Adjust width dynamically
                  height: cardWidth * 0.35, // Keep it square
                  decoration: BoxDecoration(
                    color: AppColor.grey, // Placeholder color
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.hotel, // Example placeholder icon
                      size: cardWidth * 0.15, // Adjust size dynamically
                      color: AppColor.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between picture and text
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamically scaling title text
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (price != null) ...[
                        const SizedBox(height: 14),
                        // Dynamically scaling price text
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Price: $price',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Available: $available',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRoomUnavailableModal(BuildContext context, int roomNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Room $roomNumber is unavailable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room Type: Standard Room'),
              Text('Status: Unavailable'),
              CustomButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
