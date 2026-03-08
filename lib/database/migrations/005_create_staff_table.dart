import 'package:drift/drift.dart';

class Staff extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get staffid => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get designation => text()();
  TextColumn get role => text()();
  TextColumn get dob => text()();
  RealColumn get salary => real()();
}
