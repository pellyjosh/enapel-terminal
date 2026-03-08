import 'package:drift/drift.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  BoolColumn get isAdmin =>
      boolean().withDefault(Constant(false))(); // Default is false
  DateTimeColumn get createdAt => dateTime().withDefault(
      currentDateAndTime)(); // Use currentDateAndTime for auto-updated timestamps
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
