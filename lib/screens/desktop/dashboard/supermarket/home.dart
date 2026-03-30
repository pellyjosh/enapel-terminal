import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/widgets/dashboard_widgets.dart';
import 'package:enapel/widgets/price_lookup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuperMarketDashScreen extends StatefulWidget {
  final dynamic navigateToDashboardContent;
  const SuperMarketDashScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<SuperMarketDashScreen> createState() => _SuperMarketDashState();
}

class _SuperMarketDashState extends State<SuperMarketDashScreen> {
  Map<String, dynamic>? user;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    try {
      final userMap = KeyStorage.getMap('user');
      print(userMap);
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
      Get.offAllNamed(Routes.dashboard);
    } else if (value == 'logout') {
      // Handle logout
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: CircularProgressIndicator());
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
                  title: "Today's Sales",
                  value: "₦450,000",
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                  trend: "+12.5%",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Transactions",
                  value: "128",
                  icon: Icons.receipt_long_outlined,
                  color: Colors.blue,
                  trend: "+8.2%",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Low Stock",
                  value: "14",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.orange,
                  trend: "-2",
                  isNegative: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Tools and Activity Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Tools (Left 2/3)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Operational Tools",
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
                      childAspectRatio: 1.2,
                      children: [
                        QuickActionButton(
                          label: "Point of Sale",
                          icon: Icons.shopping_cart_outlined,
                          color: Colors.blue,
                          onTap: () => widget.navigateToDashboardContent(3),
                        ),
                        if (isAdmin)
                          QuickActionButton(
                            label: "Inventory",
                            icon: Icons.inventory_2_outlined,
                            color: Colors.orange,
                            onTap: () => widget.navigateToDashboardContent(4),
                          ),
                        QuickActionButton(
                          label: "Staff Manage",
                          icon: Icons.people_outline,
                          color: Colors.purple,
                          onTap: () => widget.navigateToDashboardContent(5),
                        ),
                        QuickActionButton(
                          label: "Price Lookup",
                          icon: Icons.search_outlined,
                          color: Colors.teal,
                          onTap: () {
                            Get.dialog(const PriceLookupDialog());
                          },
                        ),
                        if (isAdmin)
                          QuickActionButton(
                            label: "Analytics",
                            icon: Icons.analytics_outlined,
                            color: Colors.red,
                            onTap: () => widget.navigateToDashboardContent(7),
                          ),
                        QuickActionButton(
                          label: "Settings",
                          icon: Icons.settings_outlined,
                          color: Colors.grey,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Recent Activity (Right 1/3)
              Expanded(
                flex: 1,
                child: ActivityList(
                  title: "Recent Sales",
                  onSeeAll: () {},
                  items: [
                    ActivityItem(
                      title: "Sale #8492",
                      subtitle: "₦12,500 - 4 items",
                      time: "2m ago",
                      icon: Icons.shopping_bag_outlined,
                      iconColor: Colors.green,
                    ),
                    ActivityItem(
                      title: "Sale #8491",
                      subtitle: "₦5,200 - 2 items",
                      time: "15m ago",
                      icon: Icons.shopping_bag_outlined,
                      iconColor: Colors.green,
                    ),
                    ActivityItem(
                      title: "Return #102",
                      subtitle: "₦1,400 - 1 item",
                      time: "1h ago",
                      icon: Icons.assignment_return_outlined,
                      iconColor: Colors.orange,
                    ),
                    ActivityItem(
                      title: "Sale #8490",
                      subtitle: "₦45,000 - 12 items",
                      time: "2h ago",
                      icon: Icons.shopping_bag_outlined,
                      iconColor: Colors.green,
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
