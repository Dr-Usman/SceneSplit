import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';

void main() {
  test(
    'migration from v5 to v6 adds settlements.date and backfills from created_at without error',
    () async {
      // 1. Create a raw SQLite in-memory database simulating version 5
      final executor = NativeDatabase.memory();
      final db = AppDatabase.forTesting(executor);

      // Drop current settlements table to simulate an existing v5 database
      await db.customStatement('DROP TABLE settlements;');
      await db.customStatement('''
      CREATE TABLE settlements (
        id TEXT NOT NULL PRIMARY KEY,
        group_id TEXT NOT NULL REFERENCES groups (id),
        from_user_id TEXT NOT NULL REFERENCES users (id),
        to_user_id TEXT NOT NULL REFERENCES users (id),
        amount_cents INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))
      );
    ''');

      // Insert dummy data into v5 settlements
      final pastTimestamp =
          DateTime(2026, 1, 15, 10, 30).millisecondsSinceEpoch ~/ 1000;
      await db.customStatement('''
      INSERT INTO users (id, name, is_current_user) VALUES ('u1', 'Alice', 1);
      INSERT INTO users (id, name, is_current_user) VALUES ('u2', 'Bob', 0);
      INSERT INTO groups (id, name, currency_code) VALUES ('g1', 'Trip', 'USD');
      INSERT INTO settlements (id, group_id, from_user_id, to_user_id, amount_cents, note, created_at)
      VALUES ('s1', 'g1', 'u1', 'u2', 5000, 'Test v5', $pastTimestamp);
    ''');

      // Verify v5 has no date column initially
      final initialColumns = await db
          .customSelect('PRAGMA table_info(settlements)')
          .get();
      expect(
        initialColumns.any((c) => c.read<String>('name') == 'date'),
        isFalse,
      );

      // 2. Run the migration to version 6 using the actual AppDatabase migration logic
      final m = db.createMigrator();
      await db.migration.onUpgrade(m, 5, 6);

      // 3. Verify date column exists and was backfilled with created_at timestamp
      final migratedColumns = await db
          .customSelect('PRAGMA table_info(settlements)')
          .get();
      expect(
        migratedColumns.any((c) => c.read<String>('name') == 'date'),
        isTrue,
      );

      final rows = await db
          .customSelect(
            'SELECT date, created_at FROM settlements WHERE id = ?',
            variables: [Variable('s1')],
          )
          .get();

      expect(rows.length, 1);
      expect(rows.first.read<int>('date'), pastTimestamp);
      expect(rows.first.read<int>('created_at'), pastTimestamp);

      // 4. Verify running migration again idempotently does not throw duplicate column error
      await db.migration.onUpgrade(m, 5, 6);

      await db.close();
    },
  );
}
