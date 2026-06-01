import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/daos.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAO Providers
final usersDaoProvider = Provider<UsersDao>((ref) {
  return UsersDao(ref.watch(databaseProvider));
});

final groupsDaoProvider = Provider<GroupsDao>((ref) {
  return GroupsDao(ref.watch(databaseProvider));
});

final expensesDaoProvider = Provider<ExpensesDao>((ref) {
  return ExpensesDao(ref.watch(databaseProvider));
});

final settlementsDaoProvider = Provider<SettlementsDao>((ref) {
  return SettlementsDao(ref.watch(databaseProvider));
});

// Repository Providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(usersDaoProvider));
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(groupsDaoProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(expensesDaoProvider));
});

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  return SettlementRepository(ref.watch(settlementsDaoProvider));
});

// Service Providers
final splitEngineServiceProvider = Provider<SplitEngineService>((ref) {
  return SplitEngineService();
});

final balanceServiceProvider = Provider<BalanceService>((ref) {
  return BalanceService();
});

final settlementServiceProvider = Provider<SettlementService>((ref) {
  return SettlementService();
});
