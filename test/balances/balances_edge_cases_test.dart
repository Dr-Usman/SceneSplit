import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/services/balance_service.dart';

void main() {
  final now = DateTime(2026, 6, 1);

  ExpensePayer payer(String userId, int amountCents, {String id = 'p'}) =>
      ExpensePayer(
        id: id,
        expenseId: 'exp',
        userId: userId,
        amountCents: amountCents,
      );

  ExpenseSplit split(String userId, int amountCents, {String id = 's'}) =>
      ExpenseSplit(
        id: id,
        expenseId: 'exp',
        userId: userId,
        amountCents: amountCents,
      );

  Settlement settlement(
    String fromUserId,
    String toUserId,
    int amountCents, {
    String id = 'set',
  }) => Settlement(
    id: id,
    groupId: 'g1',
    fromUserId: fromUserId,
    toUserId: toUserId,
    amountCents: amountCents,
    date: now,
    createdAt: now,
  );

  group('BalanceService Edge Cases & Complex Topologies', () {
    test('3-person cyclic debts cancel out to zero open debts', () {
      // Alice paid $60 split equally with Bob (Bob owes Alice $30)
      // Bob paid $60 split equally with Charlie (Charlie owes Bob $30)
      // Charlie paid $60 split equally with Alice (Alice owes Charlie $30)
      // Net balances: Alice = +30 - 30 = 0, Bob = +30 - 30 = 0, Charlie = +30 - 30 = 0
      final payers = [
        payer('alice', 6000, id: 'p1'),
        payer('bob', 6000, id: 'p2'),
        payer('charlie', 6000, id: 'p3'),
      ];
      final splits = [
        // Exp 1: Alice paid for Alice & Bob
        split('alice', 3000, id: 's1'),
        split('bob', 3000, id: 's2'),
        // Exp 2: Bob paid for Bob & Charlie
        split('bob', 3000, id: 's3'),
        split('charlie', 3000, id: 's4'),
        // Exp 3: Charlie paid for Charlie & Alice
        split('charlie', 3000, id: 's5'),
        split('alice', 3000, id: 's6'),
      ];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: const [],
      );
      expect(net['alice'], 0);
      expect(net['bob'], 0);
      expect(net['charlie'], 0);

      final simplified = BalanceService.simplifyDebts(net);
      expect(
        simplified,
        isEmpty,
        reason: 'Cyclic debts must cancel completely',
      );
    });

    test('Transitive debts eliminate intermediary debtor', () {
      // Alice paid $100 for Bob (Bob owes Alice $100)
      // Charlie paid $100 for Alice (Alice owes Charlie $100)
      // Net: Bob = -100, Alice = +100 - 100 = 0, Charlie = +100
      // Simplified: Bob owes Charlie $100 directly. Alice has no transactions.
      final payers = [
        payer('alice', 10000, id: 'p1'),
        payer('charlie', 10000, id: 'p2'),
      ];
      final splits = [
        split('bob', 10000, id: 's1'),
        split('alice', 10000, id: 's2'),
      ];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: const [],
      );
      expect(net['alice'], 0);
      expect(net['bob'], -10000);
      expect(net['charlie'], 10000);

      final simplified = BalanceService.simplifyDebts(net);
      expect(simplified.length, 1);
      expect(simplified.first.fromUserId, 'bob');
      expect(simplified.first.toUserId, 'charlie');
      expect(simplified.first.amountCents, 10000);
    });

    test('Settlement exactly offsets open debt to zero', () {
      // Alice paid $50 for Bob (Bob owes Alice $50)
      // Bob records a settlement of $50 to Alice
      final payers = [payer('alice', 5000)];
      final splits = [split('bob', 5000)];
      final settlements = [settlement('bob', 'alice', 5000)];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: settlements,
      );

      expect(net['alice'], 0);
      expect(net['bob'], 0);

      final debts = BalanceService.simplifyDebts(net);
      expect(debts, isEmpty);
    });

    test('Over-settlement flips direction of debt', () {
      // Bob owed Alice $30, but Bob settled $50 to Alice
      // Now Alice owes Bob $20
      final payers = [payer('alice', 3000)];
      final splits = [split('bob', 3000)];
      final settlements = [settlement('bob', 'alice', 5000)];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: settlements,
      );

      expect(net['alice'], -2000);
      expect(net['bob'], 2000);

      final debts = BalanceService.simplifyDebts(net);
      expect(debts.length, 1);
      expect(debts.first.fromUserId, 'alice');
      expect(debts.first.toUserId, 'bob');
      expect(debts.first.amountCents, 2000);
    });

    test('Isolated subgraphs do not cross debts between separate clusters', () {
      // Cluster 1: Alice paid for Bob $40
      // Cluster 2: Dave paid for Eve $60
      final payers = [
        payer('alice', 4000, id: 'p1'),
        payer('dave', 6000, id: 'p2'),
      ];
      final splits = [
        split('bob', 4000, id: 's1'),
        split('eve', 6000, id: 's2'),
      ];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: const [],
      );
      final debts = BalanceService.simplifyDebts(net);

      expect(debts.length, 2);
      // Both debts are independent
      final cluster1 = debts.firstWhere((d) => d.fromUserId == 'bob');
      expect(cluster1.toUserId, 'alice');
      expect(cluster1.amountCents, 4000);

      final cluster2 = debts.firstWhere((d) => d.fromUserId == 'eve');
      expect(cluster2.toUserId, 'dave');
      expect(cluster2.amountCents, 6000);
    });

    test('Single-person solo expense has zero net impact on balances', () {
      // Alice paid $75 and split 100% to herself
      final payers = [payer('alice', 7500)];
      final splits = [split('alice', 7500)];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: const [],
      );
      expect(net['alice'], 0);
      expect(BalanceService.simplifyDebts(net), isEmpty);
    });

    test('Zero-cent splits or settlements are safely ignored', () {
      final payers = [payer('alice', 1000)];
      final splits = [
        split('bob', 1000),
        split('charlie', 0), // zero split
      ];
      final settlements = [
        settlement('charlie', 'alice', 0), // zero settlement
      ];

      final net = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: settlements,
      );

      expect(net['alice'], 1000);
      expect(net['bob'], -1000);
      expect(net['charlie'], 0);

      final debts = BalanceService.simplifyDebts(net);
      expect(debts.length, 1);
      expect(debts.first.fromUserId, 'bob');
      expect(debts.first.toUserId, 'alice');
    });

    test(
      'Conservation of money: sum of credits equals sum of debts down to 1 cent',
      () {
        // 8-person complex bill with multiple payers and uneven splits
        final payers = [
          payer('u1', 12345, id: 'p1'),
          payer('u2', 6789, id: 'p2'),
          payer('u3', 45000, id: 'p3'),
        ];
        final splits = [
          split('u1', 8000, id: 's1'),
          split('u2', 8000, id: 's2'),
          split('u3', 8000, id: 's3'),
          split('u4', 10000, id: 's4'),
          split('u5', 10000, id: 's5'),
          split('u6', 10000, id: 's6'),
          split('u7', 5067, id: 's7'),
          split('u8', 5067, id: 's8'),
        ];

        final net = BalanceService.netBalances(
          payers: payers,
          splits: splits,
          settlements: const [],
        );

        var totalNet = 0;
        for (final int balance in net.values) {
          totalNet += balance;
        }
        expect(
          totalNet,
          0,
          reason: 'Global net sum across all members must be strictly zero',
        );

        final debts = BalanceService.simplifyDebts(net);
        var totalCredited = 0;
        var totalDebited = 0;
        for (final d in debts) {
          totalDebited += d.amountCents;
          totalCredited += d.amountCents;
        }
        expect(totalDebited, totalCredited);
        expect(debts.every((d) => d.amountCents > 0), isTrue);
      },
    );
  });
}
