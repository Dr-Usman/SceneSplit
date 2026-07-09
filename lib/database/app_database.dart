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
    ExpenseSplits,
    Settlements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  static const int databaseSchemaVersion = 1;

  @override
  int get schemaVersion => databaseSchemaVersion;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) async => m.createAll());

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'scene_split',
      native: DriftNativeOptions(databasePath: resolveDatabasePath),
    );
  }
}
