import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/users_dao.dart';
import '../models/user_model.dart';

class UserRepository {
  final UsersDao _usersDao;
  static const _uuid = Uuid();

  UserRepository(this._usersDao);

  Stream<List<UserModel>> watchAllUsers() {
    return _usersDao.watchAllUsers().map(
      (rows) => rows.map((row) => UserModel.fromRow(row)).toList(),
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final rows = await _usersDao.getAllUsers();
    return rows.map((row) => UserModel.fromRow(row)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final row = await _usersDao.getUserById(id);
    return row != null ? UserModel.fromRow(row) : null;
  }

  Future<UserModel> createUser({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final user = UsersCompanion.insert(
      id: id,
      name: name,
      email: Value(email),
      avatarUrl: Value(avatarUrl),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _usersDao.insertUser(user);
    final createdUser = await _usersDao.getUserById(id);
    return UserModel.fromRow(createdUser!);
  }

  Future<void> updateUser(UserModel user) async {
    final companion = UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      avatarUrl: Value(user.avatarUrl),
      isSynced: Value(user.isSynced),
      createdAt: Value(user.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _usersDao.updateUser(companion);
  }

  Future<void> deleteUser(String id) async {
    await _usersDao.deleteUser(id);
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    final rows = await _usersDao.getUsersByIds(ids);
    return rows.map((row) => UserModel.fromRow(row)).toList();
  }
}
