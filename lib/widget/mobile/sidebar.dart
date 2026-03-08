import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start off-screen (right)
      end: Offset.zero, // Move to original position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(); // Start animation when menu opens
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMenuItemSelected(int index) {
    widget.onItemSelected(index);
    Navigator.pop(context); // Close menu after selection
  }

 Widget _buildMenuItem(BuildContext context, IconData icon, String title,
      int index, VoidCallback onTap) {
    bool isSelected = widget.selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: onTap, // Use the provided onTap function
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.blue.withOpacity(0.8) : Colors.transparent,
            border: const Border(
              bottom: BorderSide(color: Colors.white, width: 1.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[300]),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // **Tap outside to close**
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5), // Dimmed background effect
          ),
        ),

        // **Sliding Side Menu**
        SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: const Border(
                      left: BorderSide(color: Colors.white, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildMenuItem(context, Icons.home, "Home", 0,
                        () => _onMenuItemSelected(0)),
                    _buildMenuItem(context, Icons.dashboard, "Dashboard", 1,
                        () => _onMenuItemSelected(1)),
                    _buildMenuItem(context, Icons.shopping_cart, "Sales", 2,
                        () => _onMenuItemSelected(2)),
                    _buildMenuItem(context, Icons.inventory, "Inventory", 3,
                        () => _onMenuItemSelected(3)),
                    _buildMenuItem(context, Icons.people, "Staff", 4,
                        () => _onMenuItemSelected(4)),
                    _buildMenuItem(context, Icons.list_alt_rounded,
                        "Guest List", 5, () => _onMenuItemSelected(5)),
                    _buildMenuItem(context, Icons.analytics, "Analytics", 6,
                        () => _onMenuItemSelected(6)),
                    const Spacer(),
                    _buildMenuItem(context, Icons.logout, "Logout", 7,
                        () => _onMenuItemSelected(7)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
