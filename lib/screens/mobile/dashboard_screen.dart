import 'package:enapel/screens/mobile/dashboard/analytics.dart';
import 'package:enapel/screens/mobile/dashboard/home.dart';
import 'package:enapel/screens/mobile/dashboard/hotel.dart';
import 'package:enapel/screens/mobile/dashboard/inventory.dart';
import 'package:enapel/screens/mobile/dashboard/reservation.dart';
import 'package:enapel/screens/mobile/dashboard/sales.dart';
import 'package:enapel/screens/mobile/dashboard/staff.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  final TerminalLicenseService _licenseService = TerminalLicenseService();

  @override
  void initState() {
    super.initState();
    _enforceLicense();
  }

  Future<void> _enforceLicense() async {
    await _licenseService.ensureValid(refresh: true);
  }

  void _onBottomNavItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void navigateToDashboardContent(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> contentOptions = [
      HomeScreenMobile(navigateToDashboardContent: navigateToDashboardContent),
      HotelHomeMobile(navigateToDashboardContent: navigateToDashboardContent),
      const PointOfSalesScreenMobile(),
      const InventoryScreenMobile(),
      const StaffMobileScreen(),
      const ReservationScreenMobile(),
      const AnalyticsSreenMobile()
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Main Content with Animated Transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: SizedBox.expand(
              key: ValueKey(selectedIndex),
              child: contentOptions[selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.black,
        currentIndex: selectedIndex,
        onTap: _onBottomNavItemSelected,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.black,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Guest List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
