import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _uuid = Uuid();

class UserDeleteBlockedException implements Exception {
  UserDeleteBlockedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserNameTakenException implements Exception {
  UserNameTakenException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Case-insensitive name match among existing users.
/// Pass [excludeUserId] when renaming so the current user is ignored.
Future<bool> userNameExists(
  AppDatabase db,
  String name, {
  String? excludeUserId,
}) async {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  final users = await db.select(db.users).get();
  return users.any(
    (u) => u.id != excludeUserId && u.name.trim().toLowerCase() == normalized,
  );
}

Future<void> updateCurrentUserName(AppDatabase db, String name) async {
  final trimmed = name.trim();
  final me = await (db.select(
    db.users,
  )..where((u) => u.isCurrentUser.equals(true))).getSingleOrNull();
  if (me != null && await userNameExists(db, trimmed, excludeUserId: me.id)) {
    throw UserNameTakenException('Someone named "$trimmed" already exists.');
  }
  await (db.update(db.users)..where((u) => u.isCurrentUser.equals(true))).write(
    UsersCompanion(name: Value(trimmed)),
  );
}

Future<void> updateCurrency(AppDatabase db, String currencyCode) async {
  await _upsertAppSettings(
    db,
    AppSettingsCompanion(currencyCode: Value(currencyCode)),
  );
}

Future<void> updateThemeMode(AppDatabase db, String themeMode) async {
  await _upsertAppSettings(
    db,
    AppSettingsCompanion(themeMode: Value(themeMode)),
  );
}

/// Updates the single settings row, or inserts it when missing.
Future<void> _upsertAppSettings(
  AppDatabase db,
  AppSettingsCompanion companion,
) async {
  final existing =
      await (db.select(db.appSettings)
            ..where((s) => s.id.equals(1))
            ..limit(1))
          .getSingleOrNull();
  if (existing == null) {
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            id: const Value(1),
            currencyCode: companion.currencyCode,
            themeMode: companion.themeMode,
          ),
        );
    return;
  }
  await (db.update(
    db.appSettings,
  )..where((s) => s.id.equals(1))).write(companion);
}

Future<void> updateUserName(AppDatabase db, String userId, String name) async {
  final trimmed = name.trim();
  if (await userNameExists(db, trimmed, excludeUserId: userId)) {
    throw UserNameTakenException('Someone named "$trimmed" already exists.');
  }
  await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
    UsersCompanion(name: Value(trimmed)),
  );
}

Future<String> createUser(AppDatabase db, String name) async {
  final trimmed = name.trim();
  if (await userNameExists(db, trimmed)) {
    throw UserNameTakenException('Someone named "$trimmed" already exists.');
  }
  final existing = await db.select(db.users).get();
  final userId = _uuid.v4();
  await db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          id: userId,
          name: trimmed,
          colorIndex: Value(existing.length % 8),
        ),
      );
  return userId;
}

Future<bool> userHasFinancialActivity(
  AppDatabase db,
  String userId, {
  String? groupId,
}) async {
  if (groupId != null) {
    final groupExpenses = await (db.select(
      db.expenses,
    )..where((e) => e.groupId.equals(groupId))).get();
    final expenseIds = groupExpenses.map((e) => e.id).toList();
    if (expenseIds.isNotEmpty) {
      final paidInGroup =
          await (db.select(db.expensePayers)..where(
                (p) => p.userId.equals(userId) & p.expenseId.isIn(expenseIds),
              ))
              .getSingleOrNull();
      if (paidInGroup != null) return true;

      final splitInGroup =
          await (db.select(db.expenseSplits)..where(
                (s) => s.userId.equals(userId) & s.expenseId.isIn(expenseIds),
              ))
              .getSingleOrNull();
      if (splitInGroup != null) return true;
    }

    final settlementInGroup =
        await (db.select(db.settlements)..where(
              (s) =>
                  s.groupId.equals(groupId) &
                  (s.fromUserId.equals(userId) | s.toUserId.equals(userId)),
            ))
            .getSingleOrNull();
    if (settlementInGroup != null) return true;

    return false;
  }

  final paid = await (db.select(
    db.expensePayers,
  )..where((p) => p.userId.equals(userId))).getSingleOrNull();
  if (paid != null) return true;

  final split = await (db.select(
    db.expenseSplits,
  )..where((s) => s.userId.equals(userId))).getSingleOrNull();
  if (split != null) return true;

  final settlement =
      await (db.select(db.settlements)..where(
            (s) => s.fromUserId.equals(userId) | s.toUserId.equals(userId),
          ))
          .getSingleOrNull();
  return settlement != null;
}

Future<bool> canRemoveMemberFromGroup(
  AppDatabase db,
  String userId,
  String groupId,
) async => !(await userHasFinancialActivity(db, userId, groupId: groupId));

Future<void> deleteUser(AppDatabase db, String userId) async {
  final user = await (db.select(
    db.users,
  )..where((u) => u.id.equals(userId))).getSingleOrNull();
  if (user == null) return;

  if (user.isCurrentUser) {
    throw UserDeleteBlockedException('You cannot delete yourself.');
  }

  if (await userHasFinancialActivity(db, userId)) {
    throw UserDeleteBlockedException(
      'This person has expenses or settlements and cannot be deleted.',
    );
  }

  await db.transaction(() async {
    await (db.delete(
      db.groupMembers,
    )..where((m) => m.userId.equals(userId))).go();
    await (db.delete(db.users)..where((u) => u.id.equals(userId))).go();
  });
}
