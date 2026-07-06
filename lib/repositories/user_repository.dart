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

Future<String> createUser(AppDatabase db, String name) async {
  final existing = await db.select(db.users).get();
  final userId = _uuid.v4();
  await db.into(db.users).insert(UsersCompanion.insert(
        id: userId,
        name: name,
        colorIndex: Value(existing.length % 8),
      ));
  return userId;
}

Future<bool> userHasFinancialActivity(
  AppDatabase db,
  String userId, {
  String? groupId,
}) async {
  if (groupId != null) {
    final paidInGroup = await (db.select(db.expenses)
          ..where(
            (e) => e.groupId.equals(groupId) & e.paidById.equals(userId),
          ))
        .getSingleOrNull();
    if (paidInGroup != null) return true;

    final groupExpenses = await (db.select(db.expenses)
          ..where((e) => e.groupId.equals(groupId)))
        .get();
    final expenseIds = groupExpenses.map((e) => e.id).toList();
    if (expenseIds.isNotEmpty) {
      final splitInGroup = await (db.select(db.expenseSplits)
            ..where(
              (s) =>
                  s.userId.equals(userId) & s.expenseId.isIn(expenseIds),
            ))
          .getSingleOrNull();
      if (splitInGroup != null) return true;
    }

    final settlementInGroup = await (db.select(db.settlements)
          ..where(
            (s) =>
                s.groupId.equals(groupId) &
                (s.fromUserId.equals(userId) | s.toUserId.equals(userId)),
          ))
        .getSingleOrNull();
    if (settlementInGroup != null) return true;

    return false;
  }

  final paid = await (db.select(db.expenses)
        ..where((e) => e.paidById.equals(userId)))
      .getSingleOrNull();
  if (paid != null) return true;

  final split = await (db.select(db.expenseSplits)
        ..where((s) => s.userId.equals(userId)))
      .getSingleOrNull();
  if (split != null) return true;

  final settlement = await (db.select(db.settlements)
        ..where(
          (s) => s.fromUserId.equals(userId) | s.toUserId.equals(userId),
        ))
      .getSingleOrNull();
  return settlement != null;
}

Future<bool> canRemoveMemberFromGroup(
  AppDatabase db,
  String userId,
  String groupId,
) async =>
    !(await userHasFinancialActivity(db, userId, groupId: groupId));

Future<void> deleteUser(AppDatabase db, String userId) async {
  final user = await (db.select(db.users)..where((u) => u.id.equals(userId)))
      .getSingleOrNull();
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
    await (db.delete(db.groupMembers)..where((m) => m.userId.equals(userId)))
        .go();
    await (db.delete(db.users)..where((u) => u.id.equals(userId))).go();
  });
}
