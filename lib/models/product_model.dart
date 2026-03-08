class Product {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String status;
  final String? barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.status,
    this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()), // Convert string to double
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      barcode: json['barcode'],
    );
  }
}

class Receipt {
  final String receiptNumber;
  final double total;
  final String paymentMethod;
  final double cashPaid;
  final double changeDue;
  final DateTime date;
  final List<SaleItems> items;

  Receipt({
    required this.receiptNumber,
    required this.total,
    required this.paymentMethod,
    required this.cashPaid,
    required this.changeDue,
    required this.date,
    required this.items,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receiptNumber: json['receipt_number'] ?? 'N/A',
      total: (json['total_price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'pending',
      cashPaid: (json['cash_paid'] ?? 0).toDouble(),
      changeDue: (json['change_due'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      items: (json['items'] ?? []).map<SaleItems>((item) {
        return SaleItems.fromJson(item);
      }).toList(),
    );
  }
}

class SaleItems {
  final String name;
  final int quantity;
  final double price;

  SaleItems({
    required this.name,
    required this.quantity,
    required this.price,
  });

factory SaleItems.fromJson(Map<String, dynamic> json) {
    return SaleItems(
      name: json['product_name'] ?? 'Unnamed',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
