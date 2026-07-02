import 'package:drift/drift.dart';

import '../database/app_database.dart';

Future<void> updateCurrentUserName(AppDatabase db, String name) async {
  await (db.update(db.users)..where((u) => u.isCurrentUser.equals(true))).write(
    UsersCompanion(name: Value(name)),
  );
}

Future<void> updateCurrency(AppDatabase db, String currencyCode) async {
  await db.into(db.appSettings).insert(
        AppSettingsCompanion.insert(
          id: const Value(1),
          currencyCode: Value(currencyCode),
        ),
        mode: InsertMode.insertOrReplace,
      );
}

Future<void> updateUserName(AppDatabase db, String userId, String name) async {
  await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
    UsersCompanion(name: Value(name)),
  );
}
