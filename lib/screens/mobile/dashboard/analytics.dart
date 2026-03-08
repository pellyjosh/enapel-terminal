import 'dart:io';

import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/mobile/header.dart';
import 'package:enapel/widget/mobile/listview.dart';
import 'package:enapel/widget/staff/filter.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsSreenMobile extends StatefulWidget {
  const AnalyticsSreenMobile({super.key});

  @override
  State<AnalyticsSreenMobile> createState() => _AnalyticsSreenMobileState();
}

class _AnalyticsSreenMobileState extends State<AnalyticsSreenMobile> {
  String tableType = 'Sales Report';
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> tableData = [];

  final Map<String, List<Map<String, String>>> tableDataMap = {
    'Sales Report': List.generate(20, (index) {
      return {
        'id': 'ID-${index + 1}',
        'product': 'Product ${index + 1}',
        'unitsSold': '${(index + 1) * 5} units',
        'revenue': '₦${(index + 1) * 5000}',
        'date': '2024-11-${19 - index % 30}',
      };
    }),
    'Financial Report': List.generate(20, (index) {
      return {
        'id': 'ID-${index + 1}',
        'income': '₦${(index + 1) * 10000}',
        'expenses': '₦${(index + 1) * 7000}',
        'netProfit': '₦${(index + 1) * 3000}',
        'date': '2024-11-${19 - index % 30}',
      };
    }),
    'Stock Report': List.generate(20, (index) {
      return {
        'id': 'ID-${index + 1}',
        'item': 'Item ${index + 1}',
        'category': 'Category ${index + 1}',
        'stockLevel': '${(index + 1) * 10} pcs',
        'reorderStatus': (index % 5 == 0 ? 'Reorder' : 'Sufficient'),
      };
    }),
  };
  @override
  void initState() {
    super.initState();
    tableData = tableDataMap[tableType]!;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBarWidget(
          title: 'Analytics',
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
            // Show popup to select table type when tapped
            _showTableTypePopup(context);
          },
        ),

        // Data Table
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount:
                tableData.length, // Dynamically change based on tableData
            itemBuilder: (context, index) {
              final rowData = tableData[index];
              return DynamicListItem(
                backgroundColor: index.isEven ? AppColor.white : AppColor.black,
                leading: Icon(Icons.inventory, color: AppColor.primary),
                title: Text(
                  rowData['product'] ?? rowData['item'] ?? rowData['id'] ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: index.isEven ? AppColor.black : AppColor.white,
                  ),
                ),
                subtitle: Text(
                  rowData['category'] ?? rowData['unitsSold'] ?? rowData['netProfit'] ??'',
                  style: TextStyle(
                    color: index.isEven ? AppColor.black : AppColor.white,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                  rowData['revenue'] ??
                          rowData['income'] ??
                          rowData['stockLevel'] ??
                          '',
                      style: TextStyle(
                        color: index.isEven ? AppColor.black : AppColor.white,
                      ),
                    ),
                    Icon(Icons.more_vert, color: AppColor.grey),
                  ],
                ),
                isEven: index.isEven,
                onTap: () {
                  // Show full details of the tapped item
                  _showItemDetails(context, rowData); // Pass context here
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Popup to show available report types
  void _showTableTypePopup(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(
          100, 100, 0, 0), // Adjust position based on your UI needs
      items: [
        PopupMenuItem<String>(
          value: 'Sales Report',
          child: Text(
            'Sales Report',
            style: TextStyle(
              color: tableType == 'Sales Report' ? AppColor.primary : AppColor.black,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Financial Report',
          child: Text(
            'Financial Report',
            style: TextStyle(
              color:
                  tableType == 'Financial Report' ? AppColor.primary : AppColor.black,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Stock Report',
          child: Text(
            'Stock Report',
            style: TextStyle(
              color: tableType == 'Stock Report' ? AppColor.primary : AppColor.black,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _updateTableData(
            value); // Update the table data based on the selected report type
      }
    });
  }


  // Update table data based on selected report type
  void _updateTableData(String reportType) {
    setState(() {
      tableType = reportType;
      tableData = tableDataMap[
          tableType]!; // Update list data for the selected report type
    });
  }

  // Show full details for selected item in the list
 void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    // Dynamically determine the table type fields to show
    List<Map<String, String>> detailsFields;

    if (tableType == 'Sales Report') {
      detailsFields = [
        {'label': 'ID', 'value': item['id'] ?? ''},
        {'label': 'Product', 'value': item['product'] ?? ''},
        {'label': 'Units Sold', 'value': item['unitsSold'] ?? ''},
        {'label': 'Revenue', 'value': item['revenue'] ?? ''},
        {'label': 'Date', 'value': item['date'] ?? ''},
      ];
    } else if (tableType == 'Financial Report') {
      detailsFields = [
        {'label': 'ID', 'value': item['id'] ?? ''},
        {'label': 'Income', 'value': item['income'] ?? ''},
        {'label': 'Expenses', 'value': item['expenses'] ?? ''},
        {'label': 'Net Profit', 'value': item['netProfit'] ?? ''},
        {'label': 'Date', 'value': item['date'] ?? ''},
      ];
    } else if (tableType == 'Stock Report') {
      detailsFields = [
        {'label': 'ID', 'value': item['id'] ?? ''},
        {'label': 'Item', 'value': item['item'] ?? ''},
        {'label': 'Category', 'value': item['category'] ?? ''},
        {'label': 'Stock Level', 'value': item['stockLevel'] ?? ''},
        {'label': 'Reorder Status', 'value': item['reorderStatus'] ?? ''},
      ];
    } else {
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
              
            ],
          ),
        );
      },
    );
  }

}
