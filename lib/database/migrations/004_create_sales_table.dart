import 'package:drift/drift.dart';

@DataClassName('Sale')
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()(); // Unique Sale ID
  TextColumn get posCode => text()(); // Unique POS Code
  RealColumn get total => real()(); // Total transaction amount
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('pos'))(); // Payment method
  RealColumn get amountPaid =>
      real().withDefault(const Constant(0.00))(); // Amount paid by customer
  RealColumn get change =>
      real().withDefault(const Constant(0.00))(); // Change given back
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SaleItem')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId =>
      integer().references(Sales, #id)(); // Foreign Key to Sales
  IntColumn get productId => integer()(); // Reference to Product
  TextColumn get productName => text()(); // Store product name for reference
  RealColumn get price => real()(); // Product price
  IntColumn get quantity => integer()(); // Quantity sold
}
