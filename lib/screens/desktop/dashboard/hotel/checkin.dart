import 'package:enapel/controller/hotel/hotel_controller.dart';
import 'package:enapel/models/room_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:enapel/widget/custom_button.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CheckinScreen extends StatefulWidget {
  final dynamic navigateToDashboardContent;
  const CheckinScreen({super.key, required this.navigateToDashboardContent});

  @override
  State<CheckinScreen> createState() => _CheckinState();
}

class _CheckinState extends State<CheckinScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController paidInController = TextEditingController();
  final TextEditingController amountPaidController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final HotelController hotelController = Get.put(HotelController());
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColor.black.withOpacity(0.7),
            child: Center(
              child: Container(
                width: screenWidth * 0.72,
                height: screenHeight * 0.8,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            hotelController.selectedRoomName.isNotEmpty
                                ? "Check-In: ${hotelController.selectedRoomName.value}"
                                : "Check-In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.025,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SfDateRangePicker(
                          selectionMode: DateRangePickerSelectionMode.range,
                          enablePastDates: false,
                          initialSelectedRange: PickerDateRange(
                            DateTime.now(),
                            DateTime.now().add(const Duration(days: 1)),
                          ),
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is PickerDateRange) {
                              selectedStartDate = args.value.startDate;
                              selectedEndDate = args.value.endDate ??
                                  args.value.startDate
                                      ?.add(const Duration(days: 1));
                            }
                          },
                          backgroundColor: AppColor.white,
                          headerStyle: DateRangePickerHeaderStyle(
                            backgroundColor: AppColor.black,
                            textStyle: TextStyle(
                              color: AppColor.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          monthViewSettings: DateRangePickerMonthViewSettings(
                            viewHeaderStyle: DateRangePickerViewHeaderStyle(
                              textStyle: TextStyle(
                                color: AppColor.black.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          selectionColor: AppColor.black,
                          startRangeSelectionColor: AppColor.black,
                          endRangeSelectionColor: AppColor.black,
                          rangeSelectionColor: AppColor.black.withOpacity(0.15),
                          selectionTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          rangeTextStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          monthCellStyle: DateRangePickerMonthCellStyle(
                            textStyle: TextStyle(
                              color: AppColor.black,
                            ),
                            todayCellDecoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(
                              color: AppColor.black,
                              fontWeight: FontWeight.bold,
                            ),
                            specialDatesDecoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: "Name",
                                hintText: "Enter Name",
                                controller: nameController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                labelText: "Address",
                                hintText: "Enter Address",
                                controller: addressController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: "Phone Number",
                                hintText: "Enter Phone Number",
                                controller: phoneController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                labelText: "Email",
                                hintText: "Enter Email",
                                controller: emailController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: CustomButton(
                            label: "Check In",
                            onPressed: () {
                              _showCheckInModal(
                                context,
                                hotelController.selectedRoomName.value,
                                hotelController.selectedRoomId.value,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCheckInModal(BuildContext context, String roomName, int roomId) {
    if (selectedStartDate == null || selectedEndDate == null) {
      _showErrorDialog(
          context, 'Please select check-in and check-out dates first.');
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Confirm Check-In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColor.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Guest Name: ${nameController.text.trim()}'),
              const SizedBox(height: 8),
              Text('Room: $roomName'),
              const SizedBox(height: 8),
              Text(
                  'Check-In Date: ${DateFormat('yyyy-MM-dd').format(selectedStartDate!)}'),
              const SizedBox(height: 8),
              Text(
                  'Check-Out Date: ${DateFormat('yyyy-MM-dd').format(selectedEndDate!)}'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColor.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final guestName = nameController.text.trim();
                        final guestEmail = emailController.text.trim();
                        final guestPhone = phoneController.text.trim();

                        if (guestName.isEmpty) {
                          _showErrorDialog(context, 'Guest name is required.');
                          return;
                        }
                        if (selectedStartDate == null) {
                          _showErrorDialog(
                              context, 'Please select a check-in date.');
                          return;
                        }
                        if (selectedEndDate == null) {
                          _showErrorDialog(
                              context, 'Please select a check-out date.');
                          return;
                        }
                        if (selectedEndDate!.isBefore(selectedStartDate!)) {
                          _showErrorDialog(context,
                              'Check-out date must be after check-in date.');
                          return;
                        }

                        final request = CheckinRequest(
                          guestName: guestName,
                          guestEmail: guestEmail.isEmpty ? null : guestEmail,
                          guestPhone: guestPhone.isEmpty ? null : guestPhone,
                          roomId: roomId,
                          checkIn: selectedStartDate!,
                          checkOut: selectedEndDate!,
                        );

                        await hotelController.checkin(request);

                        if (hotelController.successMessage.isNotEmpty) {
                          Navigator.pop(context);
                          nameController.clear();
                          emailController.clear();
                          phoneController.clear();
                          selectedStartDate = null;
                          selectedEndDate = null;
                          widget.navigateToDashboardContent(9);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Obx(() {
                        return hotelController.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColor.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Confirm');
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
