import 'package:enapel/database/storage/key_storage.dart';
import 'package:enapel/route/route.dart';
import 'package:enapel/screens/desktop/dashboard/partials/headers.dart';
import 'package:enapel/widgets/dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePharmacyScreen extends StatefulWidget {
 final dynamic navigateToDashboardContent;

  const HomePharmacyScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<HomePharmacyScreen> createState() => _HomeState();
}

class _HomeState extends State<HomePharmacyScreen> {
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
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
                  title: "Dispensed Today",
                  value: "42",
                  icon: Icons.medication_outlined,
                  color: Colors.blue,
                  trend: "+5",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Active Prescriptions",
                  value: "18",
                  icon: Icons.assignment_outlined,
                  color: Colors.orange,
                  trend: "3 Pending",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: "Expiry Alerts",
                  value: "7",
                  icon: Icons.warning_amber_outlined,
                  color: Colors.red,
                  trend: "Next 30 days",
                  isNegative: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Tools and Queue Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacy Tools (Left 2/3)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pharmacy Operations",
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
                          label: "Dispensing POS",
                          icon: Icons.point_of_sale_outlined,
                          color: Colors.blue,
                          onTap: () => widget.navigateToDashboardContent(3),
                        ),
                        QuickActionButton(
                          label: "Patient Register",
                          icon: Icons.person_add_outlined,
                          color: Colors.teal,
                          onTap: () => widget.navigateToDashboardContent(11),
                        ),
                        if (isAdmin)
                          QuickActionButton(
                            label: "Drug Catalog",
                            icon: Icons.inventory_2_outlined,
                            color: Colors.orange,
                            onTap: () => widget.navigateToDashboardContent(4),
                          ),
                        QuickActionButton(
                          label: "Prescriptions",
                          icon: Icons.history_edu_outlined,
                          color: Colors.purple,
                          onTap: () => widget.navigateToDashboardContent(10),
                        ),
                        if (isAdmin)
                          QuickActionButton(
                            label: "Pharmacy Reports",
                            icon: Icons.analytics_outlined,
                            color: Colors.red,
                            onTap: () => widget.navigateToDashboardContent(7),
                          ),
                        QuickActionButton(
                          label: "Drug Lookup",
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
              // Prescription Queue (Right 1/3)
              Expanded(
                flex: 1,
                child: ActivityList(
                  title: "Prescription Queue",
                  onSeeAll: () {},
                  items: [
                    ActivityItem(
                      title: "John Doe",
                      subtitle: "Amoxicillin - Waiting",
                      time: "5m ago",
                      icon: Icons.pending_actions_outlined,
                      iconColor: Colors.orange,
                    ),
                    ActivityItem(
                      title: "Jane Smith",
                      subtitle: "Paracetamol - Ready",
                      time: "12m ago",
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    ActivityItem(
                      title: "Robert Brown",
                      subtitle: "Insulin - Ready",
                      time: "25m ago",
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                    ),
                    ActivityItem(
                      title: "Emma Wilson",
                      subtitle: "Ibuprofen - Processing",
                      time: "40m ago",
                      icon: Icons.sync_outlined,
                      iconColor: Colors.blue,
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
