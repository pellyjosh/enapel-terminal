class SalesModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final int price;
  final DateTime createdAt;

  SalesModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PatientModel {
  final int? id;
  final String name;
  final String medication;
  final String dosage;
  final String prescriptionStatus;
  final DateTime? firstVisit;
  final DateTime? lastVisit;
  final int ? duration;

  PatientModel({
    this.id,
    required this.name,
    required this.medication,
    required this.dosage,
    required this.prescriptionStatus,
    this.firstVisit,
    this.lastVisit,
    required this.duration,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      name: json['name'] ?? '',
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      prescriptionStatus: json['prescription_status'] ?? '',
      firstVisit: json['first_visit'] != null ? DateTime.tryParse(json['first_visit']) : null,
      lastVisit: json['last_visit'] != null ? DateTime.tryParse(json['last_visit']) : null,
      duration: (json['duration'] as num?)?.toInt() ??
          0, // fallback if API doesn't send
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'medication': medication,
      'dosage': dosage,
      'prescription_status': prescriptionStatus,
      'first_visit': firstVisit?.toIso8601String(),
      'last_visit': lastVisit?.toIso8601String(),
      'duration': duration,
    };
  }
}



// class ExpenseModel {
//   final int id;
//   final String type;
//   final double amount;
//   final String createdAt;

//   ExpenseModel({
//     required this.id,
//     required this.type,
//     required this.amount,
//     required this.createdAt,
//   });

//   factory ExpenseModel.fromJson(Map<String, dynamic> json) {
//     return ExpenseModel(
//       id: json['id'],
//       type: json['type'],
//       amount: (json['amount'] as num).toDouble(),
//       createdAt: json['created_at'],
//     );
//   }
// }
class FinanceSummaryModel {
  final double? revenue;
  final double? expenses;
  final double netProfit;
  final String date;

  FinanceSummaryModel({
    this.revenue,
    this.expenses,
    required this.netProfit,
    required this.date,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryModel(
      revenue: (json['revenue'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      netProfit: (json['netprofit'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}

