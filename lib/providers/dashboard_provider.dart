import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/dashboard_data_model.dart';
import 'database_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardData extends _$DashboardData {
  @override
  Future<DashboardDataModel> build() async {
    final expenseRepo = ref.watch(expenseRepositoryProvider);
    final settlementRepo = ref.watch(settlementRepositoryProvider);
    final balanceService = ref.watch(balanceServiceProvider);
    final settlementService = ref.watch(settlementServiceProvider);

    final expenses = await expenseRepo.getAllExpenses();
    final splits = await expenseRepo.getAllSplits();
    final settlements = await settlementRepo.getAllSettlements();

    final balances = balanceService.calculateNetBalances(
      expenses: expenses,
      allSplits: splits,
      settlements: settlements,
    );

    final suggestions = settlementService.suggestSettlements(
      netBalances: balances,
    );

    return DashboardDataModel(
      balances: balances,
      suggestions: suggestions,
      totalOwed: balances.values
          .where((b) => b > 0)
          .fold(0.0, (sum, b) => sum + b),
      totalOwing: balances.values
          .where((b) => b < 0)
          .fold(0.0, (sum, b) => sum + b.abs()),
    );
  }
}

@riverpod
class GroupDashboard extends _$GroupDashboard {
  @override
  Future<DashboardDataModel> build(String groupId) async {
    final expenseRepo = ref.watch(expenseRepositoryProvider);
    final settlementRepo = ref.watch(settlementRepositoryProvider);
    final balanceService = ref.watch(balanceServiceProvider);
    final settlementService = ref.watch(settlementServiceProvider);

    final expenses = await expenseRepo.getAllExpenses();
    final splits = await expenseRepo.getAllSplits();
    final settlements = await settlementRepo.getAllSettlements();

    final balances = balanceService.calculateNetBalances(
      expenses: expenses,
      allSplits: splits,
      settlements: settlements,
      groupId: groupId,
    );

    final suggestions = settlementService.suggestSettlements(
      netBalances: balances,
      groupId: groupId,
    );

    return DashboardDataModel(
      balances: balances,
      suggestions: suggestions,
      totalOwed: balances.values
          .where((b) => b > 0)
          .fold(0.0, (sum, b) => sum + b),
      totalOwing: balances.values
          .where((b) => b < 0)
          .fold(0.0, (sum, b) => sum + b.abs()),
    );
  }
}
