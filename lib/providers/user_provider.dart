import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import 'database_provider.dart';

part 'user_provider.g.dart';

@riverpod
class UserList extends _$UserList {
  @override
  Stream<List<UserModel>> build() {
    return ref.watch(userRepositoryProvider).watchAllUsers();
  }

  Future<void> addUser({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    await ref
        .read(userRepositoryProvider)
        .createUser(name: name, email: email, avatarUrl: avatarUrl);
  }

  Future<void> updateUser(UserModel user) async {
    await ref.read(userRepositoryProvider).updateUser(user);
  }

  Future<void> deleteUser(String id) async {
    await ref.read(userRepositoryProvider).deleteUser(id);
  }
}
