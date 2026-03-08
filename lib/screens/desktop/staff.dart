import 'dart:math';
import 'package:enapel/controller/staff_controller.dart';
import 'package:enapel/models/staff_model.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/staff/filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/utils/app_color.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagementScreen> {
  final StaffController staffController = Get.put(StaffController());
  List<StaffModel> filteredStaffList = [];
  bool isFilterActive = false;

  int currentIndex = 0;

  final List<String> tableTypes = ['Staffs', 'Payroll', 'Permission'];
  List<String> roles = [
    'Admin',
    'Manager',
    'Supervisor',
    'Team Lead',
    'Viewer'
  ];
  // Track selected role
  String? selectedRole;
  // Track added roles dynamically
  List<String> addedRoles = [];

  final Map<String, List<String>> tableHeaders = {
    'Staffs': [
      'ID',
      'STAFFID',
      'NAME',
      'PHONE',
      'DESIGNATION',
      'ROLE',
      'DOB',
      'ACTIONS',
    ],
    'Payroll': [
      'ID',
      'STAFFID',
      'NAME',
      'DESIGNATION',
      'SALARY',
      'STATUS',
    ],
  };

  late Map<String, List<List<dynamic>>> tableData;

  @override
  void initState() {
    super.initState();
    staffController.getStaffs().then((_) {
      setState(() {
        filteredStaffList = staffController.staffList;
      });
    });
  }

  List<List<dynamic>> generateStaffData() {
    return staffController.staffList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final staff = entry.value;

      return [
        index.toString(),
        staff.staffId,
        staff.name,
        staff.phone,
        staff.designation,
        staff.role,
        staff.dob,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColor.primary),
              onPressed: () => showEditModal(staff),
              tooltip: 'Edit',
              iconSize: 20,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: AppColor.danger),
              onPressed: () => deleteStaff(staff),
              tooltip: 'Delete',
              iconSize: 20,
            ),
          ],
        ),
      ];
    }).toList();
  }

  List<List<dynamic>> generatePayrollData() {
    final random = Random();
    return staffController.staffList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final staff = entry.value;
      final isPaid = random.nextBool(); // Random true/false
      final paymentStatus = isPaid ? 'Paid' : 'Not Paid';

      return [
        index.toString(),
        staff.staffId,
        staff.name,
        staff.designation,
        staff.salary,
        Text(
          // Colored Paid/Not Paid
          paymentStatus,
          style: TextStyle(
            color: isPaid ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }).toList();
  }

  void _showFilterDialog() async {
    final filterOptions = {
      'Income Range': ['Below 3000', '3000-5000', 'Above 5000'],
      'Role': ['Admin', 'User', 'Cashier'],
      'Designation': ['Manager', 'Developer', 'HR', 'Cashier'],
    };

    final initialSelectedValues = {
      'Income Range': null,
      'Role': null,
      'Designation': null,
    };

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => FilterPopup(
        filterOptions: filterOptions,
        initialSelectedValues: initialSelectedValues,
        title: 'Staff Management Filters',
      ),
    );

    if (result != null) {
      final selectedIncomeRange = result['Income Range'];
      final selectedRole = result['Role'];
      final selectedDesignation = result['Designation'];

      setState(() {
        isFilterActive = true;
        filteredStaffList = staffController.staffList.where((staff) {
          final salary = int.tryParse(staff.salary ?? '0') ?? 0;

          final matchesIncome = selectedIncomeRange == null ||
              (selectedIncomeRange == 'Below 3000' && salary < 3000) ||
              (selectedIncomeRange == '3000-5000' &&
                  salary >= 3000 &&
                  salary <= 5000) ||
              (selectedIncomeRange == 'Above 5000' && salary > 5000);

          final matchesRole =
              selectedRole == null || staff.role == selectedRole;
          final matchesDesignation = selectedDesignation == null ||
              staff.designation == selectedDesignation;

          return matchesIncome && matchesRole && matchesDesignation;
        }).toList();
      });
    }
  }

  void showEditModal(StaffModel staff) {
    final nameController = TextEditingController(text: staff.name);
    final phoneController = TextEditingController(text: staff.phone);
    final dobController = TextEditingController(text: staff.dob);
    final salaryController = TextEditingController(text: staff.salary);

    final List<String> designations = [
      'Manager',
      'Assistant',
      'Clerk',
      'Technician'
    ];
    final List<String> roles = ['Admin', 'HR', 'IT', 'Support'];

    String selectedDesignation = designations.contains(staff.designation)
        ? staff.designation
        : designations.first;
    String selectedRole = roles.contains(staff.role) ? staff.role : roles.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColor.white, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Staff Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Two-column layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              labelText: 'Name',
                              controller: nameController,
                              hintText: 'Enter name',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Phone',
                              controller: phoneController,
                              hintText: 'Enter phone number',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Date of Birth',
                              controller: dobController,
                              hintText: 'YYYY-MM-DD',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              labelText: 'Designation',
                              hintText: 'Select designation',
                              dropdownItems: designations,
                              selectedDropdownValue: selectedDesignation,
                              onDropdownChanged: (value) {
                                selectedDesignation =
                                    value ?? designations.first;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Role',
                              hintText: 'Select role',
                              dropdownItems: roles,
                              selectedDropdownValue: selectedRole,
                              onDropdownChanged: (value) {
                                selectedRole = value ?? roles.first;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Salary',
                              controller: salaryController,
                              hintText: 'Enter salary',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await staffController.updateStaff(
                            staff.id,
                            nameController.text,
                            phoneController.text,
                            dobController.text,
                            selectedDesignation,
                            selectedRole,
                            salaryController.text,
                          );
                          await staffController.getStaffs();
                          setState(() {
                            tableData['Staffs'] = generateStaffData();
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Updated ${nameController.text}"),
                            ),
                          );
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteStaff(StaffModel staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.black,
        title: Text("Confirm Delete", style: TextStyle(color: AppColor.white)),
        content: Text("Delete ${staff.name}? This cannot be undone.",
            style: TextStyle(color: AppColor.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await staffController.deleteStaff(staff.id);
              await staffController.getStaffs();
              setState(() {
                tableData['Staffs'] = generateStaffData();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Deleted ${staff.name}")),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(dynamic text, bool isEvenRow, {Color? textColor}) {
    if (text is String) {
      return Container(
        padding: const EdgeInsets.all(8),
        width: 150,
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? (isEvenRow ? AppColor.white : AppColor.black),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        width: 150,
        child: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * 0.1;
    if (currentIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Container(
              width: double.infinity,
              color: AppColor.black.withOpacity(0.8),
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "STAFF MANAGEMENT",
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColor.black.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // First Box: Roles
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            color: AppColor.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'ROLES',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 23),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => showAddRoleModal(),
                                        icon: const Icon(Icons.add),
                                        label: const Text("Add Role"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColor.black.withOpacity(0.8),
                                          foregroundColor: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Scrollable Roles List
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: addedRoles.map((role) {
                                          return Row(
                                            children: [
                                              Checkbox(
                                                value:
                                                    true, // Manage checkbox state here
                                                onChanged: (value) {
                                                  setState(() {
                                                    // Optionally update checkbox state
                                                  });
                                                },
                                              ),
                                              Text(
                                                role,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Second Box: Permissions
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            color: AppColor.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'PERMISSIONS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 23),
                                      ),
                                      CustomButton(
                                        onPressed: () {
                                          // Handle Add Permission functionality here
                                        },
                                        icon: Icon(Icons.add,
                                            color: AppColor.white),
                                        label: "Add permission to role",
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColor.black.withOpacity(0.8),
                                          foregroundColor: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Dropdown for Roles under Permissions
                                  DropdownButton<String>(
                                    hint: Text("Select Role"),
                                    onChanged: (String? newValue) {
                                      // Handle role change here
                                    },
                                    items: addedRoles
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  // Scrollable Permissions List
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                value:
                                                    false, // Update with dynamic state
                                                onChanged: (value) {},
                                              ),
                                              const Text(
                                                'HR',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Checkbox(
                                                value:
                                                    false, // Update with dynamic state
                                                onChanged: (value) {},
                                              ),
                                              const Text(
                                                'Finance',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Checkbox(
                                                value:
                                                    true, // Update with dynamic state
                                                onChanged: (value) {},
                                              ),
                                              const Text(
                                                'Operations',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Table Section (with added fixes)
          Expanded(
            child: Column(
              children: [
                // Static Header
                Container(
                  color: AppColor.black,
                  child: Row(
                    children: ['Role', 'Permission', 'Date']
                        .map((header) => Expanded(
                              child: _buildCell(
                                header,
                                false,
                                textColor: AppColor.white,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                // Scrollable Rows
                Expanded(
                  child: ListView.builder(
                    itemCount: 4, // Number of roles
                    itemBuilder: (context, index) {
                      final roles = ['Admin', 'Manager', 'Editor', 'Viewer'];
                      final dates = [
                        '2024-12-01',
                        '2024-12-02',
                        '2024-12-03',
                        '2024-12-04'
                      ];
                      List<List<String>> permissions = [
                        ['Add User', 'Edit Settings', 'Delete Records'],
                        ['Approve Requests', 'Generate Reports'],
                        ['Edit Content', 'Manage Media'],
                        ['View Content']
                      ];

                      final isEvenRow = index % 2 == 0;

                      return Container(
                        color: isEvenRow ? AppColor.white : AppColor.black,
                        child: Row(
                          children: [
                            // Role
                            Expanded(
                              child: _buildCell(
                                roles[index],
                                isEvenRow,
                                textColor:
                                    isEvenRow ? AppColor.black : AppColor.white,
                              ),
                            ),
                            // Permissions
                            Expanded(
                              child: _buildCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: permissions[index]
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final permIndex = entry.key;
                                    final perm = entry.value;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: SizedBox(
                                        width: 150,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                perm,
                                                style: TextStyle(
                                                  color: isEvenRow
                                                      ? AppColor.black
                                                      : AppColor.white,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: AppColor.danger,
                                                size: 22,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                setState(() {
                                                  // Remove the specific permission from the list
                                                  permissions[index]
                                                      .removeAt(permIndex);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                isEvenRow,
                              ),
                            ),
                            // Date
                            Expanded(
                              child: _buildCell(
                                dates[index],
                                isEvenRow,
                                textColor:
                                    isEvenRow ? AppColor.black : AppColor.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Navigation Section
          SizedBox(
            child: Container(
              color: AppColor.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: tableTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;

                  final icon = index == 0
                      ? Icons.group
                      : index == 1
                          ? Icons.monetization_on
                          : index == 2
                              ? Icons.assignment
                              : Icons.add;

                  final isActive = currentIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: Container(
                        color: isActive ? AppColor.primary : AppColor.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              color: isActive ? AppColor.black : AppColor.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                color: isActive
                                    ? AppColor.black
                                    : AppColor.white.withOpacity(0.5),
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      );
    }

    final tableType = tableTypes[currentIndex];
    final headers = tableHeaders[tableType]!;
    final rows = staffController.staffList!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        SafeArea(
          child: Container(
            width: double.infinity, // Ensures it spans the full width
            color: AppColor.black.withOpacity(0.8),
            padding:
                const EdgeInsets.all(16.0), // Adjust padding for better spacing
            child: Text(
              "STAFF MANAGEMENT",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start, // Centers the title horizontally
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Search and Filter Section
        Row(
          children: [
            CustomButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              label: "Filter",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
              ),
            ),
            if (isFilterActive)
              CustomButton(
                onPressed: () {
                  setState(() {
                    filteredStaffList = staffController.staffList;
                    isFilterActive = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: "Clear Filter",
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(width: 5),
            Expanded(
              child: CustomTextField(
                hintText: 'Search...', // Hint text for the search field
                isSearchField: true, // Enables the search icon as the prefix
                fillColor: AppColor.white, // Custom fill color
                borderRadius: 8.0, // Matches the rounded corner design
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              onPressed: () => showAddStaffDialog(tableType),
              icon: const Icon(Icons.add),
              label: "Add",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
              ),
            ),
            const SizedBox(width: 5),
            CustomButton(
              onPressed: () {}, // Placeholder
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                minimumSize: const Size(120, 40),
              ),
              child: Text(
                "Export",
                style: TextStyle(color: AppColor.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Data Table
        Expanded(
          child: Column(
            children: [
              // Static Header
              Container(
                color: AppColor.black, // Set header background to black
                child: Row(
                  children: headers
                      .map((header) => Expanded(
                            child: _buildCell(
                              header,
                              false,
                              textColor: AppColor.white, // Header text in white
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Scrollable Rows
              Obx(() {
                if (staffController.isLoading.value) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (staffController.hasError.value) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            "Server connection error",
                            style:
                                TextStyle(color: AppColor.danger, fontSize: 16),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            onPressed: () {
                              staffController.getStaffs();
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }

                final staffToRender = isFilterActive
                    ? filteredStaffList
                    : staffController.staffList;

                final rows = tableTypes[currentIndex] == 'Staffs'
                    ? (isFilterActive
                            ? filteredStaffList
                            : staffController.staffList)
                        .asMap()
                        .entries
                        .map((entry) {
                        final index = entry.key + 1;
                        final staff = entry.value;
                        return [
                          index.toString(),
                          staff.staffId,
                          staff.name,
                          staff.phone,
                          staff.designation,
                          staff.role,
                          staff.dob,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: AppColor.primary),
                                onPressed: () => showEditModal(staff),
                                tooltip: 'Edit',
                                iconSize: 20,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: AppColor.danger),
                                onPressed: () => deleteStaff(staff),
                                tooltip: 'Delete',
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ];
                      }).toList()
                    : generatePayrollData(); // When on 'Payroll'

                if (rows.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text("No staff found")),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final isEvenRow = index % 2 == 0;

                      return Container(
                        color: isEvenRow ? AppColor.black : AppColor.white,
                        child: Row(
                          children: row.map((cell) {
                            return Expanded(
                              child: _buildCell(
                                cell,
                                isEvenRow,
                                textColor:
                                    isEvenRow ? AppColor.white : AppColor.black,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                );
              })
            ],
          ),
        ),

        // Bottom Navigation Bar
        Container(
          color: AppColor.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: tableTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;

              // Choose an icon for each table type
              final icon = index == 0
                  ? Icons.group // Icon for 'Staffs'
                  : index == 1
                      ? Icons.monetization_on // Icon for 'Payroll'
                      : Icons.add;

              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  child: Container(
                    color: isActive
                        ? AppColor.primary
                        : AppColor.black, // Active background
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: isActive
                              ? AppColor.black
                              : AppColor.white, // Active icon color
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: isActive
                                ? AppColor.black
                                : AppColor.white
                                    .withOpacity(0.5), // Active text color
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  void showAddRoleModal() {
    final TextEditingController roleController = TextEditingController();
    if (selectedRole != null) {
      roleController.text = selectedRole!;
    }
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColor.white),
              ),
              backgroundColor: AppColor.black,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dialog Title
                      Text(
                        "Add Role",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Custom Text Field for Input
                      CustomTextField(
                        labelText: 'Role',
                        labelTextColor: AppColor.white,
                        hintText: 'Enter Role',
                        controller: roleController,
                        dropdownItems: null, // Not a dropdown
                        onDropdownChanged: null, // Not used here
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Role cannot be empty';
                          }
                          return null;
                        },
                        onChanged: (newValue) {
                          setModalState(() {
                            selectedRole = newValue; // Update the selected role
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                            },
                            child: const Text("Cancel"),
                          ),
                          CustomButton(
                            onPressed: (selectedRole == null ||
                                    selectedRole!.isEmpty)
                                ? null
                                : () {
                                    setState(() {
                                      addedRoles
                                          .add(selectedRole!); // Add the role
                                    });
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Role '$selectedRole' added"),
                                        backgroundColor: AppColor.success,
                                      ),
                                    );
                                  },
                            child: const Text("Add Role"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showAddStaffDialog(tableType) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final dobController = TextEditingController();
    final salaryController = TextEditingController();

    final List<String> designations = [
      'Manager',
      'Assistant',
      'Clerk',
      'Technician'
    ];
    final List<String> roles = ['Admin', 'HR', 'IT', 'Support'];

    String selectedDesignation = designations.first;
    String selectedRole = roles.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColor.white, width: 2),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Add New Staff",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white)),
                  const SizedBox(height: 16),

                  // Two-column layout
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CustomTextField(
                              labelText: 'Name',
                              controller: nameController,
                              hintText: 'Enter name',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Phone',
                              controller: phoneController,
                              hintText: 'Enter phone',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Date of Birth',
                              controller: dobController,
                              hintText: 'YYYY-MM-DD',
                              readOnly: true,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      DateTime.tryParse(dobController.text) ??
                                          DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  dobController.text = pickedDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            CustomTextField(
                              labelText: 'Designation',
                              hintText: 'Select Designation',
                              dropdownItems: designations,
                              selectedDropdownValue: selectedDesignation,
                              onDropdownChanged: (val) {
                                selectedDesignation = val!;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Role',
                              hintText: 'Select Role',
                              dropdownItems: roles,
                              selectedDropdownValue: selectedRole,
                              onDropdownChanged: (val) {
                                selectedRole = val!;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              labelText: 'Salary',
                              controller: salaryController,
                              hintText: 'Enter salary',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CustomButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            CustomButton(
              child: const Text("Save"),
              onPressed: () async {
                await staffController.addStaff(
                  nameController.text,
                  phoneController.text,
                  dobController.text,
                  selectedDesignation,
                  selectedRole,
                  salaryController.text,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void applyFilters(String tableType, String? selectedHeader,
      DateTime? fromDate, DateTime? toDate) {
    if (selectedHeader == null) return;

    final filteredData = staffController.staffList.where((staff) {
      dynamic cellValue;

      // Map header name to the corresponding field in StaffModel
      switch (selectedHeader.toUpperCase()) {
        case 'NAME':
          cellValue = staff.name;
          break;
        case 'ROLE':
          cellValue = staff.role;
          break;
        case 'DESIGNATION':
          cellValue = staff.designation;
          break;
        case 'DOB':
          cellValue = staff.dob;
          break;
        case 'INCOME':
        case 'SALARY':
          cellValue = staff.salary;
          break;
        default:
          return true;
      }

      // Date filtering
      if (fromDate != null &&
          toDate != null &&
          selectedHeader.toLowerCase().contains("date")) {
        try {
          final cellDate = DateTime.parse(cellValue);
          return cellDate.isAfter(fromDate) && cellDate.isBefore(toDate);
        } catch (e) {
          return false;
        }
      }

      return true; // You can add more conditions here later
    }).toList();

    setState(() {
      filteredStaffList = filteredData;
      isFilterActive = true;
    });
  }
}
