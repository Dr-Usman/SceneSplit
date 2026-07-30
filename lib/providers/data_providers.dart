import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final usersStreamProvider = StreamProvider<List<User>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.users).watch();
});

final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.groups)
    ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]);
  return query.watch();
});

final groupMembersStreamProvider = StreamProvider<List<GroupMember>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.groupMembers).watch();
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.expenses).watch();
});

final payersStreamProvider = StreamProvider<List<ExpensePayer>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.expensePayers).watch();
});

final splitsStreamProvider = StreamProvider<List<ExpenseSplit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.expenseSplits).watch();
});

final settlementsStreamProvider = StreamProvider<List<Settlement>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.settlements).watch();
});

/// Map of userId -> User for quick display lookups.
final userByIdProvider = Provider<Map<String, User>>((ref) {
  final users = ref.watch(usersStreamProvider).value ?? [];
  return {for (final u in users) u.id: u};
});
