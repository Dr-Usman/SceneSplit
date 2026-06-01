import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/group_type.dart';
import '../models/group_model.dart';
import 'database_provider.dart';

part 'group_provider.g.dart';

@riverpod
class GroupList extends _$GroupList {
  @override
  Stream<List<GroupModel>> build() {
    return ref.watch(groupRepositoryProvider).watchAllGroups();
  }

  Future<void> addGroup({
    required String name,
    String? description,
    GroupType type = GroupType.custom,
    List<String> memberIds = const [],
  }) async {
    await ref
        .read(groupRepositoryProvider)
        .createGroup(
          name: name,
          description: description,
          type: type,
          memberIds: memberIds,
        );
  }

  Future<void> updateGroup(GroupModel group) async {
    await ref.read(groupRepositoryProvider).updateGroup(group);
  }

  Future<void> deleteGroup(String id) async {
    await ref.read(groupRepositoryProvider).deleteGroup(id);
  }

  Future<void> addMember(String groupId, String userId) async {
    await ref.read(groupRepositoryProvider).addMember(groupId, userId);
  }

  Future<void> removeMember(String groupId, String userId) async {
    await ref.read(groupRepositoryProvider).removeMember(groupId, userId);
  }
}

@riverpod
class GroupDetail extends _$GroupDetail {
  @override
  Future<GroupModel?> build(String groupId) async {
    return ref.watch(groupRepositoryProvider).getGroupById(groupId);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () async => await ref.read(groupRepositoryProvider).getGroupById(groupId),
    );
  }
}
