import 'package:drift/drift.dart';
import 'package:enapel/database/database.dart';
import 'package:faker/faker.dart';

class DatabaseSeeder {
  final EnapelDatabase db;

  DatabaseSeeder(this.db);

  Future<void> seedUsers() async {
    // final faker = Faker();

    // // Seed a single user
    // await db.into(db.users).insert(UsersCompanion(
    //       name: Value(faker.person.name()),
    //       email: Value(faker.internet.email()),
    //       password: Value(faker.guid.guid()),
    //     ));

    print('User seeding complete');
  }

  Future<void> seedInventory() async {
    final faker = Faker();

    for (int i = 0; i < 20; i++) {
      // Generate a price with a minimum of 100.00
      final double price =
          (faker.randomGenerator.integer(900, min: 100)).toDouble();

      await db.into(db.inventory).insert(
            InventoryCompanion(
                name: Value(faker.food.dish()),
                quantity: Value(faker.randomGenerator.integer(100, min: 1)),
                price: Value(price)),
          );
    }

    print('Inventory seeding complete');
  }

  Future<void> seedDatabase() async {
    await seedUsers();
    await seedInventory();
  }
}
