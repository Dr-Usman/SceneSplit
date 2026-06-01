import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups, GroupMembers, Users])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(super.attachedDatabase);

  Stream<List<Group>> watchAllGroups() => select(groups).watch();

  Future<List<Group>> getAllGroups() => select(groups).get();

  Future<Group?> getGroupById(String id) =>
      (select(groups)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<int> insertGroup(GroupsCompanion entry) =>
      into(groups).insert(entry, mode: InsertMode.insertOrReplace);

  Future<bool> updateGroup(GroupsCompanion entry) =>
      update(groups).replace(entry);

  Future<int> deleteGroup(String id) =>
      (delete(groups)..where((g) => g.id.equals(id))).go();

  Future<void> addMember(String groupId, String userId) async {
    await into(groupMembers).insert(
      GroupMembersCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        userId: userId,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> removeMember(String groupId, String userId) async {
    await (delete(
          groupMembers,
        )..where((gm) => gm.groupId.equals(groupId) & gm.userId.equals(userId)))
        .go();
  }

  Future<List<String>> getGroupMemberIds(String groupId) async {
    final members = await (select(
      groupMembers,
    )..where((gm) => gm.groupId.equals(groupId))).get();
    return members.map((m) => m.userId).toList();
  }

  Stream<List<String>> watchGroupMemberIds(String groupId) {
    return (select(groupMembers)..where((gm) => gm.groupId.equals(groupId)))
        .watch()
        .map((members) => members.map((m) => m.userId).toList());
  }

  Future<List<User>> getGroupMembers(String groupId) async {
    final memberIds = await getGroupMemberIds(groupId);
    if (memberIds.isEmpty) return [];
    return (select(users)..where((u) => u.id.isIn(memberIds))).get();
  }

  Stream<List<User>> watchGroupMembers(String groupId) {
    return watchGroupMemberIds(groupId).asyncMap((ids) async {
      if (ids.isEmpty) return [];
      return (select(users)..where((u) => u.id.isIn(ids))).get();
    });
  }
}
