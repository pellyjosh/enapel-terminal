import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/utils/app_color.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: Get.height * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: AppColor.white, size: Get.width * 0.09),
          Icon(Icons.inventory, color: AppColor.white, size: Get.width * 0.09),
          Icon(Icons.bar_chart, color: AppColor.white, size: Get.width * 0.09),
        ],
      ),
    );
  }
}
