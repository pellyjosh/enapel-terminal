import 'package:enapel/widget/mobile/header.dart';
import 'package:flutter/material.dart';
import 'package:enapel/utils/app_color.dart';

class ReservationScreenMobile extends StatefulWidget {
  const ReservationScreenMobile({super.key});

  @override
  State<ReservationScreenMobile> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationScreenMobile> {
  String activeTab = 'Upcoming';

  final tabs = ['Upcoming', 'Past', 'Recent'];

  final Map<String, List<Map<String, String>>> reservationData = {
    'Upcoming': [
      {
        'title': 'Suite 401',
        'checkIn': '12 Mar 2021',
        'duration': 'Long (2 weeks)',
        'guests': '4 Adults',
        'author': 'John Doe',
      },
      {
        'title': 'Normal Room 120',
        'checkIn': '15 Mar 2021',
        'duration': 'Short (3 days)',
        'guests': '2 Adults',
        'author': 'Jane Smith',
      },
    ],
    'Past': [
      {
        'title': 'Suite 500',
        'checkIn': '10 Jan 2021',
        'duration': 'Long (1 month)',
        'guests': '5 Adults',
        'author': 'Alice Johnson',
      },
    ],
    'Recent': [
      {
        'title': 'Suite 300',
        'checkIn': '20 Nov 2021',
        'duration': 'Short (1 week)',
        'guests': '3 Adults',
        'author': 'Bob Marley',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       CustomAppBarWidget(
            title: 'Reservations',
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
              print('List tapped');
            }),
        Expanded(
          child: Container(
            color: AppColor.white.withOpacity(0.7),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: tabs.map((tab) {
                    final isActive = tab == activeTab;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          border: isActive
                              ? const Border(
                                  bottom:
                                      BorderSide(color: Colors.black, width: 2),
                                )
                              : null,
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: reservationData[activeTab]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final data = reservationData[activeTab]![index];
                      return ReservationItem(data: data);
                    },
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

class ReservationItem extends StatelessWidget {
  final Map<String, String> data;

  const ReservationItem({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showReservationDetails(context, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.18,
              height: screenWidth * 0.18,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "By: ${data['author'] ?? ''}",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showReservationDetails(BuildContext context, Map<String, String> data) {
   showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                 child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Check In: ${data['checkIn'] ?? ''}",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("Duration: ${data['duration'] ?? ''}",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text("Guests: ${data['guests'] ?? ''}",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              ),
            Expanded(child: Container())
          ],
        ),
      );
    },
  );
}