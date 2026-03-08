import 'package:enapel/controller/hotel/hotel_controller.dart';
import 'package:enapel/models/room_model.dart';
import 'package:enapel/widget/bottomnav.dart';
import 'package:enapel/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:get/get.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationScreen> {
  final HotelController controller = Get.put(HotelController());
  int currentIndex = 0; // 0 = Recent, 1 = Past
  RxList<Reservation> allReservations = <Reservation>[].obs;
  String searchText = '';

  final tabs = ['Recent', 'Past'];

  List<Reservation> get filteredReservations {
    final now = DateTime.now();
    final isRecent = currentIndex == 0;

    final filteredByTime = allReservations.where((r) {
      if (isRecent) {
        return r.checkInDate.isBefore(now) && r.checkOutDate.isAfter(now);
      } else {
        return r.checkOutDate.isBefore(now);
      }
    });

    final lowerSearch = searchText.toLowerCase();
    return filteredByTime
        .where((r) => r.guestName.toLowerCase().contains(lowerSearch))
        .toList();
  }

  void switchTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller.getBookings();
    allReservations.bindStream(controller.bookings.stream);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          child: Container(
            width: double.infinity,
            color: AppColor.black.withOpacity(0.8),
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Reservations",
              style: TextStyle(
                color: AppColor.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: AppColor.white.withOpacity(0.7),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                   child: CustomTextField(
                hintText: 'Search...',
                isSearchField: true,
                fillColor: AppColor.white,
                borderRadius: 8.0,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
             onChanged: (value) {
                 
                },
              ),
                  ),
                
                Expanded(
                  child: Obx(() {
                    final filtered = filteredReservations;

                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (currentIndex == 1 &&
                        controller.errorMessage.isNotEmpty) {
                      return Stack(
                        children: [
                          Opacity(
                            opacity: 0.7,
                            child: Container(
                              color: Colors.black,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: controller.getBookings,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          currentIndex == 0
                              ? 'No recent bookings'
                              : 'No past bookings',
                          style: TextStyle(fontSize: 18, color: AppColor.black),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final reservation = filtered[index];
                        return ReservationItem(
                          reservation: reservation,
                          activeTab: tabs[currentIndex],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: AppColor.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BottomNavItem(
                icon: Icons.access_time,
                label: 'Recent',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => switchTab(0),
              ),
              BottomNavItem(
                icon: Icons.history,
                label: 'Past',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => switchTab(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final String activeTab;

  const ReservationItem({
    required this.reservation,
    required this.activeTab,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int duration =
        reservation.checkOutDate.difference(reservation.checkInDate).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Icon
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: AppColor.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Icon(
              Icons.hotel,
              color: AppColor.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Reservation Details
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Name
                  Text(
                    reservation.roomName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Check-in: ${reservation.checkInDate.toLocal().toString().split(' ')[0]}",
                          style:  TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Duration: $duration days",
                          style:  TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activeTab != 'Recent') ...[
                    const SizedBox(height: 2),
                    Text(
                      "Check-out: ${reservation.checkOutDate.toLocal().toString().split(' ')[0]}",
                      style:  TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColor.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    "Guest: ${reservation.guestName} (${reservation.guestPhone})",
                    style:  TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: AppColor.black.withOpacity(0.5),
                     ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
