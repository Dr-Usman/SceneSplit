import '../database/app_database.dart';

/// Pure balance math. All amounts in integer cents.
abstract class BalanceService {
  /// Net balance per user: positive = others owe them, negative = they owe.
  ///
  /// An expense credits the payer with the full amount and debits each
  /// participant with their share. A settlement from A to B credits A
  /// (paying back debt) and debits B.
  static Map<String, int> netBalances({
    required List<Expense> expenses,
    required List<ExpenseSplit> splits,
    required List<Settlement> settlements,
  }) {
    final net = <String, int>{};

    for (final e in expenses) {
      net[e.paidById] = (net[e.paidById] ?? 0) + e.amountCents;
    }
    for (final s in splits) {
      net[s.userId] = (net[s.userId] ?? 0) - s.amountCents;
    }
    for (final s in settlements) {
      net[s.fromUserId] = (net[s.fromUserId] ?? 0) + s.amountCents;
      net[s.toUserId] = (net[s.toUserId] ?? 0) - s.amountCents;
    }
    return net;
  }

  /// Simplified pairwise debts from net balances (minimum transactions style).
  static List<PairwiseDebt> simplifyDebts(Map<String, int> net) {
    final creditors = <String, int>{};
    final debtors = <String, int>{};

    for (final e in net.entries) {
      if (e.value > 0) creditors[e.key] = e.value;
      if (e.value < 0) debtors[e.key] = -e.value;
    }

    final result = <PairwiseDebt>[];
    final creditorList = creditors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtorList = debtors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var ci = 0;
    var di = 0;
    while (ci < creditorList.length && di < debtorList.length) {
      final amount = creditorList[ci].value < debtorList[di].value
          ? creditorList[ci].value
          : debtorList[di].value;
      if (amount > 0) {
        result.add(PairwiseDebt(
          fromUserId: debtorList[di].key,
          toUserId: creditorList[ci].key,
          amountCents: amount,
        ));
      }
      creditorList[ci] = MapEntry(
        creditorList[ci].key,
        creditorList[ci].value - amount,
      );
      debtorList[di] = MapEntry(
        debtorList[di].key,
        debtorList[di].value - amount,
      );
      if (creditorList[ci].value == 0) ci++;
      if (debtorList[di].value == 0) di++;
    }
    return result;
  }
}

class PairwiseDebt {
  final String fromUserId;
  final String toUserId;
  final int amountCents;

  const PairwiseDebt({
    required this.fromUserId,
    required this.toUserId,
    required this.amountCents,
  });
}
