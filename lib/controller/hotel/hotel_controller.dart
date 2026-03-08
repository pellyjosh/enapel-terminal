import 'dart:convert';

import 'package:enapel/api/api_service.dart';
import 'package:enapel/api/config.dart';
import 'package:enapel/database/connection.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/helper/db_connection_helper.dart';
import 'package:enapel/models/category_model.dart';
import 'package:enapel/models/room_model.dart';
import 'package:enapel/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HotelController extends GetxController {
  late final EnapelDatabase database;
  late final ApiService apiService;
  late final bool isServerMode;

  var roomStatistics = [].obs;
  var bookedDates = <DateTime>[].obs;
  var isRoomLoading = false.obs;
  var isCategoryLoading = false.obs;
  final roomError = false.obs;
  final categoryError = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;
  var selectedRoomId = 0.obs;
  var selectedRoomName = ''.obs;

  RxList<RoomModel> filteredRooms = <RoomModel>[].obs;
  RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;
  RxList<RoomModel> rooms = <RoomModel>[].obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  var bookings = <Reservation>[].obs;
  var isBookingLoading = false.obs;
  var bookingError = false.obs;

  // var bookings = <BookingModel>[].obs;

  var bookId = 0;
  var bookName = '';
  var bookEmail = '';
  var bookPhone = '';
  var bookAddress = '';

  HotelController() {
    _initialize();
  }

  Future<void> _initialize() async {
    isServerMode = await ConnectionHelper.isServerConnection();

    if (isServerMode) {
      apiService = Get.put(ApiService());
      await getRooms();
      await getCategories();
      await getBookings();
    } else {
      database = Get.put(EnapelDatabase(openLocalConnection()));
    }
  }

  void applyRoomSearchAndFilter(
      String searchQuery, Map<String, String?> filters) {
    final query = searchQuery.toLowerCase();

    filteredRooms.value = rooms.where((room) {
      bool matchesSearch = room.name.toLowerCase().contains(query);

      bool matchesFilters = true;
      if (filters['Category'] != null) {
        matchesFilters =
            matchesFilters && (room.category == filters['Category']);
      }
      if (filters['Status'] != null) {
        matchesFilters = matchesFilters &&
            (room.status.toLowerCase() == filters['Status']!.toLowerCase());
      }

      return matchesSearch && matchesFilters;
    }).toList();
  }

  void applyCategorySearchAndFilter(
      String searchQuery, Map<String, String?> filters) {
    final query = searchQuery.toLowerCase();

    filteredCategories.value = categories.where((category) {
      bool matchesSearch = category.name.toLowerCase().contains(query);

      bool matchesFilters = true;
      if (filters['Description'] != null) {
        matchesFilters =
            matchesFilters && (category.description == filters['Description']);
      }

      return matchesSearch && matchesFilters;
    }).toList();
  }

  Future<void> getRooms(
      {String query = '', bool autoAssignToFiltered = false}) async {
    isRoomLoading.value = true;
    roomError.value = false;
    try {
      if (isServerMode) {
        final url = query.isNotEmpty
            ? '${Config.getRooms}?search=$query'
            : Config.getRooms;

        final response = await apiService.get(url);

        if (response['success'] == true) {
          List<dynamic> data = response['rooms'];
          List<RoomModel> roomList =
              data.map((room) => RoomModel.fromApi(room)).toList();
          rooms.assignAll(roomList);
          filteredRooms.assignAll(roomList);

          print(query.isEmpty
              ? "✅ Rooms successfully loaded from server."
              : "🔍 Search results loaded from server.");
        } else {
          print("⚠️ Error fetching rooms: ${response['message']}");
          roomError.value = true;
        }
      } else {
        print(query.isEmpty
            ? "✅ Rooms successfully loaded from local database."
            : "🔍 Search results loaded from local database.");
      }
    } catch (e) {
      print("❌ Error loading rooms: $e");
      roomError.value = true;
    } finally {
      isRoomLoading.value = false;
    }
  }

  Future<void> fetchRoomStatistics(String date) async {
    try {
      if (isServerMode) {
        final response =
            await apiService.get('${Config.getRoomStatistics}?date=$date');

        if (response['success'] == true) {
          roomStatistics.assignAll(response['data']);
          print('✅ Room statistics loaded from server');
        } else {
          print("⚠️ API Error: ${response['message']} - ${response['error']}");
        }
      } else {
        print("⚠️ Local DB call not implemented");
      }
    } catch (e) {
      print("❌ Error fetching room statistics: $e");
    } finally {
      isRoomLoading.value = false;
    }
  }

  Future<bool> fetchBookedDates(int roomId) async {
    try {
      final response = await apiService.get('${Config.getBookedDates}/$roomId');
      if (response['success'] == true) {
        bookedDates.value = (response['booked_dates'] as List)
            .map((date) => DateTime.parse(date))
            .toList();
        print('Booked dates loaded');
        return true;
      } else {
        print("Error: ${response['message']}");
        return false;
      }
    } catch (e) {
      print("Error fetching booked dates: $e");
      return false;
    }
  }

  void showLoading(String message) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  setBookParams(id, name, email, phone, address) {
    bookId = id;
    bookName = name;
    bookEmail = email;
    bookAddress = address;

    print('$bookId, $bookName');
  }

  resetBookParams() {
    bookId = 0;
    bookName = '';
    bookEmail = '';
    bookAddress = '';

    print('$bookId, $bookName');
  }

  Future<void> addRoom({
    required String name,
    required int category,
    required double price,
    required String status,
    required String tableType,
  }) async {
    isRoomLoading.value = true;
    showLoading("Adding room...");

    try {
      if (isServerMode) {
        final response = await apiService.post(Config.addRoom, {
          "name": name,
          "category_id": category.toString(),
          "price": price,
          "status": status.toLowerCase(),
        });

        if (response['success'] == true) {
          await getRooms();
          filteredRooms.assignAll(rooms); // 🔥 Re-assign filtered list
          filteredRooms.refresh();
          print("✅ Room added.");
        } else {
          print("⚠️ Failed to add room: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error adding room: $e");
    } finally {
      isRoomLoading.value = false;
      hideLoading();
      Get.snackbar(
        "Success",
        "Room added successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateRoom(RoomModel updatedRoom, int? categoryId) async {
    isRoomLoading.value = true;
    showLoading("Updating room...");

    try {
      if (isServerMode) {
        final url = '${Config.updateRoom}/${updatedRoom.id}';
        final body = updatedRoom.toJson();
        if (categoryId != null) {
          body['category_id'] = categoryId.toString();
        }

        final response = await apiService.post(url, body);

        if (response['message']?.toString().toLowerCase().contains('updated') ??
            false) {
          await getRooms();
          filteredRooms.assignAll(rooms); // 🔥 Ensure filtered list is updated
          filteredRooms.refresh(); // 🔁 Force reactive update
          print("✅ Room updated.");
        } else {
          print("⚠️ Failed to update room: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error updating room: $e");
    } finally {
      isRoomLoading.value = false;
      hideLoading();
      Get.snackbar(
        "Success",
        "Room updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteRoom(RoomModel room) async {
    isRoomLoading.value = true;
    showLoading("Deleting room...");

    try {
      if (isServerMode) {
        final response =
            await apiService.post("${Config.deleteRoom}/${room.id}", {});

        if (response['message']?.toString().toLowerCase().contains('deleted') ??
            false) {
          await getRooms();
          filteredRooms.assignAll(rooms); // 🔥 Re-assign filtered list
          filteredRooms.refresh(); // 🔁 Force refresh
          print("✅ Room deleted.");
        } else {
          print("⚠️ Failed to delete room: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error deleting room: $e");
    } finally {
      isRoomLoading.value = false;
      hideLoading();
      Get.snackbar(
        "Success",
        "Room deleted successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> getCategories() async {
    isCategoryLoading.value = true;
    categoryError.value = false;
    print("📡 Fetching categories from server...");
    try {
      if (isServerMode) {
        final response = await apiService.get(Config.getCategories);

        if (response.containsKey('data')) {
          List<dynamic> data = response['data'];
          List<CategoryModel> categoryList =
              data.map((cat) => CategoryModel.fromApi(cat)).toList();
          categories.assignAll(categoryList);
          filteredCategories.assignAll(categoryList);
          print("✅ Categories successfully loaded from server.");
        } else {
          print("⚠️ Error fetching categories: response has no 'data' key.");
          categoryError.value = true;
        }
      } else {
        print("⚠️ Local DB call not implemented for categories.");
      }
    } catch (e) {
      print("❌ Error loading categories: $e");
      categoryError.value = true;
    } finally {
      isCategoryLoading.value = false;
    }
  }

  /// Add new category
  Future<void> addCategory(
      String name, String description, double price) async {
    try {
      if (isServerMode) {
        final response = await apiService.post(Config.addCategory, {
          "category": name,
          "description": description,
          "price": price,
        });

        if (response['success'] == true) {
          await getCategories();
          filteredCategories.assignAll(categories);
          categories.refresh();
          print("✅ Category added successfully.");
        } else {
          print("⚠️ Error adding category: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error adding category: $e");
    }
  }

  /// Update category
  Future<void> editCategory(
      int id, String name, String description, double price) async {
    try {
      if (isServerMode) {
        final response = await apiService.post("${Config.editCategory}/$id", {
          "name": name,
          "description": description,
          "base_price": price,
        });

        if (response['success'] == true) {
          final index = categories.indexWhere((c) => c.id == id);
          if (index != -1) {
            categories[index] = CategoryModel(
              id: id,
              name: name,
              description: description,
              basePrice: price,
            );
            filteredCategories.assignAll(categories);
            categories.refresh();
          }
          print("✅ Category updated successfully.");
        } else {
          print("⚠️ Error updating category: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error editing category: $e");
    }
  }

  /// Delete category
  Future<void> deleteCategory(int categoryId) async {
    try {
      if (isServerMode) {
        final response =
            await apiService.delete("${Config.deleteCategory}/$categoryId");

        if (response['success'] == true) {
          categories.removeWhere((c) => c.id == categoryId);
          filteredCategories.assignAll(categories);
          filteredCategories.refresh();
          print("✅ Category deleted successfully.");
        } else {
          print("⚠️ Error deleting category: ${response['message']}");
        }
      }
    } catch (e) {
      print("❌ Error deleting category: $e");
    }
  }

  Future<void> checkin(CheckinRequest request) async {
    // Show loading state immediately
    isLoading.value = true;
    successMessage.value = ''; // <-- Reset previous success messages

    // Validate required fields inside the request
    if (!request.isValid()) {
      isLoading.value = false;
      _showSnackbar(
          'Error', 'Please fill all required fields correctly', Colors.red);
      return;
    }

    // Validate dates
    if (request.checkIn.isAfter(request.checkOut)) {
      isLoading.value = false;
      _showSnackbar(
          'Error', 'Check-Out date cannot be before Check-In date', Colors.red);
      return;
    }

    try {
      if (isServerMode) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        String formattedCheckIn = dateFormat.format(request.checkIn);
        String formattedCheckOut = dateFormat.format(request.checkOut);

        // Send the request
        final response = await apiService.post(Config.bookRoom, {
          'guest_name': request.guestName,
          'guest_email': request.guestEmail ?? '',
          'guest_phone': request.guestPhone ?? '',
          'room_id': request.roomId,
          'check_in': formattedCheckIn,
          'check_out': formattedCheckOut,
        });

        // Handle response
        if (response['success'] == true) {
          successMessage.value =
              'Room booked successfully!'; // <-- Set success message properly
          _showSnackbar('Success', successMessage.value, Colors.green);
        } else {
          final errorMsg = response['message'] ?? 'Booking failed';
          _showSnackbar('Error', errorMsg, Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Error', 'Network error: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Snackbar utility
  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(title, message,
        backgroundColor: color, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> getBookings() async {
    isBookingLoading.value = true;
    bookingError.value = false;

    try {
      if (isServerMode) {
        final response = await apiService.get(Config.bookedRooms); // API URL

        if (response['success'] == true) {
          List<dynamic> data = response['data'];
          List<Reservation> bookingList =
              data.map((booking) => Reservation.fromApi(booking)).toList();

          bookings.assignAll(bookingList);
          print("✅ Bookings successfully loaded from server.");
        } else {
          print("⚠️ Error fetching bookings: ${response['message']}");
          bookingError.value = true;
        }
      } else {
        print("✅ Bookings successfully loaded from local database.");
      }
    } catch (e) {
      print("❌ Error loading bookings: $e");
      bookingError.value = true;
    } finally {
      isBookingLoading.value = false;
    }
  }

  var recentBookings = <Reservation>[].obs;
  var pastBookings = <Reservation>[].obs;

  void filterBookings() {
    final now = DateTime.now();

    recentBookings.assignAll(
      bookings.where((b) => b.checkOutDate.isAfter(now)).toList(),
    );

    pastBookings.assignAll(
      bookings.where((b) => b.checkOutDate.isBefore(now)).toList(),
    );
  }

  // Future<void> bookRoom({
  //   required String guestName,
  //   required String guestEmail,
  //   required String guestPhone,
  //   required int roomId,
  //   required DateTime checkIn,
  //   required DateTime checkOut,
  // }) async {
  //   try {
  //     if (isServerMode) {
  //       final response = await apiService.post(Config.bookRoom, {
  //         "guest_name": guestName,
  //         "guest_email": guestEmail,
  //         "guest_phone": guestPhone,
  //         "room_id": roomId,
  //         "check_in": checkIn.toIso8601String(),
  //         "check_out": checkOut.toIso8601String(),
  //       });

  //       if (response['success'] == true) {
  //         print('Room booked successfully on server');
  //       } else {
  //         print("Error booking room on server: ${response['message']}");
  //       }
  //     } else {
  //       final booking = BookingsCompanion.insert(
  //         guestName: guestName,
  //         guestEmail: Value(guestEmail),
  //         guestPhone: Value(guestPhone),
  //         roomId: roomId,
  //         checkIn: checkIn,
  //         checkOut: checkOut,
  //       );

  //       await database.into(database.bookings).insert(booking);
  //       print('Room booked successfully in local database');
  //     }
  //   } catch (e) {
  //     print("Error booking room: $e");
  //   }
  // }
}
