import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_paths.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    AppSettings,
    Groups,
    GroupMembers,
    Expenses,
    ExpensePayers,
    ExpenseSplits,
    Settlements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  static const int databaseSchemaVersion = 3;

  @override
  int get schemaVersion => databaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(appSettings, appSettings.themeMode);
      }
      if (from < 3) {
        await m.createTable(expensePayers);
        // Backfill one payer row per existing expense from paid_by_id.
        await customStatement('''
INSERT INTO expense_payers (id, expense_id, user_id, amount_cents)
SELECT id || '-payer', id, paid_by_id, amount_cents
FROM expenses
''');
        // Recreate expenses without paid_by_id (copies columns present in
        // the new Dart schema only).
        await m.alterTable(TableMigration(expenses));
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'scene_split',
      native: DriftNativeOptions(databasePath: resolveDatabasePath),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
