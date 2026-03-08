import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:enapel/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EnapelDatabase db;

  setUp(() async {
    // Use in-memory database for testing
    db = EnapelDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // Test inserting an inventory item
  test('Insert Inventory Item', () async {
    const item = InventoryCompanion(
      name: Value('Product A'),
      quantity: Value(10),
    );

    await db.into(db.inventory).insert(item);

    final items = await db.select(db.inventory).get();
    expect(items.any((i) => i.name == 'Product A'), true);
    expect(items.firstWhere((i) => i.name == 'Product A').quantity, 10);
  });

  // Test inserting a user
  test('Insert User', () async {
    const user = UsersCompanion(
      name: Value('John Doe'),
      email: Value('johndoe@example.com'),
      password: Value('hashed_password'),
    );

    await db.into(db.users).insert(user);

    final users = await db.select(db.users).get();
    expect(users.any((u) => u.email == 'johndoe@example.com'), true);
  });

  // Test updating an inventory item
  test('Update Inventory Item', () async {
    const item = InventoryCompanion(
      name: Value('Product A'),
      quantity: Value(10),
    );
    final id = await db.into(db.inventory).insert(item);

    final updatedItem = InventoryCompanion(
      id: Value(id),
      name: const Value('Updated Product'),
      quantity: const Value(20),
    );

    await db.update(db.inventory).replace(updatedItem);

    final items = await db.select(db.inventory).get();
    final updated = items.firstWhere((i) => i.id == id);
    expect(updated.name, 'Updated Product');
    expect(updated.quantity, 20);
  });

  // Test deleting an inventory item
  test('Delete Inventory Item', () async {
    const item = InventoryCompanion(
      name: Value('Product A'),
      quantity: Value(10),
    );
    final id = await db.into(db.inventory).insert(item);

    await (db.delete(db.inventory)..where((tbl) => tbl.id.equals(id))).go();

    final items = await db.select(db.inventory).get();
    expect(items.any((i) => i.id == id), false);
  });
}
