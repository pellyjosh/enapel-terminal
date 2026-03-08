import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/mobile/header.dart';
import 'package:enapel/widget/mobile/listview.dart';
import 'package:flutter/material.dart';

class StaffMobileScreen extends StatefulWidget {
  const StaffMobileScreen({super.key});

  @override
  State<StaffMobileScreen> createState() => _StaffMobileScreenState();
}

class _StaffMobileScreenState extends State<StaffMobileScreen> {
  String tableType = 'staff';
  List<Map<String, String>> tableData = [];

  final Map<String, List<Map<String, String>>> tableDataMap = {
    'staff': List.generate(20, (index) {
      return {
        'id': 'ID-${index + 1}',
        'staffid': 'ENP-57246879${index + 2}',
        'name': 'Uche ${index + 1}',
        'phone': '0906574564${(index + 1) * 5}',
        'designation': 'Cashier',
        'role': 'Cashier',
        'dob': '2024-11-${19 - index % 30}',
      };
    }),
    'payroll': List.generate(20, (index) {
      return {
        'id': 'ID-${index + 1}',
        'income': '₦${(index + 1) * 10000}',
        'staffid': 'ENP-57246879${index + 2}',
        'name': 'Uche ${index + 1}',
        'designation': 'Cashier',
        'salary': '₦${(index + 1) * 5000}',
      };
    }),
  };

  List<String> addedRoles = ['Admin', 'Manager', 'Editor', 'Viewer'];
  Map<String, List<String>> rolePermissions = {
    'Admin': ['Add User', 'Edit Settings', 'Delete Records'],
    'Manager': ['Approve Requests', 'Generate Reports'],
    'Editor': ['Edit Content', 'Manage Media'],
    'Viewer': ['View Content'],
  };

  @override
  void initState() {
    super.initState();
    tableData = tableDataMap[tableType] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBarWidget(
          title: 'Staff Info',
          menuIcon: Icons.menu,
          searchIcon: Icons.search,
          barcodeIcon: Icons.qr_code_scanner,
          listIcon: Icons.list,
          onMenuTap: () {
            print('Menu tapped');
          },
          onSearchTap: () {
            // Trigger search logic
          },
          onBarcodeTap: () {
            print('Barcode tapped');
          },
          onListTap: () {
            _showTableTypePopup(context);
          },
        ),
        Expanded(
          child: tableType == 'permissions'
              ? _buildPermissionsScreen()
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tableDataMap[tableType]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final rowData = tableDataMap[tableType]?[index] ?? {};
                    return DynamicListItem(
                      backgroundColor:
                          index.isEven ? AppColor.white : AppColor.black,
                      leading: Icon(Icons.person, color: AppColor.primary),
                      title: Text(
                        rowData['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: index.isEven ? AppColor.black : AppColor.white,
                        ),
                      ),
                      subtitle: Text(
                        rowData['designation'] ?? rowData['role'] ?? '',
                        style: TextStyle(
                          color: index.isEven ? AppColor.black : AppColor.white,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rowData['salary'] ?? rowData['income'] ?? '',
                            style: TextStyle(
                              color: index.isEven
                                  ? AppColor.black
                                  : AppColor.white,
                            ),
                          ),
                          Icon(Icons.more_vert, color: AppColor.grey),
                        ],
                      ),
                      isEven: index.isEven,
                      onTap: () {
                        _showItemDetails(context, rowData);
                      },
                    );
                  },
                ),
        ),

      ],
    );
  }
void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    List<Map<String, String>> detailsFields = [];

    switch (tableType) {
      case 'staff':
        detailsFields = [
          {'label': 'ID', 'value': item['id'] ?? ''},
          {'label': 'Staff ID', 'value': item['staffid'] ?? ''},
          {'label': 'Name', 'value': item['name'] ?? ''},
          {'label': 'Designation', 'value': item['designation'] ?? ''},
          {'label': 'Phone', 'value': item['phone'] ?? ''},
          {'label': 'DOB', 'value': item['dob'] ?? ''},
        ];
        break;
      case 'payroll':
        detailsFields = [
          {'label': 'ID', 'value': item['id'] ?? ''},
          {'label': 'Staff ID', 'value': item['staffid'] ?? ''},
          {'label': 'Name', 'value': item['name'] ?? ''},
          {'label': 'Designation', 'value': item['designation'] ?? ''},
          {'label': 'Salary', 'value': item['salary'] ?? ''},
          {'label': 'Income', 'value': item['income'] ?? ''},
        ];
        break;
      default:
        detailsFields = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
       return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var field in detailsFields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '${field['label']}: ${field['value']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
               Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    onPressed: () {
                      // Implement edit functionality here
                      print("Edit button pressed");
                    },
                    child: const Text('Edit'),
                  ),
                  CustomButton(
                    onPressed: () {
                      // Implement delete functionality here
                      print("Delete button pressed");
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPermissionsScreen() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Box: Roles
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      color: AppColor.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ROLES',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => (),
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
                                          value: true,
                                          onChanged: (value) {
                                            setState(() {
                                              // Optionally update checkbox state
                                            });
                                          },
                                        ),
                                        Text(
                                          role,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 10),
                    // Second Box: Permissions
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      color: AppColor.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  icon: Icon(Icons.add, color: AppColor.white),
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
                              items: addedRoles.map<DropdownMenuItem<String>>(
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
                                          value: false,
                                          onChanged: (value) {},
                                        ),
                                        const Text(
                                          'HR',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: false,
                                          onChanged: (value) {},
                                        ),
                                        const Text(
                                          'Finance',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: true,
                                          onChanged: (value) {},
                                        ),
                                        const Text(
                                          'Operations',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 10),
                    // Roles List at the bottom
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      itemCount: addedRoles.length,
                      itemBuilder: (context, index) {
                        String role = addedRoles[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: DynamicListItem(
                              backgroundColor:
                                index.isEven ? AppColor.white : AppColor.black,
                            leading:
                                Icon(Icons.person, color: AppColor.primary),
                            title: Text(
                              role,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                 color: index.isEven
                                    ? AppColor.black
                                    : AppColor.white,
                              ),
                            ),
                            onTap: () => _showPermissionsModal(role),
                            trailing: Icon(Icons.arrow_forward_ios),
                            isEven: index.isEven,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableTypePopup(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'staff',
          child: Text(
            'Staff',
            style: TextStyle(
              color: tableType == 'staff' ? AppColor.primary : AppColor.black,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'payroll',
          child: Text(
            'Payroll',
            style: TextStyle(
              color: tableType == 'payroll' ? AppColor.primary : AppColor.black,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'permissions',
          child: Text(
            'Roles & Permissions',
            style: TextStyle(
              color: tableType == 'permissions'
                  ? AppColor.primary
                  : AppColor.black,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          tableType = value;
        });
      }
    });
  }

  void _showPermissionsModal(String role) {
    List<String> permissions = rolePermissions[role] ?? [];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$role Permissions',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: permissions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text(permissions[index]),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
