import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _uuid = Uuid();

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
    await db.into(db.groups).insert(GroupsCompanion.insert(
          id: groupId,
          name: name,
          emoji: Value(emoji),
          currencyCode: Value(currencyCode),
        ));

    final memberIds = [...existingUserIds];

    for (var i = 0; i < newMemberNames.length; i++) {
      final userId = _uuid.v4();
      await db.into(db.users).insert(UsersCompanion.insert(
            id: userId,
            name: newMemberNames[i],
            colorIndex: Value((existingUserIds.length + i) % 8),
          ));
      memberIds.add(userId);
    }

    for (final userId in memberIds) {
      await db.into(db.groupMembers).insert(GroupMembersCompanion.insert(
            id: _uuid.v4(),
            groupId: groupId,
            userId: userId,
          ));
    }
  });

  return groupId;
}

Future<void> updateGroup(
  AppDatabase db, {
  required String groupId,
  required String name,
  required String emoji,
}) async {
  await (db.update(db.groups)..where((g) => g.id.equals(groupId))).write(
    GroupsCompanion(
      name: Value(name),
      emoji: Value(emoji),
    ),
  );
}

/// Syncs group members: keeps [memberUserIds], adds [newMemberNames] as users.
Future<void> syncGroupMembers(
  AppDatabase db, {
  required String groupId,
  required List<String> memberUserIds,
  required List<String> newMemberNames,
  required int colorOffset,
}) async {
  await db.transaction(() async {
    final allIds = [...memberUserIds];

    for (var i = 0; i < newMemberNames.length; i++) {
      final userId = _uuid.v4();
      await db.into(db.users).insert(UsersCompanion.insert(
            id: userId,
            name: newMemberNames[i],
            colorIndex: Value((colorOffset + i) % 8),
          ));
      allIds.add(userId);
    }

    final existing = await (db.select(db.groupMembers)
          ..where((m) => m.groupId.equals(groupId)))
        .get();
    final existingUserIds = existing.map((m) => m.userId).toSet();

    for (final userId in allIds) {
      if (!existingUserIds.contains(userId)) {
        await db.into(db.groupMembers).insert(GroupMembersCompanion.insert(
              id: _uuid.v4(),
              groupId: groupId,
              userId: userId,
            ));
      }
    }

    for (final member in existing) {
      if (!allIds.contains(member.userId)) {
        await (db.delete(db.groupMembers)
              ..where((m) => m.id.equals(member.id)))
            .go();
      }
    }
  });
}

Future<void> deleteGroup(AppDatabase db, String groupId) async {
  await db.transaction(() async {
    final expenses = await (db.select(db.expenses)
          ..where((e) => e.groupId.equals(groupId)))
        .get();
    for (final e in expenses) {
      await (db.delete(db.expenseSplits)
            ..where((s) => s.expenseId.equals(e.id)))
          .go();
    }
    await (db.delete(db.expenses)..where((e) => e.groupId.equals(groupId)))
        .go();
    await (db.delete(db.settlements)..where((s) => s.groupId.equals(groupId)))
        .go();
    await (db.delete(db.groupMembers)..where((m) => m.groupId.equals(groupId)))
        .go();
    await (db.delete(db.groups)..where((g) => g.id.equals(groupId))).go();
  });
}
