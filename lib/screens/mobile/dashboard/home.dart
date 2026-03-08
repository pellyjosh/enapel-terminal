import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/widget/bottom_nav_bar.dart';
import 'package:enapel/widget/dashboard_buttons.dart';
import 'package:enapel/widget/header_widget.dart';

class HomeScreenMobile extends StatefulWidget {
  final Function(int) navigateToDashboardContent;

  const HomeScreenMobile({
    super.key,
    required this.navigateToDashboardContent,
  });

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
 
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         HeaderWidget(
         navigateToDashboardContent: widget.navigateToDashboardContent,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OptionButton(
                  icon: Icons.shopping_cart,
                  label: "input sales",
                  fontSize: Get.width * 0.015,
                  iconSize: Get.width * 0.05,
                ),
                SizedBox(height: Get.height * 0.05),
                OptionButton(
                  icon: Icons.bar_chart,
                  label: "view reports",
                  fontSize: Get.width * 0.015,
                  iconSize: Get.width * 0.05,
                ),
                SizedBox(height: Get.height * 0.05),
                OptionButton(
                  icon: Icons.inventory,
                  label: "inventory of items",
                  fontSize: Get.width * 0.015,
                  iconSize: Get.width * 0.05,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
