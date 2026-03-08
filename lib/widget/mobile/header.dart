import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget {
  final String title;
  final IconData menuIcon;
  final IconData searchIcon;
  final IconData barcodeIcon;
  final IconData listIcon;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onBarcodeTap;
  final VoidCallback onListTap;

  const CustomAppBarWidget({
    Key? key,
    required this.title,
    required this.menuIcon,
    required this.searchIcon,
    required this.barcodeIcon,
    required this.listIcon,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onBarcodeTap,
    required this.onListTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
padding: const EdgeInsets.only(top: 50.0, left: 26.0, right: 26.0, bottom: 30),
      color: AppColor.white.withOpacity(0.8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title in the center
          Text(
            title,
            style:  TextStyle(
              color: AppColor.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Left-side icons
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onMenuTap,
                  icon: Icon(menuIcon, color: AppColor.black),
                ),
              ],
            ),
          ),
          // Right-side icons
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onSearchTap,
                  icon: Icon(searchIcon, color: AppColor.black),
                ),
                IconButton(
                  onPressed: onBarcodeTap,
                  icon: Icon(barcodeIcon, color: AppColor.black),
                ),
                IconButton(
                  onPressed: onListTap,
                  icon: Icon(listIcon, color: AppColor.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
