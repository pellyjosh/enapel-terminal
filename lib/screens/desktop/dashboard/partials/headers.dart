import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Header extends StatelessWidget {
  final Map<String, dynamic> user;
  final void Function(String) onMenuSelected;

  const Header({
    Key? key,
    required this.user,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = user['name'] ?? 'Staff';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.02,
        vertical: Get.height * 0.05,
      ),
      color: Colors.black.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome $userName", // Dynamically show the user's name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.width * 0.019, // Responsive text
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                (user['isAdmin'] is bool)
                    ? (user['isAdmin'] ? "Super Staff" : "Staff")
                    : (user['isAdmin'] == 1 ? "Super Staff" : "Staff"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.width * 0.010, // Responsive text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: onMenuSelected, // Handle menu actions
            icon: Icon(
              Icons.person,
              color: AppColor.white,
              size: Get.width * 0.03, // Responsive icon size
            ),
            color: AppColor.white, // Menu background color
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Text(
                  'Profile Settings',
                  style: TextStyle(fontSize: Get.width * 0.015),
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: Get.width * 0.015),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
