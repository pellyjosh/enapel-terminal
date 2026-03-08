import 'package:enapel/controller/patient_controller.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();
  final TextEditingController dosageNumberController = TextEditingController();

  String? selectedDosageUnit;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  final patientController = Get.put(PatientController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColor.black.withOpacity(0.7),
            child: Stack(
              children: [
                // Back arrow at the top-left corner
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColor.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // Main content container
                Center(
                  child: Container(
                    width: screenWidth * 0.72,
                    height: screenHeight * 0.7,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Form title
                            Text(
                              "Patient Register",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.03,
                                color: AppColor.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  // LEFT COLUMN
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            labelText: "Name",
                                            controller: nameController,
                                            hintText: "Enter Name",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Name required";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          CustomTextField(
                                            labelText: "Medication",
                                            controller: medicationController,
                                            hintText: "Enter Medication",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Medication required";
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomTextField(
                                                  labelText: "Dosage Amount",
                                                  textColor: AppColor.black,
                                                  controller:
                                                      dosageNumberController,
                                                  hintText:
                                                      "Enter dosage amount",
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Dosage number required";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: CustomTextField(
                                                  backgroundColor:
                                                      AppColor.white,
                                                  labelText: "Dosage Unit",
                                                  dropdownItems: const [
                                                    "mg",
                                                    "ml",
                                                    "g",
                                                    "kg",
                                                    "mcg",
                                                    "L",
                                                    "IU",
                                                    "tablet",
                                                    "capsule",
                                                    "drop"
                                                  ],
                                                  selectedDropdownValue:
                                                      selectedDosageUnit,
                                                  onDropdownChanged: (value) {
                                                    setState(() {
                                                      selectedDosageUnit =
                                                          value!;
                                                    });
                                                  },
                                                  hintText: "Select Unit",
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Dosage unit required";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    width: 2,
                                    height: screenHeight * 0.4,
                                    color: AppColor.black,
                                  ),
                                  const SizedBox(width: 20),
                                  // RIGHT COLUMN
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Last Visit Date Range"),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: SfDateRangePicker(
                                            selectionMode:
                                                DateRangePickerSelectionMode
                                                    .range,
                                            enablePastDates: false,
                                            initialSelectedRange:
                                                PickerDateRange(
                                              DateTime.now(),
                                              DateTime.now()
                                                  .add(const Duration(days: 1)),
                                            ),
                                            onSelectionChanged: (args) {
                                              if (args.value
                                                  is PickerDateRange) {
                                                setState(() {
                                                  selectedStartDate =
                                                      args.value.startDate;
                                                  selectedEndDate = args
                                                          .value.endDate ??
                                                      args.value.startDate?.add(
                                                          const Duration(
                                                              days: 1));
                                                });
                                              }
                                            },
                                            backgroundColor: AppColor.white,
                                            headerStyle:
                                                DateRangePickerHeaderStyle(
                                              backgroundColor: AppColor.black,
                                              textStyle: TextStyle(
                                                color: AppColor.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          monthViewSettings:
                                                DateRangePickerMonthViewSettings(
                                              viewHeaderStyle:
                                                  DateRangePickerViewHeaderStyle(
                                                textStyle: TextStyle(
                                                  color: AppColor.black
                                                      .withOpacity(0.7),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            selectionColor: AppColor.black,
                                            startRangeSelectionColor:
                                                AppColor.black,
                                            endRangeSelectionColor:
                                                AppColor.black,
                                            rangeSelectionColor: AppColor.black
                                                .withOpacity(0.15),
                                            selectionTextStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            rangeTextStyle: const TextStyle(
                                              color: Colors.black,
                                            ),
                                            monthCellStyle:
                                                DateRangePickerMonthCellStyle(
                                              textStyle: TextStyle(
                                                color: AppColor.black,
                                              ),
                                              todayCellDecoration:
                                                  BoxDecoration(
                                                color: AppColor.black
                                                    .withOpacity(0.05),
                                                shape: BoxShape.circle,
                                              ),
                                              todayTextStyle: TextStyle(
                                                color: AppColor.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              specialDatesDecoration:
                                                  BoxDecoration(
                                                color: AppColor.black
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: CustomButton(
                                label: "Register",
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (selectedStartDate == null ||
                                        selectedEndDate == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please select a date range")),
                                      );
                                      return;
                                    }

                                    final combinedDosage =
                                        "${dosageNumberController.text}${selectedDosageUnit!}";

                                    await patientController.addPatient(
                                      name: nameController.text,
                                      medication: medicationController.text,
                                      dosage: combinedDosage,
                                      prescriptionStatus: "Active",
                                      firstVisit: selectedStartDate!,
                                      lastVisit: selectedEndDate!,
                                    );

                                    nameController.clear();
                                    medicationController.clear();
                                    dosageNumberController.clear();
                                    selectedDosageUnit = null;
                                    setState(() {
                                      selectedStartDate = null;
                                      selectedEndDate = null;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Patient registered successfully"),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
