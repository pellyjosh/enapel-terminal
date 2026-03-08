import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';

class Sidebar extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final Function(int) onItemSelected;
  final int selectedIndex;

  const Sidebar({
    super.key,
    required this.menuItems,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = MediaQuery.of(context).size.width * 0.1;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: sidebarWidth.clamp(80, 140), // Responsive width
      color: AppColor.black.withOpacity(0.9),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            menuItems.length,
            (index) => _buildSidebarIcon(
              icon: menuItems[index]['icon'],
              label: menuItems[index]['label'],
              index: index,
              sidebarWidth: sidebarWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarIcon({
    required IconData icon,
    required String label,
    required int index,
    required double sidebarWidth,
  }) {
    final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: MouseRegion(
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hover, child) {
            return Stack(
              clipBehavior: Clip.none, // Ensure the label is not clipped
              alignment: Alignment.centerLeft,
              children: [
                GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: hover ? sidebarWidth * 0.9 : sidebarWidth * 0.8,
                    height: hover ? sidebarWidth * 0.9 : sidebarWidth * 0.8,
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? AppColor.primary
                          : hover
                              ? AppColor.white.withOpacity(0.2)
                              : AppColor.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: AppColor.white,
                          size: sidebarWidth * 0.35,
                        ),
                        SizedBox(
                            height: sidebarWidth *
                                0.05), // Spacing between icon and label
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: sidebarWidth * 0.1, // Dynamic font size
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
