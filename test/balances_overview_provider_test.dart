import 'package:flutter_test/flutter_test.dart';

import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/balances_overview_provider.dart';
import 'package:scene_split/providers/group_detail_provider.dart';
import 'package:scene_split/services/balance_service.dart';

OpenPairwiseBalance _debt({
  required String groupId,
  required String groupName,
  required String currency,
  required String from,
  required String to,
  required int cents,
}) {
  return OpenPairwiseBalance(
    groupId: groupId,
    groupName: groupName,
    groupEmoji: '🎬',
    currencyCode: currency,
    debt: PairwiseDebt(fromUserId: from, toUserId: to, amountCents: cents),
  );
}

void main() {
  group('filterOpenDebts', () {
    final debts = [
      _debt(
        groupId: 'g1',
        groupName: 'Trip',
        currency: 'PKR',
        from: 'ali',
        to: 'you',
        cents: 500,
      ),
      _debt(
        groupId: 'g2',
        groupName: 'Dinner',
        currency: 'PKR',
        from: 'bob',
        to: 'you',
        cents: 200,
      ),
      _debt(
        groupId: 'g1',
        groupName: 'Trip',
        currency: 'PKR',
        from: 'you',
        to: 'ali',
        cents: 100,
      ),
      _debt(
        groupId: 'g3',
        groupName: 'USD trip',
        currency: 'USD',
        from: 'ali',
        to: 'you',
        cents: 50,
      ),
    ];

    test('no filters returns all', () {
      expect(filterOpenDebts(debts), hasLength(4));
    });

    test('Whom=You shows only edges owed to current user', () {
      final filtered = filterOpenDebts(debts, toId: 'you');
      expect(filtered, hasLength(3));
      expect(filtered.every((d) => d.debt.toUserId == 'you'), isTrue);
    });

    test('Who+Whom filters to directed pair', () {
      final filtered = filterOpenDebts(debts, fromId: 'ali', toId: 'you');
      expect(filtered, hasLength(2));
      expect(filtered.map((d) => d.groupId), containsAll(['g1', 'g3']));
    });

    test('Who only filters by debtor', () {
      final filtered = filterOpenDebts(debts, fromId: 'bob');
      expect(filtered, hasLength(1));
      expect(filtered.single.debt.fromUserId, 'bob');
    });
  });

  group('aggregatePairByCurrency', () {
    test('sums per currency and skips other pairs', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 100,
        ),
        _debt(
          groupId: 'g2',
          groupName: 'B',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 50,
        ),
        _debt(
          groupId: 'g3',
          groupName: 'C',
          currency: 'USD',
          from: 'ali',
          to: 'you',
          cents: 20,
        ),
        _debt(
          groupId: 'g4',
          groupName: 'D',
          currency: 'PKR',
          from: 'bob',
          to: 'you',
          cents: 999,
        ),
      ];

      final totals = aggregatePairByCurrency(debts, fromId: 'ali', toId: 'you');
      expect(totals, hasLength(2));
      expect(totals[0].currencyCode, 'PKR');
      expect(totals[0].amountCents, 150);
      expect(totals[1].currencyCode, 'USD');
      expect(totals[1].amountCents, 20);
    });
  });

  group('summarizePersonPovTotals', () {
    test('sums owed and owe per currency across counterparties', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 100,
        ),
        _debt(
          groupId: 'g2',
          groupName: 'B',
          currency: 'PKR',
          from: 'bob',
          to: 'you',
          cents: 50,
        ),
        _debt(
          groupId: 'g3',
          groupName: 'C',
          currency: 'USD',
          from: 'ali',
          to: 'you',
          cents: 20,
        ),
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'you',
          to: 'ali',
          cents: 30,
        ),
        _debt(
          groupId: 'g4',
          groupName: 'D',
          currency: 'EUR',
          from: 'bob',
          to: 'ali',
          cents: 999,
        ),
      ];

      final totals = summarizePersonPovTotals(debts, 'you');
      expect(totals, hasLength(2));
      expect(totals[0].currencyCode, 'PKR');
      expect(totals[0].owedToThemCents, 150);
      expect(totals[0].theyOweCents, 30);
      expect(totals[1].currencyCode, 'USD');
      expect(totals[1].owedToThemCents, 20);
      expect(totals[1].theyOweCents, 0);
    });

    test('returns empty when person has no open edges', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'ali',
          to: 'bob',
          cents: 100,
        ),
      ];
      expect(summarizePersonPovTotals(debts, 'you'), isEmpty);
    });
  });

  group('netPersonPovTotals', () {
    test('nets only currencies with both sides open', () {
      final nets = netPersonPovTotals([
        const PersonPovCurrencyTotals(
          currencyCode: 'PKR',
          owedToThemCents: 1800,
          theyOweCents: 43800,
        ),
        const PersonPovCurrencyTotals(
          currencyCode: 'USD',
          owedToThemCents: 20,
          theyOweCents: 0,
        ),
      ]);
      expect(nets, hasLength(1));
      expect(nets.single.currencyCode, 'PKR');
      expect(nets.single.netCentsFromPerson, 42000);
      expect(nets.single.personOwesOther, isTrue);
      expect(nets.single.amountCents, 42000);
    });

    test('skips equal gross sides', () {
      final nets = netPersonPovTotals([
        const PersonPovCurrencyTotals(
          currencyCode: 'PKR',
          owedToThemCents: 100,
          theyOweCents: 100,
        ),
      ]);
      expect(nets, isEmpty);
    });

    test('other owes person when credit exceeds debt', () {
      final nets = netPersonPovTotals([
        const PersonPovCurrencyTotals(
          currencyCode: 'PKR',
          owedToThemCents: 500,
          theyOweCents: 100,
        ),
      ]);
      expect(nets.single.netCentsFromPerson, -400);
      expect(nets.single.personOwesOther, isFalse);
      expect(nets.single.amountCents, 400);
    });
  });

  group('scopeDebtsForBalancesHero', () {
    final debts = [
      _debt(
        groupId: 'g1',
        groupName: 'A',
        currency: 'PKR',
        from: 'ali',
        to: 'you',
        cents: 100,
      ),
      _debt(
        groupId: 'g2',
        groupName: 'B',
        currency: 'PKR',
        from: 'you',
        to: 'ali',
        cents: 40,
      ),
      _debt(
        groupId: 'g3',
        groupName: 'C',
        currency: 'USD',
        from: 'bob',
        to: 'you',
        cents: 20,
      ),
      _debt(
        groupId: 'g4',
        groupName: 'D',
        currency: 'EUR',
        from: 'bob',
        to: 'ali',
        cents: 999,
      ),
      _debt(
        groupId: 'g5',
        groupName: 'E',
        currency: 'PKR',
        from: 'ali',
        to: 'bob',
        cents: 15,
      ),
    ];

    test('neither Who nor Whom returns empty', () {
      expect(scopeDebtsForBalancesHero(debts), isEmpty);
    });

    test('Whom only keeps all edges involving Whom', () {
      final scoped = scopeDebtsForBalancesHero(debts, whomId: 'you');
      expect(scoped, hasLength(3));
      expect(
        scoped.every((d) {
          return d.debt.fromUserId == 'you' || d.debt.toUserId == 'you';
        }),
        isTrue,
      );
      final totals = summarizePersonPovTotals(scoped, 'you');
      expect(
        totals.singleWhere((t) => t.currencyCode == 'PKR').owedToThemCents,
        100,
      );
      expect(
        totals.singleWhere((t) => t.currencyCode == 'PKR').theyOweCents,
        40,
      );
      expect(
        totals.singleWhere((t) => t.currencyCode == 'USD').owedToThemCents,
        20,
      );
    });

    test('Who only keeps all edges involving Who', () {
      final scoped = scopeDebtsForBalancesHero(debts, whoId: 'ali');
      expect(scoped, hasLength(4));
      expect(
        scoped.every((d) {
          return d.debt.fromUserId == 'ali' || d.debt.toUserId == 'ali';
        }),
        isTrue,
      );
      final totals = summarizePersonPovTotals(scoped, 'ali');
      expect(
        totals.singleWhere((t) => t.currencyCode == 'PKR').owedToThemCents,
        40,
      );
      expect(
        totals.singleWhere((t) => t.currencyCode == 'PKR').theyOweCents,
        115,
      );
      expect(
        totals.singleWhere((t) => t.currencyCode == 'EUR').owedToThemCents,
        999,
      );
    });

    test('both keeps only the Who–Whom pair (both directions)', () {
      final scoped = scopeDebtsForBalancesHero(
        debts,
        whoId: 'ali',
        whomId: 'you',
      );
      expect(scoped, hasLength(2));
      expect(
        scoped.every((d) {
          final ids = {d.debt.fromUserId, d.debt.toUserId};
          return ids.contains('you') && ids.contains('ali');
        }),
        isTrue,
      );
      final totals = summarizePersonPovTotals(scoped, 'you');
      expect(totals, hasLength(1));
      expect(totals.single.owedToThemCents, 100);
      expect(totals.single.theyOweCents, 40);
    });

    test('both drops edges with other people', () {
      final scoped = scopeDebtsForBalancesHero(
        debts,
        whoId: 'bob',
        whomId: 'you',
      );
      expect(scoped, hasLength(1));
      expect(scoped.single.debt.fromUserId, 'bob');
      expect(scoped.single.debt.toUserId, 'you');
      final totals = summarizePersonPovTotals(scoped, 'you');
      expect(totals.single.owedToThemCents, 20);
      expect(totals.single.theyOweCents, 0);
    });
  });

  group('aggregatePersonPovByCounterparty', () {
    test('groups by counterparty and currency', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 100,
        ),
        _debt(
          groupId: 'g2',
          groupName: 'B',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 40,
        ),
        _debt(
          groupId: 'g3',
          groupName: 'C',
          currency: 'USD',
          from: 'bob',
          to: 'you',
          cents: 10,
        ),
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'you',
          to: 'ali',
          cents: 25,
        ),
      ];

      final agg = aggregatePersonPovByCounterparty(debts, 'you');
      expect(agg.owedByCounterparty['ali']!['PKR'], 140);
      expect(agg.owedByCounterparty['bob']!['USD'], 10);
      expect(agg.oweToCounterparty['ali']!['PKR'], 25);
      expect(agg.oweToCounterparty.containsKey('bob'), isFalse);
    });
  });

  group('groupDebtsByPair', () {
    test('merges same pair across currencies and scenes', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 100,
        ),
        _debt(
          groupId: 'g2',
          groupName: 'B',
          currency: 'PKR',
          from: 'ali',
          to: 'you',
          cents: 50,
        ),
        _debt(
          groupId: 'g3',
          groupName: 'C',
          currency: 'USD',
          from: 'ali',
          to: 'you',
          cents: 20,
        ),
        _debt(
          groupId: 'g1',
          groupName: 'A',
          currency: 'PKR',
          from: 'bob',
          to: 'you',
          cents: 75,
        ),
      ];

      final pairs = groupDebtsByPair(debts);
      expect(pairs, hasLength(2));

      final ali = pairs.firstWhere((p) => p.fromUserId == 'ali');
      expect(ali.toUserId, 'you');
      expect(ali.sceneCount, 3);
      expect(ali.currencyTotals, hasLength(2));
      expect(ali.currencyTotals[0].currencyCode, 'PKR');
      expect(ali.currencyTotals[0].amountCents, 150);
      expect(ali.currencyTotals[1].currencyCode, 'USD');
      expect(ali.currencyTotals[1].amountCents, 20);
      expect(ali.sceneLabels, hasLength(3));
      expect(ali.sceneLabels.first, contains('A'));

      final bob = pairs.firstWhere((p) => p.fromUserId == 'bob');
      expect(bob.currencyTotals.single.amountCents, 75);
      expect(bob.sceneCount, 1);
      expect(bob.sceneLabels, ['🎬 A']);
    });
  });

  group('groupDebtsByCurrency', () {
    test('sections and sorts largest first within currency', () {
      final debts = [
        _debt(
          groupId: 'g1',
          groupName: 'Small',
          currency: 'PKR',
          from: 'a',
          to: 'b',
          cents: 10,
        ),
        _debt(
          groupId: 'g2',
          groupName: 'Big',
          currency: 'PKR',
          from: 'a',
          to: 'b',
          cents: 90,
        ),
        _debt(
          groupId: 'g3',
          groupName: 'Usd',
          currency: 'USD',
          from: 'a',
          to: 'b',
          cents: 5,
        ),
      ];
      final grouped = groupDebtsByCurrency(debts);
      expect(grouped.keys, containsAll(['PKR', 'USD']));
      expect(grouped['PKR']!.first.debt.amountCents, 90);
      expect(grouped['PKR']!.last.debt.amountCents, 10);
    });
  });

  group('share and expense totals', () {
    test('sumShareCents and sumExpenseCents', () {
      final now = DateTime(2026, 1, 1);
      final shares = [
        MemberExpenseShare(
          expense: Expense(
            id: 'e1',
            groupId: 'g',
            title: 'Lunch',
            amountCents: 1000,
            splitType: 'equal',
            date: now,
            createdAt: now,
          ),
          shareCents: 400,
          alsoPaid: false,
        ),
        MemberExpenseShare(
          expense: Expense(
            id: 'e2',
            groupId: 'g',
            title: 'Taxi',
            amountCents: 500,
            splitType: 'equal',
            date: now,
            createdAt: now,
          ),
          shareCents: 250,
          alsoPaid: true,
        ),
      ];
      expect(sumShareCents(shares), 650);
      expect(sumExpenseCents(shares), 1500);
    });
  });
}
