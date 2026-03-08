import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/screens/desktop/dashboard/pharmacy/register.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePharmacyScreen extends StatefulWidget {
 final dynamic navigateToDashboardContent;

  const HomePharmacyScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<HomePharmacyScreen> createState() => _HomeState();
}

class _HomeState extends State<HomePharmacyScreen> {
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    try {
      final userMap = KeyStorage.getMap('user');
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
      widget.navigateToDashboardContent(12);
    } else if (value == 'logout') {
      // Handle log-out action
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.black),
      );
    }

    return Column(
      children: [
        Header(
          user: user!,
          onMenuSelected: handleMenuSelection,
        ),
        SizedBox(height: Get.height * 0.05),

        Expanded(
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: Get.width * 0.03,
                  mainAxisSpacing: Get.height * 0.025,
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                  children: [
                    _buildOptionButton(
                      icon: Icons.assignment,
                      label: "patient register",
                      onTap: () {
                         widget.navigateToDashboardContent(11);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.bar_chart,
                      label: "reports",
                      onTap: () {
                        widget.navigateToDashboardContent(7);
                      },
                    ),
                    _buildOptionButton(
                      icon: Icons.manage_accounts,
                      label: "Patient Management",
                      onTap: () {
                        widget.navigateToDashboardContent(10);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Dynamic Content with AnimatedSwitcher
      ],
    );
  }
}

Widget _buildOptionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap, // Add onTap parameter for navigation
}) {
  return GestureDetector(
    onTap: onTap, // Trigger navigation on tap
    child: Container(
      padding: EdgeInsets.all(Get.width * 0.02),
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColor.white,
            size: Get.width * 0.05, // Responsive icon size
          ),
          SizedBox(height: Get.height * 0.01),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.white,
              fontSize: Get.width * 0.012, // Responsive text size
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
