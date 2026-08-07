import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/services/balance_service.dart';
import 'package:scene_split/services/split_engine_service.dart';

void main() {
  final now = DateTime(2026, 7, 14);

  ExpensePayer payer({
    required String id,
    required String expenseId,
    required String userId,
    required int amountCents,
  }) {
    return ExpensePayer(
      id: id,
      expenseId: expenseId,
      userId: userId,
      amountCents: amountCents,
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
    String id = 's1',
  }) {
    return Settlement(
      id: id,
      groupId: 'g1',
      fromUserId: fromUserId,
      toUserId: toUserId,
      amountCents: amountCents,
      createdAt: now,
    );
  }

  String debtKey(PairwiseDebt d) =>
      '${d.fromUserId}->${d.toUserId}:${d.amountCents}';

  Map<String, int> netFromDebts(List<PairwiseDebt> debts) {
    final net = <String, int>{};
    for (final d in debts) {
      net[d.toUserId] = (net[d.toUserId] ?? 0) + d.amountCents;
      net[d.fromUserId] = (net[d.fromUserId] ?? 0) - d.amountCents;
    }
    return net;
  }

  void expectDebtsMatchNets({
    required List<ExpensePayer> payers,
    required List<ExpenseSplit> splits,
    required List<Settlement> settlements,
    required List<PairwiseDebt> debts,
  }) {
    final expected = BalanceService.netBalances(
      payers: payers,
      splits: splits,
      settlements: settlements,
    );
    final actual = netFromDebts(debts);
    final users = {...expected.keys, ...actual.keys};
    for (final u in users) {
      expect(actual[u] ?? 0, expected[u] ?? 0, reason: 'net for $u');
    }
  }

  group('BalanceService.netBalances', () {
    test('credits payer and debits participants', () {
      final net = BalanceService.netBalances(
        payers: [
          payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 100),
        ],
        splits: [
          split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 50),
          split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 50),
        ],
        settlements: const [],
      );

      expect(net['alice'], 50);
      expect(net['bob'], -50);
    });

    test('credits multiple payers independently of splits', () {
      // $100 bill: Alice paid $60, Bob paid $40; equal split three ways.
      final net = BalanceService.netBalances(
        payers: [
          payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 60),
          payer(id: 'p2', expenseId: 'e1', userId: 'bob', amountCents: 40),
        ],
        splits: [
          split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 34),
          split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 33),
          split(id: 'sp3', expenseId: 'e1', userId: 'charlie', amountCents: 33),
        ],
        settlements: const [],
      );

      expect(net['alice'], 26);
      expect(net['bob'], 7);
      expect(net['charlie'], -33);
    });

    test('applies settlements between users', () {
      final net = BalanceService.netBalances(
        payers: [
          payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 100),
        ],
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

  group('BalanceService.pairwiseDebts', () {
    test('single-payer equal split: participants owe the payer', () {
      final payers = [
        payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 100),
      ];
      final splits = [
        split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 50),
        split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 50),
      ];
      final debts = BalanceService.pairwiseDebts(
        payersByExpense: {'e1': payers},
        splitsByExpense: {'e1': splits},
        settlements: const [],
      );

      expect(debts.map(debtKey), ['bob->alice:50']);
      expectDebtsMatchNets(
        payers: payers,
        splits: splits,
        settlements: const [],
        debts: debts,
      );
    });

    test('multi-payer allocates shares toward each payer', () {
      final payers = [
        payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 60),
        payer(id: 'p2', expenseId: 'e1', userId: 'bob', amountCents: 40),
      ];
      final splits = [
        split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 34),
        split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 33),
        split(id: 'sp3', expenseId: 'e1', userId: 'charlie', amountCents: 33),
      ];
      final debts = BalanceService.pairwiseDebts(
        payersByExpense: {'e1': payers},
        splitsByExpense: {'e1': splits},
        settlements: const [],
      );

      expectDebtsMatchNets(
        payers: payers,
        splits: splits,
        settlements: const [],
        debts: debts,
      );
      // Charlie was not a payer; he should only owe Alice and/or Bob.
      for (final d in debts) {
        if (d.fromUserId == 'charlie') {
          expect(d.toUserId, anyOf('alice', 'bob'));
        }
      }
    });

    test('settlement reduces the matching edge', () {
      final payers = [
        payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 100),
      ];
      final splits = [
        split(id: 'sp1', expenseId: 'e1', userId: 'alice', amountCents: 50),
        split(id: 'sp2', expenseId: 'e1', userId: 'bob', amountCents: 50),
      ];
      final settlements = [
        settlement(fromUserId: 'bob', toUserId: 'alice', amountCents: 50),
      ];
      final debts = BalanceService.pairwiseDebts(
        payersByExpense: {'e1': payers},
        splitsByExpense: {'e1': splits},
        settlements: settlements,
      );

      expect(debts, isEmpty);
      expectDebtsMatchNets(
        payers: payers,
        splits: splits,
        settlements: settlements,
        debts: debts,
      );
    });

    test('bilateral net cancels A↔B across expenses', () {
      // Alice pays 90 for Alice+Bob; Bob pays 60 for Alice+Bob.
      final payersByExpense = {
        'e1': [
          payer(id: 'p1', expenseId: 'e1', userId: 'alice', amountCents: 90),
        ],
        'e2': [
          payer(id: 'p2', expenseId: 'e2', userId: 'bob', amountCents: 60),
        ],
      };
      final splitsByExpense = {
        'e1': [
          split(id: 's1', expenseId: 'e1', userId: 'alice', amountCents: 45),
          split(id: 's2', expenseId: 'e1', userId: 'bob', amountCents: 45),
        ],
        'e2': [
          split(id: 's3', expenseId: 'e2', userId: 'alice', amountCents: 30),
          split(id: 's4', expenseId: 'e2', userId: 'bob', amountCents: 30),
        ],
      };
      final debts = BalanceService.pairwiseDebts(
        payersByExpense: payersByExpense,
        splitsByExpense: splitsByExpense,
        settlements: const [],
      );

      // Bob owes Alice 45 from e1; Alice owes Bob 30 from e2 → Bob→Alice 15.
      expect(debts.map(debtKey), ['bob->alice:15']);
      expectDebtsMatchNets(
        payers: [...payersByExpense['e1']!, ...payersByExpense['e2']!],
        splits: [...splitsByExpense['e1']!, ...splitsByExpense['e2']!],
        settlements: const [],
        debts: debts,
      );
    });

    test('paddle group: Ali never pays Hassan', () {
      const court = 3620 * 100;
      const juice = 2000 * 100;
      final all = ['usman', 'shahzad', 'hassan', 'ali'];
      final juicePeople = ['usman', 'shahzad', 'hassan'];

      final courtSplits = SplitEngineService.equalSplit(court, all);
      final juiceSplits = SplitEngineService.equalSplit(juice, juicePeople);

      final payersByExpense = {
        'court': [
          payer(
            id: 'p1',
            expenseId: 'court',
            userId: 'shahzad',
            amountCents: court,
          ),
        ],
        'juice': [
          payer(
            id: 'p2',
            expenseId: 'juice',
            userId: 'hassan',
            amountCents: juice,
          ),
        ],
      };
      final splitsByExpense = {
        'court': [
          for (final e in courtSplits.entries)
            split(
              id: 'c_${e.key}',
              expenseId: 'court',
              userId: e.key,
              amountCents: e.value,
            ),
        ],
        'juice': [
          for (final e in juiceSplits.entries)
            split(
              id: 'j_${e.key}',
              expenseId: 'juice',
              userId: e.key,
              amountCents: e.value,
            ),
        ],
      };

      final debts = BalanceService.pairwiseDebts(
        payersByExpense: payersByExpense,
        splitsByExpense: splitsByExpense,
        settlements: const [],
      );

      expect(
        debts.any((d) => d.fromUserId == 'ali' && d.toUserId == 'hassan'),
        isFalse,
      );

      final keys = debts.map(debtKey).toSet();
      expect(keys, contains('usman->shahzad:${courtSplits['usman']}'));
      expect(keys, contains('ali->shahzad:${courtSplits['ali']}'));
      expect(keys, contains('usman->hassan:${juiceSplits['usman']}'));

      // Hassan owes Shahzad court share minus what Shahzad owes Hassan for juice.
      final hassanToShahzad = courtSplits['hassan']! - juiceSplits['shahzad']!;
      expect(keys, contains('hassan->shahzad:$hassanToShahzad'));

      expectDebtsMatchNets(
        payers: [...payersByExpense['court']!, ...payersByExpense['juice']!],
        splits: [...splitsByExpense['court']!, ...splitsByExpense['juice']!],
        settlements: const [],
        debts: debts,
      );
    });
  });
}
