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

  /// Bill-linked pairwise debts: participants owe payers for shared expenses,
  /// then only A↔B amounts cancel. No third-party redirection.
  ///
  /// [payersByExpense] / [splitsByExpense] map expense id → rows for that
  /// expense. Settlements reduce the `from → to` edge.
  static List<PairwiseDebt> pairwiseDebts({
    required Map<String, List<ExpensePayer>> payersByExpense,
    required Map<String, List<ExpenseSplit>> splitsByExpense,
    required List<Settlement> settlements,
  }) {
    // Signed edge: positive means fromUser owes toUser.
    final edges = <String, Map<String, int>>{};

    void addEdge(String from, String to, int cents) {
      if (from == to || cents == 0) return;
      edges.putIfAbsent(from, () => <String, int>{});
      edges[from]![to] = (edges[from]![to] ?? 0) + cents;
    }

    final expenseIds = {...payersByExpense.keys, ...splitsByExpense.keys};

    for (final expenseId in expenseIds) {
      final payers = payersByExpense[expenseId] ?? const [];
      final splits = splitsByExpense[expenseId] ?? const [];
      if (payers.isEmpty || splits.isEmpty) continue;

      final shares = <String, int>{};
      for (final s in splits) {
        shares[s.userId] = (shares[s.userId] ?? 0) + s.amountCents;
      }
      final weightTotal = shares.values.fold(0, (a, b) => a + b);
      if (weightTotal <= 0) continue;

      for (final p in payers) {
        if (p.amountCents <= 0) continue;
        final allocation = _allocateByWeights(
          p.amountCents,
          shares,
          weightTotal,
        );
        for (final e in allocation.entries) {
          if (e.key != p.userId) {
            addEdge(e.key, p.userId, e.value);
          }
        }
      }
    }

    for (final s in settlements) {
      addEdge(s.fromUserId, s.toUserId, -s.amountCents);
    }

    final result = <PairwiseDebt>[];
    final seen = <String>{};

    final users = <String>{
      ...edges.keys,
      for (final m in edges.values) ...m.keys,
    }.toList()..sort();

    for (var i = 0; i < users.length; i++) {
      for (var j = i + 1; j < users.length; j++) {
        final a = users[i];
        final b = users[j];
        final pairKey = '$a\x00$b';
        if (!seen.add(pairKey)) continue;

        final aOwesB = edges[a]?[b] ?? 0;
        final bOwesA = edges[b]?[a] ?? 0;
        final net = aOwesB - bOwesA;
        if (net > 0) {
          result.add(
            PairwiseDebt(fromUserId: a, toUserId: b, amountCents: net),
          );
        } else if (net < 0) {
          result.add(
            PairwiseDebt(fromUserId: b, toUserId: a, amountCents: -net),
          );
        }
      }
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

  /// Hamilton / largest-remainder allocation of [amount] across [weights].
  static Map<String, int> _allocateByWeights(
    int amount,
    Map<String, int> weights,
    int weightTotal,
  ) {
    if (amount <= 0 || weightTotal <= 0 || weights.isEmpty) return {};

    final ids = weights.keys.toList()..sort();
    final floors = <String, int>{};
    final fractions = <String, double>{};
    var allocated = 0;

    for (final id in ids) {
      final w = weights[id]!;
      if (w <= 0) {
        floors[id] = 0;
        fractions[id] = 0;
        continue;
      }
      final exact = amount * w / weightTotal;
      final floor = exact.floor();
      floors[id] = floor;
      fractions[id] = exact - floor;
      allocated += floor;
    }

    var remainder = amount - allocated;
    final byFraction = ids.toList()
      ..sort((a, b) {
        final byFrac = fractions[b]!.compareTo(fractions[a]!);
        if (byFrac != 0) return byFrac;
        return a.compareTo(b);
      });

    var i = 0;
    while (remainder > 0 && byFraction.isNotEmpty) {
      final id = byFraction[i % byFraction.length];
      floors[id] = floors[id]! + 1;
      remainder--;
      i++;
    }
    return floors;
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
