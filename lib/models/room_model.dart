import 'package:intl/intl.dart';

class RoomModel {
  final int? id;
  final String name;
  final String category;
  final double price;
  final String status;

  RoomModel({
     this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
  });

 Map<String, dynamic> toJson({bool includeCategory = true}) {
    final data = {
      "id": id,
      "name": name,
      "price": price,
      "status": status,
    };
    if (includeCategory) data["category"] = category;
    return data;
  }


  RoomModel copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    String? status,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }

factory RoomModel.fromApi(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      category: json['category'] is Map
          ? json['category']['name'] ?? ''
          : (json['category'] ?? ''),
      price: (json['price'] as num).toDouble(),
      status: json['status'],
    );
  }

  factory RoomModel.fromDrift(dynamic data) {
    return RoomModel(
      id: data.id,
      name: data.name,
      category: data.category,
      price: data.price,
      status: data.status,
    );
  }
}
class CheckinRequest {
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int roomId;
  final DateTime checkIn;
  final DateTime checkOut;

  CheckinRequest({
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
  });
    bool isValid() {
    return guestName.isNotEmpty && roomId != 0 && checkIn.isBefore(checkOut);
  }
  Map<String, dynamic> toJson() {
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return {
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'room_id': roomId,
      'check_in': formatter.format(checkIn),
      'check_out': formatter.format(checkOut),
    };
  }
}
class Reservation {
  final int id;
  final String roomName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String guestName;
   final String? guestPhone;

  Reservation({
    required this.id,
    required this.roomName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestName,
     this.guestPhone,
  });
    factory Reservation.fromApi(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      guestName: json['guest']['name'] ?? '',
      guestPhone: json['guest']['phone'] ?? '',
      roomName: json['room']['name'] ?? '',
      checkInDate: DateTime.parse(json['check_in']),
      checkOutDate: DateTime.parse(json['check_out']),
    );
  }
}
