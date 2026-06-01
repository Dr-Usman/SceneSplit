import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.attachedDatabase);

  Stream<List<User>> watchAllUsers() => select(users).watch();

  Future<List<User>> getAllUsers() => select(users).get();

  Future<User?> getUserById(String id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<int> insertUser(UsersCompanion entry) =>
      into(users).insert(entry, mode: InsertMode.insertOrReplace);

  Future<bool> updateUser(UsersCompanion entry) => update(users).replace(entry);

  Future<int> deleteUser(String id) =>
      (delete(users)..where((u) => u.id.equals(id))).go();

  Future<List<User>> getUsersByIds(List<String> ids) =>
      (select(users)..where((u) => u.id.isIn(ids))).get();
}
