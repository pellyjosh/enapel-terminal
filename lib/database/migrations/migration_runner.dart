import 'package:drift/drift.dart';
import 'package:enapel/database/database.dart';
import 'package:enapel/database/migrations/database_seeders.dart';

class MigrationRunner {
  final EnapelDatabase db;

  MigrationRunner(this.db);

  Future<void> runMigrations(Migrator m) async {
    // This automatically creates all tables defined in `@DriftDatabase`
    await m.createAll();

    final seeder = DatabaseSeeder(db);

    // print("Migrations complete. Seeding database...");
    await seeder.seedDatabase();
  }
}
