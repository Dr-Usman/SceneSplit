import '../models/expense_model.dart';
import '../models/expense_split_model.dart';
import '../models/settlement_model.dart';
import '../models/balance_model.dart';

class BalanceService {
  /// Calculate net balances from expenses and settlements
  Map<String, double> calculateNetBalances({
    required List<ExpenseModel> expenses,
    required List<ExpenseSplitModel> allSplits,
    required List<SettlementModel> settlements,
    String? groupId,
  }) {
    final balances = <String, double>{};

    // Add amounts paid by each user
    for (final expense in expenses) {
      if (groupId != null && expense.groupId != groupId) continue;
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;
    }

    // Subtract amounts owed by each user (their splits)
    for (final split in allSplits) {
      // Find the expense for this split
      final expense = expenses.firstWhere(
        (e) => e.id == split.expenseId,
        orElse: () => throw Exception('Expense not found for split'),
      );
      if (groupId != null && expense.groupId != groupId) continue;
      balances[split.userId] = (balances[split.userId] ?? 0) - split.amount;
    }

    // Apply settlements
    for (final settlement in settlements) {
      if (groupId != null && settlement.groupId != groupId) continue;
      // Settlement: fromUser paid toUser
      // fromUser's balance increases (they paid)
      // toUser's balance decreases (they received)
      balances[settlement.fromUser] =
          (balances[settlement.fromUser] ?? 0) + settlement.amount;
      balances[settlement.toUser] =
          (balances[settlement.toUser] ?? 0) - settlement.amount;
    }

    return balances;
  }

  /// Calculate pairwise balances between users
  List<BalanceModel> calculatePairwiseBalances({
    required List<ExpenseModel> expenses,
    required List<ExpenseSplitModel> allSplits,
    required List<SettlementModel> settlements,
    String? groupId,
  }) {
    final pairwiseBalances = <String, double>{};

    // Process expenses
    for (final expense in expenses) {
      if (groupId != null && expense.groupId != groupId) continue;

      // Get splits for this expense
      final expenseSplits = allSplits
          .where((s) => s.expenseId == expense.id)
          .toList();

      for (final split in expenseSplits) {
        if (split.userId == expense.paidBy) continue;

        // split.userId owes expense.paidBy
        final key = '${split.userId}_${expense.paidBy}';
        pairwiseBalances[key] = (pairwiseBalances[key] ?? 0) - split.amount;

        final reverseKey = '${expense.paidBy}_${split.userId}';
        pairwiseBalances[reverseKey] =
            (pairwiseBalances[reverseKey] ?? 0) + split.amount;
      }
    }

    // Process settlements
    for (final settlement in settlements) {
      if (groupId != null && settlement.groupId != groupId) continue;

      final key = '${settlement.fromUser}_${settlement.toUser}';
      pairwiseBalances[key] = (pairwiseBalances[key] ?? 0) + settlement.amount;

      final reverseKey = '${settlement.toUser}_${settlement.fromUser}';
      pairwiseBalances[reverseKey] =
          (pairwiseBalances[reverseKey] ?? 0) - settlement.amount;
    }

    // Convert to BalanceModel list
    final balances = <BalanceModel>[];
    final processed = <String>{};

    for (final entry in pairwiseBalances.entries) {
      if (processed.contains(entry.key)) continue;

      final parts = entry.key.split('_');
      final userId = parts[0];
      final otherUserId = parts[1];
      final reverseKey = '${otherUserId}_$userId';

      // Skip zero balances
      if (entry.value.abs() < 0.01) {
        processed.add(entry.key);
        processed.add(reverseKey);
        continue;
      }

      // Only add positive balances (one direction)
      if (entry.value > 0) {
        balances.add(
          BalanceModel(
            userId: userId,
            otherUserId: otherUserId,
            amount: entry.value,
            groupId: groupId,
          ),
        );
      }

      processed.add(entry.key);
      processed.add(reverseKey);
    }

    return balances;
  }

  /// Get total amount a user owes across all balances
  double getTotalOwing(String userId, List<BalanceModel> balances) {
    return balances
        .where((b) => b.userId == userId && b.isOwing)
        .fold(0.0, (sum, b) => sum + b.absoluteAmount);
  }

  /// Get total amount a user is owed across all balances
  double getTotalOwed(String userId, List<BalanceModel> balances) {
    return balances
        .where((b) => b.userId == userId && b.isOwed)
        .fold(0.0, (sum, b) => sum + b.absoluteAmount);
  }
}
