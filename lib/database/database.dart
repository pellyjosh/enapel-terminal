import 'package:drift/drift.dart';
import 'package:enapel/database/migrations/001_create_user_table.dart';
import 'package:enapel/database/migrations/002_create_inventory_table.dart';
import 'package:enapel/database/migrations/004_create_sales_table.dart';
import 'package:enapel/database/migrations/005_create_staff_table.dart';
import 'package:enapel/database/migrations/migration_runner.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users, Inventory, Sales, SaleItems, Staff])
class EnapelDatabase extends _$EnapelDatabase {
  EnapelDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          print("Running migrations...");
          final runner = MigrationRunner(this);
          await runner.runMigrations(m);
        },
        onUpgrade: (migrator, from, to) async {
          // if (from < 2) {
          //   await migrator.addColumn(
          //       inventory, inventory.price as GeneratedColumn<Object>);
          // }
        },
      );
}
