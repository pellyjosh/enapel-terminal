import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/widget/mobile/sidebar.dart';
import 'package:enapel/utils/app_color.dart';

class HeaderWidget extends StatefulWidget {
 final dynamic navigateToDashboardContent;

  const HeaderWidget({
    super.key,
    selectedIndex,
    required this.navigateToDashboardContent,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  int selectedIndex = 0; // Track selected item

  void _openMenu() {
    showDialog(
      context: context,
      barrierDismissible: true, // Closes when tapping outside
      builder: (context) {
        return SideMenu(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              widget.navigateToDashboardContent(index); // Update HomeScreenMobile
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.05,
        vertical: Get.height * 0.07,
      ),
      color: AppColor.black.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, color: Colors.white, size: Get.width * 0.09),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Welcome Staff 0099",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.width * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: Get.width * 0.09),
            onPressed: _openMenu,
          ),
        ],
      ),
    );
  }
}
