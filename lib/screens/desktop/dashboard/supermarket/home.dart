import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperMarketDashScreen extends StatefulWidget {
  const SuperMarketDashScreen({super.key});

  @override
  State<SuperMarketDashScreen> createState() => _SuperMarketDashState();
}

class _SuperMarketDashState extends State<SuperMarketDashScreen> {
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    try {
      final userMap = await KeyStorage.getMap('user');
      print(userMap);
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
    } else if (value == 'logout') {
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Header(
          user: user!,
          onMenuSelected: handleMenuSelection,
        ),
        SizedBox(height: Get.height * 0.05),

        Expanded(
          child: Column(
            children: [
              // Button Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: Get.width * 0.03,
                  mainAxisSpacing: Get.height * 0.025,
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                  children: [
                    _buildOptionButton(
                      icon: Icons.shopping_cart,
                      label: "Sales",
                    ),
                    _buildOptionButton(
                      icon: Icons.bar_chart,
                      label: "reports",
                    ),
                    _buildOptionButton(
                      icon: Icons.assignment,
                      label: "Inventory",
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

Widget _buildOptionButton({required IconData icon, required String label}) {
  return Container(
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
  );
}
