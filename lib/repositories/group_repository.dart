import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/enums/group_type.dart';
import '../database/app_database.dart';
import '../database/daos/groups_dao.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupRepository {
  final GroupsDao _groupsDao;
  static const _uuid = Uuid();

  GroupRepository(this._groupsDao);

  Stream<List<GroupModel>> watchAllGroups() {
    return _groupsDao.watchAllGroups().map(
      (rows) => rows.map((row) => GroupModel.fromRow(row)).toList(),
    );
  }

  Future<List<GroupModel>> getAllGroups() async {
    final rows = await _groupsDao.getAllGroups();
    return rows.map((row) => GroupModel.fromRow(row)).toList();
  }

  Future<GroupModel?> getGroupById(String id) async {
    final row = await _groupsDao.getGroupById(id);
    if (row == null) return null;
    final members = await _groupsDao.getGroupMembers(id);
    return GroupModel.fromRow(
      row,
      members: members.map((m) => UserModel.fromRow(m)).toList(),
    );
  }

  Future<GroupModel> createGroup({
    required String name,
    String? description,
    GroupType type = GroupType.custom,
    String? avatarUrl,
    List<String> memberIds = const [],
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final group = GroupsCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      type: Value(type.name),
      avatarUrl: Value(avatarUrl),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _groupsDao.insertGroup(group);

    // Add members
    for (final memberId in memberIds) {
      await _groupsDao.addMember(id, memberId);
    }

    final createdGroup = await _groupsDao.getGroupById(id);
    final members = await _groupsDao.getGroupMembers(id);
    return GroupModel.fromRow(
      createdGroup!,
      members: members.map((m) => UserModel.fromRow(m)).toList(),
    );
  }

  Future<void> updateGroup(GroupModel group) async {
    final companion = GroupsCompanion(
      id: Value(group.id),
      name: Value(group.name),
      description: Value(group.description),
      type: Value(group.type.name),
      avatarUrl: Value(group.avatarUrl),
      isSynced: Value(group.isSynced),
      createdAt: Value(group.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _groupsDao.updateGroup(companion);
  }

  Future<void> deleteGroup(String id) async {
    await _groupsDao.deleteGroup(id);
  }

  Future<void> addMember(String groupId, String userId) async {
    await _groupsDao.addMember(groupId, userId);
  }

  Future<void> removeMember(String groupId, String userId) async {
    await _groupsDao.removeMember(groupId, userId);
  }

  Future<List<String>> getGroupMemberIds(String groupId) async {
    return await _groupsDao.getGroupMemberIds(groupId);
  }

  Stream<List<String>> watchGroupMemberIds(String groupId) {
    return _groupsDao.watchGroupMemberIds(groupId);
  }
}
