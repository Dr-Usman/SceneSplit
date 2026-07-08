import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/services/balance_service.dart';

void main() {
  final now = DateTime(2026, 7, 14);

  Expense expense({
    required String id,
    required int amountCents,
    required String paidById,
  }) {
    return Expense(
      id: id,
      groupId: 'g1',
      title: 'Test',
      amountCents: amountCents,
      paidById: paidById,
      splitType: 'equal',
      date: now,
      createdAt: now,
    );
  }

  ExpenseSplit split({
    required String id,
    required String expenseId,
    required String userId,
    required int amountCents,
  }) {
    return ExpenseSplit(
      id: id,
      expenseId: expenseId,
      userId: userId,
      amountCents: amountCents,
    );
  }

  Settlement settlement({
    required String fromUserId,
    required String toUserId,
    required int amountCents,
  }) {
    return Settlement(
      id: 's1',
      groupId: 'g1',
      fromUserId: fromUserId,
      toUserId: toUserId,
      amountCents: amountCents,
      createdAt: now,
    );
  }

  group('BalanceService.netBalances', () {
    test('credits payer and debits participants', () {
      final net = BalanceService.netBalances(
        expenses: [expense(id: 'e1', amountCents: 100, paidById: 'alice')],
        splits: [
          split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 50),
          split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 50),
        ],
        settlements: const [],
      );

      expect(net['alice'], 50);
      expect(net['bob'], -50);
    });

    test('applies settlements between users', () {
      final net = BalanceService.netBalances(
        expenses: [expense(id: 'e1', amountCents: 100, paidById: 'alice')],
        splits: [
          split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 50),
          split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 50),
        ],
        settlements: [
          settlement(fromUserId: 'bob', toUserId: 'alice', amountCents: 50),
        ],
      );

      expect(net['alice'], 0);
      expect(net['bob'], 0);
    });
  });

  group('BalanceService.simplifyDebts', () {
    test('produces minimum pairwise transfers', () {
      final debts = BalanceService.simplifyDebts({
        'alice': 70,
        'bob': -30,
        'carol': -40,
      });

      expect(debts, hasLength(2));
      expect(
        debts.map((d) => '${d.fromUserId}->${d.toUserId}:${d.amountCents}'),
        containsAll(['bob->alice:30', 'carol->alice:40']),
      );
    });
  });
}
