import 'dart:math';

import 'package:uuid/uuid.dart';

import '../models/settlement_model.dart';
import '../models/settlement_suggestion.dart';

class SettlementService {
  static const _uuid = Uuid();

  /// Generate optimal settlement suggestions using greedy algorithm
  /// This minimizes the number of transactions needed to settle all debts
  List<SettlementSuggestion> suggestSettlements({
    required Map<String, double> netBalances,
    String? groupId,
  }) {
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    // Separate into debtors and creditors
    for (final entry in netBalances.entries) {
      if (entry.value < -0.01) {
        debtors.add(entry);
      } else if (entry.value > 0.01) {
        creditors.add(entry);
      }
    }

    // Sort: debtors by most negative first, creditors by most positive first
    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final suggestions = <SettlementSuggestion>[];
    int di = 0, ci = 0;

    while (di < debtors.length && ci < creditors.length) {
      final amount = min(-debtors[di].value, creditors[ci].value);

      if (amount > 0.01) {
        suggestions.add(
          SettlementSuggestion(
            fromUserId: debtors[di].key,
            toUserId: creditors[ci].key,
            amount: amount,
            groupId: groupId,
          ),
        );
      }

      // Update balances
      debtors[di] = MapEntry(debtors[di].key, debtors[di].value + amount);
      creditors[ci] = MapEntry(creditors[ci].key, creditors[ci].value - amount);

      if (debtors[di].value.abs() < 0.01) di++;
      if (creditors[ci].value.abs() < 0.01) ci++;
    }

    return suggestions;
  }

  /// Record a settlement
  Future<SettlementModel> recordSettlement({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? groupId,
    String? expenseId,
    String? note,
  }) async {
    return SettlementModel(
      id: _uuid.v4(),
      fromUser: fromUserId,
      toUser: toUserId,
      amount: amount,
      groupId: groupId,
      expenseId: expenseId,
      note: note,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Simplify multiple settlements between same pair of users
  List<SettlementSuggestion> simplifySettlements(
    List<SettlementSuggestion> settlements,
  ) {
    final simplified = <String, double>{};

    for (final settlement in settlements) {
      final key = '${settlement.fromUserId}_${settlement.toUserId}';
      final reverseKey = '${settlement.toUserId}_${settlement.fromUserId}';

      // Check if reverse settlement exists
      if (simplified.containsKey(reverseKey)) {
        final reverseAmount = simplified[reverseKey]!;
        if (settlement.amount > reverseAmount) {
          simplified.remove(reverseKey);
          simplified[key] = settlement.amount - reverseAmount;
        } else if (settlement.amount < reverseAmount) {
          simplified[reverseKey] = reverseAmount - settlement.amount;
        } else {
          simplified.remove(reverseKey);
        }
      } else {
        simplified[key] = (simplified[key] ?? 0) + settlement.amount;
      }
    }

    return simplified.entries.map((entry) {
      final parts = entry.key.split('_');
      return SettlementSuggestion(
        fromUserId: parts[0],
        toUserId: parts[1],
        amount: entry.value,
      );
    }).toList();
  }
}
