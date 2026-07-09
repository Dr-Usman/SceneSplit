import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

class DatabaseNotifier extends Notifier<AppDatabase> {
  @override
  AppDatabase build() {
    final db = AppDatabase();
    ref.onDispose(() => db.close());
    return db;
  }

  /// Closes the current database and opens a fresh connection (e.g. after import).
  Future<void> reopen() async {
    try {
      await state.close();
    } on Object {
      // Connection may already be closed before a restore.
    }
    state = AppDatabase();
  }
}

final databaseProvider = NotifierProvider<DatabaseNotifier, AppDatabase>(
  DatabaseNotifier.new,
);

/// The user of this device (marked isCurrentUser). Null until onboarding done.
final currentUserProvider = StreamProvider<User?>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.users)
    ..where((u) => u.isCurrentUser.equals(true))
    ..limit(1);
  return query.watchSingleOrNull();
});

/// App-wide default currency code.
final currencyCodeProvider = StreamProvider<String>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.appSettings)..limit(1);
  return query.watchSingleOrNull().map((row) => row?.currencyCode ?? 'PKR');
});

/// Completes onboarding: creates the device user and saves currency.
Future<void> completeOnboarding(
  AppDatabase db, {
  required String name,
  required String currencyCode,
}) async {
  await db.transaction(() async {
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: const Uuid().v4(),
            name: name,
            isCurrentUser: const Value(true),
          ),
        );
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            id: const Value(1),
            currencyCode: Value(currencyCode),
          ),
          mode: InsertMode.insertOrReplace,
        );
  });
}
