import 'package:enapel/controller/connectivity_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
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
import 'package:enapel/services/activity_logger.dart';
import 'package:flutter/material.dart';
import 'package:enapel/screens/desktop/lock_screen.dart';
import 'package:enapel/screens/desktop/server_down_screen.dart';
import 'package:enapel/widget/side_bar_widget.dart';
import 'package:get/get.dart';

class DesktopDashboardScreen extends StatefulWidget {
  const DesktopDashboardScreen({super.key});

  @override
  State<DesktopDashboardScreen> createState() => _DesktopDashboardScreenState();
}

class _DesktopDashboardScreenState extends State<DesktopDashboardScreen> {
  int activeContentIndex = 2; // Default to Supermarket Home
  String activeModule = 'Supermarket';
  String databaseMode = 'local';
  bool isLocked = false;
  final TerminalLicenseService _licenseService = TerminalLicenseService();
  final ConnectivityController _connectivityController = Get.find<ConnectivityController>();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    databaseMode = KeyStorage.getString('database_mode') ?? 'local';
    activeModule = KeyStorage.getString('active_module') ?? 'Supermarket';
    isLocked = KeyStorage.getBool('isLocked');
    _setDefaultContentIndex();
    await _licenseService.ensureValid(refresh: true);
    setState(() {});
  }

  void _setDefaultContentIndex() {
    if (activeModule == 'Pharmacy') {
      activeContentIndex = 0;
    } else if (activeModule == 'Hotel') {
      activeContentIndex = 1;
    } else {
      activeContentIndex = 2; // Supermarket
    }
  }

  void updateSelectedIndex(int index) {
    setState(() {
      activeContentIndex = index;
    });
  }

  List<Map<String, dynamic>> _getCurrentMenu() {
    final user = KeyStorage.getMap('user');
    
    // Robust isAdmin check: handles boolean true, integer 1, or admin-like roles
    final dynamic isAdminVal = user?['isAdmin'];
    final String? role = user?['role']?.toString().toLowerCase();
    
    final bool isAdmin = (isAdminVal == true || isAdminVal == 1 || isAdminVal == '1') || 
                        (role == 'admin' || role == 'super admin' || role == 'superadmin' || role == 'owner');

    List<Map<String, dynamic>> menu = [];

    if (activeModule == 'Pharmacy') {
      menu = [
        {'icon': Icons.home, 'label': 'Home', 'contentIndex': 0},
        {'icon': Icons.assignment, 'label': 'Register', 'contentIndex': 11},
        {'icon': Icons.supervised_user_circle, 'label': 'Staff', 'contentIndex': 5},
      ];
    } else if (activeModule == 'Hotel') {
      menu = [
        {'icon': Icons.home_filled, 'label': 'Dashboard', 'contentIndex': 1},
        {'icon': Icons.list_alt_rounded, 'label': 'Guests', 'contentIndex': 6},
        {'icon': Icons.list, 'label': 'Rooms', 'contentIndex': 8},
        {'icon': Icons.supervised_user_circle, 'label': 'Staff', 'contentIndex': 5},
      ];
    } else { // Supermarket setup
      menu = [
        {'icon': Icons.home_work_sharp, 'label': 'Home', 'contentIndex': 2},
        {'icon': Icons.shopping_cart, 'label': 'Sales', 'contentIndex': 3},
        {'icon': Icons.assignment, 'label': 'Inventory', 'contentIndex': 4},
        {'icon': Icons.supervised_user_circle, 'label': 'Staff', 'contentIndex': 5},
        {'icon': Icons.analytics, 'label': 'Analytics', 'contentIndex': 7},
      ];
    }

    if (!isAdmin) {
      // Filter out management sections for non-admins
      menu = menu.where((item) {
        final label = item['label'];
        return label != 'Staff' && label != 'Inventory' && label != 'Analytics';
      }).toList();
    }

    return menu;
  }

  int get _activeSidebarIndex {
    final currentMenu = _getCurrentMenu();
    for (int i = 0; i < currentMenu.length; i++) {
      if (currentMenu[i]['contentIndex'] == activeContentIndex) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (databaseMode == 'server' && !_connectivityController.isServerAvailable.value) {
        return const ServerDownScreen();
      }

      if (isLocked) {
        return LockScreen(
          onUnlock: () {
            setState(() {
              isLocked = false;
              KeyStorage.saveBool('isLocked', false);
            });
          },
        );
      }

      final List<Widget> contentOptions = [
        HomePharmacyScreen(navigateToDashboardContent: updateSelectedIndex),
        HotelHomeScreen(navigateToDashboardContent: updateSelectedIndex),
        SuperMarketDashScreen(navigateToDashboardContent: updateSelectedIndex),
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
                  headerWidget: databaseMode == 'server' ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.black, // Use standard Material Colors
                        value: activeModule,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              activeModule = newValue;
                              _setDefaultContentIndex();
                            });
                            KeyStorage.saveString('active_module', newValue);
                            ActivityLogger.log(
                              action: 'Module Switch',
                              description: 'Switched to $newValue module',
                              module: newValue,
                            );
                          }
                        },
                        items: <String>['Supermarket', 'Pharmacy', 'Hotel']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          );
                        }).toList(),
                      ),
                    ),
                  ) : null,
                  menuItems: _getCurrentMenu(),
                  onItemSelected: (index) {
                    final contentIndex = _getCurrentMenu()[index]['contentIndex'];
                    updateSelectedIndex(contentIndex);
                  },
                  selectedIndex: _activeSidebarIndex, // Highlight active icon
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
                          activeContentIndex), // Ensure unique keys for children
                      child: contentOptions[activeContentIndex],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
