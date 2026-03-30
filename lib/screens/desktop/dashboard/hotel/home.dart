import 'package:enapel/controller/hotel/hotel_controller.dart';
import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/widgets/dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HotelHomeScreen extends StatefulWidget {
  final dynamic navigateToDashboardContent;

  const HotelHomeScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<HotelHomeScreen> createState() => _HotelDashState();
}

class _HotelDashState extends State<HotelHomeScreen> {
  final HotelController hotelController = Get.put(HotelController());
  final TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _loadUserInformation();
    await hotelController.getRooms(
        autoAssignToFiltered: false); // ← Don't auto-show rooms
    await Future.wait([
      hotelController.getRooms(),
      hotelController.getCategories(),
      hotelController
          .fetchRoomStatistics(DateTime.now().toIso8601String().split('T')[0]),
    ]);
  }

  void _searchRooms(String query) {
    final lower = query.toLowerCase();
    hotelController.filteredRooms.value = hotelController.rooms.where((room) {
      return room.name.toLowerCase().contains(lower) ||
             room.category.toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> _loadUserInformation() async {
    try {
      final userMap = await KeyStorage.getMap('user');
      if (userMap != null) {
        setState(() {
          user = userMap;
          final dynamic isAdminVal = userMap['isAdmin'];
          final String? role = userMap['role']?.toString().toLowerCase();
          
          isAdmin = (isAdminVal == true || isAdminVal == 1 || isAdminVal == '1') || 
                    (role == 'admin' || role == 'super admin' || role == 'superadmin' || role == 'owner');
        });
      }
    } catch (e) {
      print('Error loading user information: $e');
    }
  }

  void handleMenuSelection(String value) {
    if (value == 'profile') {
      widget.navigateToDashboardContent(12);
    } else if (value == 'lock') {
      KeyStorage.saveBool('isLocked', true);
      Get.offAllNamed(Routes.dashboard); // Refresh to show lock screen
    } else if (value == 'logout') {
      // Handle log-out action
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Header(
            user: user!,
            onMenuSelected: handleMenuSelection,
          ),
          const SizedBox(height: 32),

          // Statistics Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "Occupancy",
                  value: "${hotelController.roomStatistics.isNotEmpty ? (hotelController.rooms.where((r) => r.status.toLowerCase() == 'occupied').length / hotelController.rooms.length * 100).toStringAsFixed(0) : "78"}%",
                  icon: Icons.hotel_outlined,
                  color: Colors.blue,
                  trend: "32 Rooms",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Today's Arrivals",
                  value: "12",
                  icon: Icons.login_outlined,
                  color: Colors.green,
                  trend: "4 Checked in",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Today's Departures",
                  value: "8",
                  icon: Icons.logout_outlined,
                  color: Colors.orange,
                  trend: "2 Pending",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Maintenance",
                  value: "3",
                  icon: Icons.cleaning_services_outlined,
                  color: Colors.red,
                  trend: "High Priority",
                  isNegative: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Tools and Status Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Tools (Left 2/3)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hospitality Tools",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.3,
                      children: [
                        QuickActionButton(
                          label: "Fast Check-in",
                          icon: Icons.person_add_alt_1_outlined,
                          color: Colors.blue,
                          onTap: () => widget.navigateToDashboardContent(9),
                        ),
                        QuickActionButton(
                          label: "Point of Sale",
                          icon: Icons.shopping_cart_outlined,
                          color: Colors.teal,
                          onTap: () => widget.navigateToDashboardContent(3),
                        ),
                        QuickActionButton(
                          label: "Room Service",
                          icon: Icons.room_service_outlined,
                          color: Colors.orange,
                          onTap: () {},
                        ),
                        QuickActionButton(
                          label: "Housekeeping",
                          icon: Icons.cleaning_services_outlined,
                          color: Colors.purple,
                          onTap: () {},
                        ),
                        if (isAdmin)
                          QuickActionButton(
                            label: "Hotel Reports",
                            icon: Icons.analytics_outlined,
                            color: Colors.red,
                            onTap: () => widget.navigateToDashboardContent(7),
                          ),
                        QuickActionButton(
                          label: "Guest Search",
                          icon: Icons.search_outlined,
                          color: Colors.grey,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Room Status / Arrival Stream (Right 1/3)
              Expanded(
                flex: 1,
                child: ActivityList(
                  title: "Live Arrivals",
                  onSeeAll: () {},
                  items: [
                    ActivityItem(
                      title: "Smith Party",
                      subtitle: "Room 204 - Pending",
                      time: "Expected Now",
                      icon: Icons.access_time_outlined,
                      iconColor: Colors.blue,
                    ),
                    ActivityItem(
                      title: "Hotel Guest #128",
                      subtitle: "Room 105 - Checked In",
                      time: "15m ago",
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    ActivityItem(
                      title: "Brown Family",
                      subtitle: "Room 302 - Confirmed",
                      time: "In 2h",
                      icon: Icons.schedule_outlined,
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
