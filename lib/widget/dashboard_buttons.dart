import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/utils/app_color.dart';

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const OptionButton({
    super.key,
    required this.icon,
    required this.label,
    required double fontSize,
    required double iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Get.height * 0.03,
      ), // Vertical padding
      width: Get.size.width * 0.85, // Button width
      height: Get.size.height * 0.15, // Button height
      decoration: BoxDecoration(
        color: AppColor.black,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: Get.width *
                    0.1), // Adjust this value for the desired margin
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                color: AppColor.white,
                size: Get.width * 0.17, // Adjusted size to balance spacing
              ),
            ),
          ),
          SizedBox(width: Get.width * 0.0016),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColor.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Get.width * 0.055,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
