import 'package:enapel/controller/patient_controller.dart';
import 'package:enapel/models/reports_model.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:enapel/widget/staff/filter.dart';
import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PatientmanagementScreen extends StatefulWidget {
  const PatientmanagementScreen({super.key});

  @override
  State<PatientmanagementScreen> createState() =>
      _PatientmanagementScreenState();
}

class _PatientmanagementScreenState extends State<PatientmanagementScreen> {
  final TextEditingController searchController = TextEditingController();
  final PatientController controller = Get.put(PatientController());
  Map<String, String?> selectedFilters = {};
  final List<int> columnFlexes = [1, 2, 2, 2, 3, 2, 2, 2];


  String searchQuery = "";

  final List<DataColumn> patientTableColumns = const [
    DataColumn(label: Text('ID')),
    DataColumn(label: Text('Name')),
    DataColumn(label: Text('Medication')),
    DataColumn(label: Text('Dosage')),
    DataColumn(label: Text('Prescription Status')),
    DataColumn(label: Text('Duration')), // 🔥 UPDATED
    DataColumn(label: Text('First Visit')), // 🔥 UPDATED
    DataColumn(label: Text('Last Visit')),
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients(); // 🔥 use wrapper
  }

  Future<void> _loadPatients() async {
    try {
      await controller.fetchPatients();
    } catch (e) {
      debugPrint("Init fetch error: $e");
    }
  }

  Future<void> openPatientFilterDialog() async {
    final filterOptions = {
      'Prescription Status': ['Active', 'Expired'],
      'Medication':
          controller.patientList.map((e) => e.medication).toSet().toList(),
      'Dosage': controller.patientList.map((e) => e.dosage).toSet().toList(),
    };

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => FilterPopup(
        filterOptions: filterOptions,
        initialSelectedValues: {
          for (var key in filterOptions.keys) key: selectedFilters[key],
        },
        title: 'Patient Filters',
      ),
    );

    if (result != null) {
      setState(() {
        selectedFilters = result;
      });
    }
  }

List<DataCell> buildPatientCells(PatientModel patient) {
    final firstVisit = patient.firstVisit;
    final lastVisit = patient.lastVisit;

    String durationText;
    String firstVisitText;
    String lastVisitText;

    if (firstVisit != null && lastVisit != null) {
      final duration = lastVisit.difference(firstVisit);
      durationText = '${duration.inDays} days';
      firstVisitText = DateFormat('yyyy-MM-dd').format(firstVisit);
      lastVisitText = DateFormat('yyyy-MM-dd').format(lastVisit);
    } else {
      durationText = 'N/A';
      firstVisitText = firstVisit != null
          ? DateFormat('yyyy-MM-dd').format(firstVisit)
          : 'N/A';
      lastVisitText = lastVisit != null
          ? DateFormat('yyyy-MM-dd').format(lastVisit)
          : 'N/A';
    }

    return [
      DataCell(Text('${patient.id}')),
      DataCell(Text(patient.name)),
      DataCell(Text(patient.medication)),
      DataCell(Text(patient.dosage)),
      DataCell(Text(patient.prescriptionStatus)),
      DataCell(Text(durationText)),
      DataCell(Text(firstVisitText)),
      DataCell(Text(lastVisitText)),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Container(
            width: double.infinity,
            color: AppColor.black.withOpacity(0.8),
            padding: const EdgeInsets.all(16),
            child: Text(
              "PATIENTS",
              style: TextStyle(
                  color: AppColor.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CustomButton(
              onPressed: openPatientFilterDialog,
              icon: const Icon(Icons.filter_list),
              label: "Filter",
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black.withOpacity(0.8),
                foregroundColor: AppColor.white,
                minimumSize: const Size(100, 40),
              ),
            ),
            Expanded(
              child: CustomTextField(
                hintText: 'Search...',
                isSearchField: true,
                fillColor: AppColor.white,
                borderRadius: 8.0,
                controller: searchController,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              onPressed: () {/* export logic */},
              child: Text("Export", style: TextStyle(color: AppColor.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                minimumSize: const Size(120, 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          color: AppColor.black.withOpacity(0.9),
          child: Row(
            children: List.generate(patientTableColumns.length, (index) {
              return Expanded(
                flex: columnFlexes[index],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    (patientTableColumns[index].label as Text).data ?? '',
                    style: TextStyle(
                        color: AppColor.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
           
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                // 🔥 show error + retry
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.errorMessage.value,
                        style: TextStyle(color: AppColor.danger, fontSize: 16)),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: _loadPatients,
                      child: Text("Retry",
                          style: TextStyle(color: AppColor.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary),
                    )
                  ],
                ),
              );
            }

            final filteredPatients = controller.patientList.where((patient) {
              final patientString =
                  '${patient.name} ${patient.medication} ${patient.prescriptionStatus}'
                      .toLowerCase();
              bool matchesSearch = patientString.contains(searchQuery);
              bool matchesFilter = true;
              selectedFilters.forEach((key, value) {
                if (value != null) {
                  switch (key) {
                    case 'Prescription Status':
                      if (patient.prescriptionStatus != value)
                        matchesFilter = false;
                      break;
                    case 'Medication':
                      if (patient.medication != value) matchesFilter = false;
                      break;
                    case 'Dosage':
                      if (patient.dosage != value) matchesFilter = false;
                      break;
                  }
                }
              });
              return matchesSearch && matchesFilter;
            }).toList();

            return ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                final isBlackRow = index % 2 == 0;
                return Container(
                  color: isBlackRow
                      ? AppColor.black.withOpacity(0.9)
                      : AppColor.white,
                  child: Row(
                    children: List.generate(buildPatientCells(patient).length,
                        (index) {
                      final text =
                          buildPatientCells(patient)[index].child as Text;
                      return Expanded(
                        flex: columnFlexes[index],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            text.data ?? '',
                            style: TextStyle(
                              color:
                                  isBlackRow ? AppColor.white : AppColor.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
