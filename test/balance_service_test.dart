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

  String debtKey(OpenDebt d) =>
      '${d.fromUserId}->${d.toUserId}:${d.amountCents}';

  Map<String, int> netFromDebts(List<OpenDebt> debts) {
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
    required List<OpenDebt> debts,
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

  group('BalanceService.simplifyDebts', () {
    test('produces fewest transfers from nets', () {
      final debts = BalanceService.simplifyDebts({
        'alice': 70,
        'bob': -30,
        'carol': -40,
      });

      expect(debts, hasLength(2));
      expect(debts.map(debtKey).toSet(), {'bob->alice:30', 'carol->alice:40'});
    });

    test('returns empty when everyone is settled', () {
      expect(BalanceService.simplifyDebts({'a': 0, 'b': 0}), isEmpty);
      expect(BalanceService.simplifyDebts(const {}), isEmpty);
    });

    test('single debtor pays the single creditor', () {
      final debts = BalanceService.simplifyDebts({'alice': 50, 'bob': -50});
      expect(debts.map(debtKey), ['bob->alice:50']);
    });

    test('debtors pay creditors with at most n-1 transfers', () {
      final nets = {'alice': 100, 'bob': 50, 'charlie': -150};
      final debts = BalanceService.simplifyDebts(nets);

      expect(debts.map(debtKey).toSet(), {
        'charlie->alice:100',
        'charlie->bob:50',
      });
      expect(debts.length, lessThan(nets.length));
      expect(netFromDebts(debts), nets);
    });

    test('settlement is reflected through nets', () {
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
      final nets = BalanceService.netBalances(
        payers: payers,
        splits: splits,
        settlements: settlements,
      );

      expect(BalanceService.simplifyDebts(nets), isEmpty);
    });

    test('HNSU trip settles in three payments to Usman', () {
      // Tickets 1800: Nadeem 1200 + Usman 600, split 4.
      // Water 160: Usman, split 4.
      // Petrol 1050: Hamza, split Usman/Nadeem/Shoaib only.
      // Kababjees 2650, fries 480, chai 300, parking 100: Usman, split 4.
      const usman = 'usman';
      const hamza = 'hamza';
      const nadeem = 'nadeem';
      const shoaib = 'shoaib';
      const all = [usman, hamza, nadeem, shoaib];
      const petrolPeople = [usman, nadeem, shoaib];

      final expenses =
          <String, ({List<(String, int)> paid, List<String> split})>{
            'tickets': (paid: [(nadeem, 120000), (usman, 60000)], split: all),
            'water': (paid: [(usman, 16000)], split: all),
            'petrol': (paid: [(hamza, 105000)], split: petrolPeople),
            'kababjees': (paid: [(usman, 265000)], split: all),
            'fries': (paid: [(usman, 48000)], split: all),
            'chai': (paid: [(usman, 30000)], split: all),
            'parking': (paid: [(usman, 10000)], split: all),
          };

      final allPayers = <ExpensePayer>[];
      final allSplits = <ExpenseSplit>[];

      for (final e in expenses.entries) {
        final total = e.value.paid.fold(0, (a, p) => a + p.$2);
        final shareMap = SplitEngineService.equalSplit(total, e.value.split);
        allPayers.addAll([
          for (final p in e.value.paid)
            payer(
              id: '${e.key}_${p.$1}',
              expenseId: e.key,
              userId: p.$1,
              amountCents: p.$2,
            ),
        ]);
        allSplits.addAll([
          for (final s in shareMap.entries)
            split(
              id: '${e.key}_${s.key}',
              expenseId: e.key,
              userId: s.key,
              amountCents: s.value,
            ),
        ]);
      }

      final nets = BalanceService.netBalances(
        payers: allPayers,
        splits: allSplits,
        settlements: const [],
      );
      final debts = BalanceService.simplifyDebts(nets);

      expect(nets[usman], 256750);
      expect(nets[hamza], -32250);
      expect(nets[nadeem], -52250);
      expect(nets[shoaib], -172250);

      expect(debts.map(debtKey).toSet(), {
        'hamza->usman:32250',
        'nadeem->usman:52250',
        'shoaib->usman:172250',
      });

      expectDebtsMatchNets(
        payers: allPayers,
        splits: allSplits,
        settlements: const [],
        debts: debts,
      );
    });
  });
}
