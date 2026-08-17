import '../database/app_database.dart';

/// Pure balance math. All amounts in integer cents.
abstract class BalanceService {
  /// Net balance per user: positive = others owe them, negative = they owe.
  ///
  /// An expense credits each payer with their paid amount and debits each
  /// participant with their share. A settlement from A to B credits A
  /// (paying back debt) and debits B.
  static Map<String, int> netBalances({
    required List<ExpensePayer> payers,
    required List<ExpenseSplit> splits,
    required List<Settlement> settlements,
  }) {
    final net = <String, int>{};

    for (final p in payers) {
      net[p.userId] = (net[p.userId] ?? 0) + p.amountCents;
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

  /// Fewest payments that settle [net] (debtors pay creditors).
  ///
  /// Same min-transfer matching as before the bill-linked pairwise change.
  /// At most n-1 payments. Used for Who-owes-whom and settle-up.
  static List<OpenDebt> simplifyDebts(Map<String, int> net) {
    final creditors = <String, int>{};
    final debtors = <String, int>{};

    for (final e in net.entries) {
      if (e.value > 0) creditors[e.key] = e.value;
      if (e.value < 0) debtors[e.key] = -e.value;
    }

    int byAmountThenId(MapEntry<String, int> a, MapEntry<String, int> b) {
      final byCents = b.value.compareTo(a.value);
      if (byCents != 0) return byCents;
      return a.key.compareTo(b.key);
    }

    final result = <OpenDebt>[];
    final creditorList = creditors.entries.toList()..sort(byAmountThenId);
    final debtorList = debtors.entries.toList()..sort(byAmountThenId);

    var ci = 0;
    var di = 0;
    while (ci < creditorList.length && di < debtorList.length) {
      final amount = creditorList[ci].value < debtorList[di].value
          ? creditorList[ci].value
          : debtorList[di].value;
      if (amount > 0) {
        result.add(
          OpenDebt(
            fromUserId: debtorList[di].key,
            toUserId: creditorList[ci].key,
            amountCents: amount,
          ),
        );
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

    result.sort((x, y) {
      final byAmount = y.amountCents.compareTo(x.amountCents);
      if (byAmount != 0) return byAmount;
      final byFrom = x.fromUserId.compareTo(y.fromUserId);
      if (byFrom != 0) return byFrom;
      return x.toUserId.compareTo(y.toUserId);
    });
    return result;
  }
}

/// One open amount: [fromUserId] owes [toUserId] [amountCents].
class OpenDebt {
  final String fromUserId;
  final String toUserId;
  final int amountCents;

  const OpenDebt({
    required this.fromUserId,
    required this.toUserId,
    required this.amountCents,
  });
}
