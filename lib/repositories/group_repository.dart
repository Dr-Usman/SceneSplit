import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import 'user_repository.dart';

const _uuid = Uuid();

class MemberRemovalBlockedException implements Exception {
  MemberRemovalBlockedException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Creates a group with the given members. [existingUserIds] are users
/// already in the database (always includes the current user);
/// [newMemberNames] are typed names that become new reusable users.
Future<String> createGroup(
  AppDatabase db, {
  required String name,
  required String emoji,
  required String currencyCode,
  required List<String> existingUserIds,
  required List<String> newMemberNames,
}) async {
  final groupId = _uuid.v4();

  await db.transaction(() async {
    await db
        .into(db.groups)
        .insert(
          GroupsCompanion.insert(
            id: groupId,
            name: name,
            emoji: Value(emoji),
            currencyCode: Value(currencyCode),
          ),
        );

    final memberIds = [...existingUserIds];

    for (final memberName in newMemberNames) {
      final userId = await createUser(db, memberName);
      memberIds.add(userId);
    }

    for (final userId in memberIds) {
      await db
          .into(db.groupMembers)
          .insert(
            GroupMembersCompanion.insert(
              id: _uuid.v4(),
              groupId: groupId,
              userId: userId,
            ),
          );
    }
  });

  return groupId;
}

Future<void> updateGroup(
  AppDatabase db, {
  required String groupId,
  required String name,
  required String emoji,
  String? currencyCode,
}) async {
  await (db.update(db.groups)..where((g) => g.id.equals(groupId))).write(
    GroupsCompanion(
      name: Value(name),
      emoji: Value(emoji),
      currencyCode: currencyCode == null
          ? const Value.absent()
          : Value(currencyCode),
    ),
  );
}

/// Syncs group members: keeps [memberUserIds], adds [newMemberNames] as users.
Future<void> syncGroupMembers(
  AppDatabase db, {
  required String groupId,
  required List<String> memberUserIds,
  required List<String> newMemberNames,
}) async {
  await db.transaction(() async {
    final allIds = [...memberUserIds];

    for (final memberName in newMemberNames) {
      final userId = await createUser(db, memberName);
      allIds.add(userId);
    }

    final existing = await (db.select(
      db.groupMembers,
    )..where((m) => m.groupId.equals(groupId))).get();
    final existingUserIds = existing.map((m) => m.userId).toSet();

    for (final userId in allIds) {
      if (!existingUserIds.contains(userId)) {
        await db
            .into(db.groupMembers)
            .insert(
              GroupMembersCompanion.insert(
                id: _uuid.v4(),
                groupId: groupId,
                userId: userId,
              ),
            );
      }
    }

    for (final member in existing) {
      if (!allIds.contains(member.userId)) {
        if (!await canRemoveMemberFromGroup(db, member.userId, groupId)) {
          final user = await (db.select(
            db.users,
          )..where((u) => u.id.equals(member.userId))).getSingleOrNull();
          final name = user?.name ?? 'This member';
          throw MemberRemovalBlockedException(
            '$name has expenses or settlements in this group and cannot be removed.',
          );
        }
        await (db.delete(
          db.groupMembers,
        )..where((m) => m.id.equals(member.id))).go();
      }
    }
  });
}

Future<void> deleteGroup(AppDatabase db, String groupId) async {
  await db.transaction(() async {
    final expenses = await (db.select(
      db.expenses,
    )..where((e) => e.groupId.equals(groupId))).get();
    for (final e in expenses) {
      await (db.delete(
        db.expensePayers,
      )..where((p) => p.expenseId.equals(e.id))).go();
      await (db.delete(
        db.expenseSplits,
      )..where((s) => s.expenseId.equals(e.id))).go();
    }
    await (db.delete(
      db.expenses,
    )..where((e) => e.groupId.equals(groupId))).go();
    await (db.delete(
      db.settlements,
    )..where((s) => s.groupId.equals(groupId))).go();
    await (db.delete(
      db.groupMembers,
    )..where((m) => m.groupId.equals(groupId))).go();
    await (db.delete(db.groups)..where((g) => g.id.equals(groupId))).go();
  });
}
