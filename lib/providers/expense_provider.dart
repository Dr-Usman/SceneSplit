import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/split_type.dart';
import '../models/expense_model.dart';
import '../models/expense_split_model.dart';
import 'database_provider.dart';

part 'expense_provider.g.dart';

@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  Stream<List<ExpenseModel>> build() {
    return ref.watch(expenseRepositoryProvider).watchAllExpenses();
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required String paidBy,
    String? groupId,
    required SplitType splitType,
    required List<ExpenseSplitModel> splits,
  }) async {
    await ref
        .read(expenseRepositoryProvider)
        .createExpense(
          description: description,
          amount: amount,
          paidBy: paidBy,
          groupId: groupId,
          splitType: splitType,
          splits: splits,
        );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await ref.read(expenseRepositoryProvider).updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
  }
}

@riverpod
class GroupExpenses extends _$GroupExpenses {
  @override
  Stream<List<ExpenseModel>> build(String groupId) {
    return ref.watch(expenseRepositoryProvider).watchExpensesByGroup(groupId);
  }
}
