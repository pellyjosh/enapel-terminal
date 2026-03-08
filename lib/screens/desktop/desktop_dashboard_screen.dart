import 'package:enapel/screens/desktop/dashboard/hotel/checkin.dart';
import 'package:enapel/screens/desktop/dashboard/hotel/home.dart';
import 'package:enapel/screens/desktop/dashboard/hotel/reservation.dart';
import 'package:enapel/screens/desktop/dashboard/hotel/rooms.dart';
import 'package:enapel/screens/desktop/dashboard/pharmacy/home.dart';
import 'package:enapel/screens/desktop/dashboard/pharmacy/patientmanagement.dart';
import 'package:enapel/screens/desktop/dashboard/pharmacy/register.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/analytics.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/home.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/inventory.dart';
import 'package:enapel/screens/desktop/dashboard/supermarket/sales.dart';
import 'package:enapel/screens/desktop/profile.dart';
import 'package:enapel/screens/desktop/staff.dart';
import 'package:enapel/services/license_service.dart';
import 'package:enapel/widget/side_bar_widget.dart';
import 'package:flutter/material.dart';

class DesktopDashboardScreen extends StatefulWidget {
  const DesktopDashboardScreen({super.key});

  @override
  State<DesktopDashboardScreen> createState() => _DesktopDashboardScreenState();
}

class _DesktopDashboardScreenState extends State<DesktopDashboardScreen> {
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

  void updateSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> contentOptions = [
      HomePharmacyScreen(navigateToDashboardContent: updateSelectedIndex),
      HotelHomeScreen(navigateToDashboardContent: updateSelectedIndex),
      const SuperMarketDashScreen(),
      const PointOfSalesScreen(),
      const InventoryScreen(),
      const StaffManagementScreen(),
      const ReservationScreen(),
      const AnalyticsReportScreen(),
      const RoomListScreen(),
      CheckinScreen(navigateToDashboardContent: updateSelectedIndex),
      const PatientmanagementScreen(),
      const PatientRegisterScreen(),
      const ProfileSettings()
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
          Row(
            children: [
              // Sidebar
              Sidebar(
                menuItems: const [
                  {'icon': Icons.home, 'label': 'Home'},
                  {'icon': Icons.home_filled, 'label': 'Dashboard'},
                  {'icon': Icons.home_work_sharp, 'label': 'Home'},
                  {'icon': Icons.shopping_cart, 'label': 'Sales'},
                  {'icon': Icons.assignment, 'label': 'Inventory'},
                  {'icon': Icons.supervised_user_circle, 'label': 'Staff'},
                  {'icon': Icons.list_alt_rounded, 'label': 'Guests'},
                  {'icon': Icons.analytics, 'label': 'Analytics'},
                  {'icon': Icons.list, 'label': 'Rooms'},
                ],
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index; // Update the selected index
                  });
                },
                selectedIndex: selectedIndex, // Highlight active icon
              ),

              // Main Content with Transition
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    // Wrap transitions with constraints
                    return SizedBox.expand(
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                    );
                  },
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: SizedBox.expand(
                    key: ValueKey(
                        selectedIndex), // Ensure unique keys for children
                    child: contentOptions[selectedIndex],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
