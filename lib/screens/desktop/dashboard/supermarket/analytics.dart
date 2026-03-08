import 'dart:io';
import 'package:enapel/controller/analytics_controller.dart';
import 'package:enapel/models/reports_model.dart';
import 'package:enapel/widget/bottomnav.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/staff/filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AnalyticsReportScreen extends StatefulWidget {
  const AnalyticsReportScreen({super.key});

  @override
  State<AnalyticsReportScreen> createState() => _AnalyticsReportState();
}

class _AnalyticsReportState extends State<AnalyticsReportScreen> {
  String tableType = 'Sales Report';
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();
  final AnalyticsController controller = Get.put(AnalyticsController());
  String? selectedHeader;
  DateTime? fromDate;
  DateTime? toDate;
  final RxInt currentIndex = 0.obs;
 final RxString currentTable = 'Sales Report'.obs;
  bool isFilterActive = false;
  List<List<dynamic>> filteredAnalyticsData = []; // holds filtered rows


  List<Map<String, String>> tableData = [];

  final Map<String, List<DataColumn>> tableColumns = {
    'Sales Report': const [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('PRODUCT')),
      DataColumn(label: Text('UNITS SOLD')),
      DataColumn(label: Text('REVENUE')),
      DataColumn(label: Text('DATE')),
    ],
    'Financial Report': const [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('INCOME')),
      DataColumn(label: Text('EXPENSES')),
      DataColumn(label: Text('NET PROFIT')),
      DataColumn(label: Text('DATE')),
    ],
    'Stock Report': const [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('ITEM')),
      DataColumn(label: Text('CATEGORY')),
      DataColumn(label: Text('STOCK LEVEL')),
      DataColumn(label: Text('REORDER STATUS')),
    ],
  };

 List<DataCell> getRowCells(
  
    String tableType,
    int index,
    bool isBlackRow, {
    required List<SalesModel> salesList,
    required List<FinanceSummaryModel> financeSummaryList,
  }) {
    switch (tableType) {
      case 'Sales Report':
        final sale = salesList[index];
        return [
           DataCell(Text('${index + 1}')),
          DataCell(Text(sale.productName)),
          DataCell(Text('${sale.quantity} units')),
          DataCell(Text('₦${sale.price}')),
          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt))),
        ];

     case 'Financial Report':
  final finance = financeSummaryList[index];
  return [
    DataCell(Text('${index + 1}')),
    DataCell(Text('₦${finance.revenue ?? 0}')),
    DataCell(Text('₦${finance.expenses}')),
    DataCell(Text('₦${finance.netProfit}')),
    DataCell(Text(finance.date)),
  ];

      case 'Stock Report':
        return [
          DataCell(Text('ID-${index + 1}')),
          DataCell(Text('Item ${index + 1}')),
          DataCell(Text('Category ${index + 1}')),
          DataCell(Text('${(index + 1) * 10} pcs')),
          DataCell(Text((index % 5 == 0 ? 'Reorder' : 'Sufficient'))),
        ];
      default:
        return [];
    }
  }

  Future<void> exportToExcel(String tableType) async {
    var excel = Excel.createExcel();
    final sheet = excel[tableType];

    // Add header row
    sheet.appendRow(
      tableColumns[tableType]!
          .map((column) {
            if (column.label is Text) {
              return (column.label as Text).data ?? '';
            }
            return '';
          })
          .cast<CellValue?>()
          .toList(),
    );

    // Add data rows
    for (var i = 0; i < 50; i++) {
      sheet.appendRow(
        getRowCells(
          tableType,
          i,
          false,
          salesList: controller.salesList,
          financeSummaryList: controller.financeSummaryList,
        )
            .map((cell) {
              final text = cell.child as Text;
              return text.data ?? '';
            })
            .cast<CellValue?>()
            .toList(),
      );
    }

    // Save the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$tableType.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    Get.snackbar("Export Successful", "File saved at $filePath",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

void _showAnalyticsFilterDialog() async {
    final filterOptions = {
      'Revenue Range': ['Below 10,000', '10,000 - 50,000', 'Above 50,000'],
    };

    final initialSelectedValues = {
      'Revenue Range': null,
    };

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => FilterPopup(
        filterOptions: filterOptions,
        initialSelectedValues: initialSelectedValues,
        title: 'Analytics Filters',
        enableDateFilter: true,
      ),
    );

    if (result != null) {
      final selectedRevenue = result['Revenue Range'];
      final from = result['fromDate'] != null
          ? DateTime.parse(result['fromDate']!)
          : null;
      final to =
          result['toDate'] != null ? DateTime.parse(result['toDate']!) : null;

      setState(() {
        isFilterActive = true;
        fromDate = from;
        toDate = to;

        final dataList = controller.salesList;

        filteredAnalyticsData = dataList
            .where((sale) {
              bool matchesRevenue = true;
              bool matchesDate = true;

              // Revenue filter
              if (selectedRevenue != null) {
                final price = sale.price;
                if (selectedRevenue == 'Below 10,000') {
                  matchesRevenue = price < 10000;
                } else if (selectedRevenue == '10,000 - 50,000') {
                  matchesRevenue = price >= 10000 && price <= 50000;
                } else if (selectedRevenue == 'Above 50,000') {
                  matchesRevenue = price > 50000;
                }
              }

              // Date filter
              if (from != null && to != null) {
                final saleDate = sale.createdAt;
                matchesDate = saleDate.isAfter(from) && saleDate.isBefore(to);
              }

              return matchesRevenue && matchesDate;
            })
            .map((sale) => [
                  sale.id,
                  sale.productName,
                  "${sale.quantity} units",
                  "₦${sale.price}",
                  DateFormat('yyyy-MM-dd HH:mm').format(sale.createdAt),
                ])
            .toList();
      });
    }
  }

void switchTable(int index) {
    currentIndex.value = index;
    currentTable.value = index == 0
        ? 'Sales Report'
        : index == 1
            ? 'Financial Report'
            : 'Stock Report';
  }




@override
  void initState() {
    super.initState();

    ever(currentTable, (String type) {
      if (type == 'Sales Report') {
        controller.fetchSales();
      } else if (type == 'Financial Report') {
        controller.fetchFinanceSummary();
      }
    });

    // Defer trigger until after first build frame
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   currentTable.value = 'Sales Report';
    // });
  }


  @override
  Widget build(BuildContext context) {
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
              "ANALYTICS",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start, // Centers the title horizontally
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Search and Filter Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
              onPressed: _showAnalyticsFilterDialog,
              icon: const Icon(Icons.filter_list),
              label: "Filter",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
                minimumSize: const Size(100, 40), // Fixed button size
              ),
            ),
            if (isFilterActive)
              CustomButton(
                onPressed: () {
                  setState(() {
                    filteredAnalyticsData.clear();
                    isFilterActive = false;
                  });
                },
                icon: Icon(Icons.clear),
                label: "Clear Filter",
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.danger,
                  foregroundColor: AppColor.white,
                ),
              ),

            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                hintText: 'Search...', // Hint text for the search field
                isSearchField: true, // Enables the search icon as the prefix
                fillColor: AppColor.white, // Custom fill color
                borderRadius: 8.0, // Matches the rounded corner design
                controller: searchController, // Use your existing controller
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              onPressed: () => exportToExcel(tableType),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                minimumSize: const Size(120, 40), // Fixed button size
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
        color: AppColor.black.withOpacity(0.9),
        child: Row(
          children: tableColumns[currentTable]!
              .map(
                (col) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      (col.label is Text)
                          ? (col.label as Text).data ?? ''
                          : '',
                      style: TextStyle(
                          color: AppColor.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      // Scrollable Rows
    Expanded(
             child: Obx(() {
              if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final isSales = currentTable.value == 'Sales Report';

                  // Build the full unfiltered list
                  List<List<dynamic>> rawList = isSales
                      ? controller.salesList
                          .map((sale) => [
                                '', // Placeholder for ID, we'll insert index below
                                sale.productName,
                                "${sale.quantity} units",
                                "₦${sale.price}",
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(sale.createdAt),
                              ])
                          .toList()
                      : controller.financeSummaryList
                          .map((finance) => [
                                '', // Placeholder for ID
                                "₦${finance.revenue ?? 0}",
                                "₦${finance.expenses}",
                                "₦${finance.netProfit}",
                                finance.date,
                              ])
                          .toList();

                  if (controller.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Server connection error",
                              style: TextStyle(color: AppColor.danger)),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            onPressed: () {
                              if (currentTable == 'Sales Report') {
                                controller.fetchSales();
                              } else if (currentTable == 'Financial Report') {
                                controller.fetchFinanceSummary();
                              }
                            },
                          )
                        ],
                      ),
                    );
                  }

                  // Apply search query
                  List<List<dynamic>> filtered = rawList.where((row) {
                    if (searchQuery.isEmpty) return true;
                    return row.any((cell) => cell
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()));
                  }).toList();

                  // If filter active, override filtered with filteredAnalyticsData
                  if (isFilterActive && filteredAnalyticsData.isNotEmpty) {
                    filtered = filteredAnalyticsData;
                  }

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No data found."));
                  }

                  // Insert auto index number in ID column (first cell)
                  for (int i = 0; i < filtered.length; i++) {
                    filtered[i][0] = (i + 1).toString();
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final row = filtered[index];
                      final isBlackRow = index % 2 == 0;

                      return Container(
                        color: isBlackRow
                            ? AppColor.black.withOpacity(0.9)
                            : AppColor.white,
                        child: Row(
                          children: row.map((cell) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cell.toString(),
                                  style: TextStyle(
                                    color: isBlackRow
                                        ? AppColor.white
                                        : AppColor.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                }),

              ),

    ],
  ),
),

        // Footer Buttons
      Obx(() => Container(
              color: AppColor.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BottomNavItem(
                    icon: Icons.meeting_room,
                    label: 'Sales',
                    index: 0,
                    currentIndex: currentIndex.value,
                    onTap: () => switchTable(0),
                  ),
                  BottomNavItem(
                    icon: Icons.category,
                    label: 'Financial',
                    index: 1,
                    currentIndex: currentIndex.value,
                    onTap: () => switchTable(1),
                  ),
                  BottomNavItem(
                    icon: Icons.inventory,
                    label: 'Stock',
                    index: 2,
                    currentIndex: currentIndex.value,
                    onTap: () => switchTable(2),
                  ),
                ],
              ),
            ))

      ],
    );
  }
}
