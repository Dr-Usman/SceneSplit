import 'package:uuid/uuid.dart';

import '../core/enums/split_type.dart';
import '../models/expense_split_model.dart';

class SplitEngineService {
  static const _uuid = Uuid();

  /// Calculate splits for an expense based on split type
  List<ExpenseSplitModel> calculateSplits({
    required String expenseId,
    required double totalAmount,
    required SplitType splitType,
    required List<String> participantIds,
    Map<String, double>? exactAmounts,
    Map<String, double>? percentages,
  }) {
    switch (splitType) {
      case SplitType.equal:
        return _calculateEqualSplit(expenseId, totalAmount, participantIds);
      case SplitType.exact:
        return _calculateExactSplit(expenseId, participantIds, exactAmounts!);
      case SplitType.percentage:
        return _calculatePercentageSplit(
          expenseId,
          totalAmount,
          participantIds,
          percentages!,
        );
    }
  }

  List<ExpenseSplitModel> _calculateEqualSplit(
    String expenseId,
    double totalAmount,
    List<String> participantIds,
  ) {
    final share = totalAmount / participantIds.length;
    final now = DateTime.now();

    return participantIds.map((userId) {
      return ExpenseSplitModel(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: userId,
        amount: share,
        createdAt: now,
      );
    }).toList();
  }

  List<ExpenseSplitModel> _calculateExactSplit(
    String expenseId,
    List<String> participantIds,
    Map<String, double> exactAmounts,
  ) {
    final now = DateTime.now();

    return participantIds.map((userId) {
      return ExpenseSplitModel(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: userId,
        amount: exactAmounts[userId] ?? 0,
        createdAt: now,
      );
    }).toList();
  }

  List<ExpenseSplitModel> _calculatePercentageSplit(
    String expenseId,
    double totalAmount,
    List<String> participantIds,
    Map<String, double> percentages,
  ) {
    final now = DateTime.now();

    return participantIds.map((userId) {
      final percentage = percentages[userId] ?? 0;
      return ExpenseSplitModel(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: userId,
        amount: totalAmount * (percentage / 100),
        percentage: percentage,
        createdAt: now,
      );
    }).toList();
  }

  /// Validate splits sum to total amount
  bool validateSplits(double totalAmount, List<ExpenseSplitModel> splits) {
    final splitSum = splits.fold(0.0, (sum, split) => sum + split.amount);
    return (splitSum - totalAmount).abs() < 0.01;
  }

  /// Validate percentages sum to 100
  bool validatePercentages(Map<String, double> percentages) {
    final sum = percentages.values.fold(0.0, (sum, p) => sum + p);
    return (sum - 100).abs() < 0.01;
  }

  /// Calculate equal split amount per person
  double calculateEqualSplitAmount(double totalAmount, int participantCount) {
    if (participantCount == 0) return 0;
    return totalAmount / participantCount;
  }
}
