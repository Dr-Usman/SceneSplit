import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/person_detail_provider.dart';
import 'package:scene_split/services/balance_service.dart';

void main() {
  final now = DateTime(2026, 8, 7);

  Group group({
    required String id,
    required String name,
    required String currencyCode,
  }) {
    return Group(
      id: id,
      name: name,
      emoji: '🏕',
      currencyCode: currencyCode,
      createdAt: now,
    );
  }

  GroupMember member({
    required String groupId,
    required String userId,
    String id = 'm',
  }) {
    return GroupMember(id: id, groupId: groupId, userId: userId, joinedAt: now);
  }

  test('filterDebtsForPerson keeps only edges involving the person', () {
    const debts = [
      PairwiseDebt(fromUserId: 'a', toUserId: 'b', amountCents: 100),
      PairwiseDebt(fromUserId: 'c', toUserId: 'd', amountCents: 200),
      PairwiseDebt(fromUserId: 'b', toUserId: 'a', amountCents: 50),
      PairwiseDebt(fromUserId: 'e', toUserId: 'a', amountCents: 75),
    ];

    final forA = filterDebtsForPerson(debts, 'a');
    expect(forA.map((d) => d.amountCents).toList(), [100, 50, 75]);

    final forZ = filterDebtsForPerson(debts, 'z');
    expect(forZ, isEmpty);
  });

  test('groupsForPerson returns only memberships, sorted by name', () {
    final groups = [
      group(id: 'g2', name: 'Zurich', currencyCode: 'CHF'),
      group(id: 'g1', name: 'Berlin', currencyCode: 'EUR'),
      group(id: 'g3', name: 'Murree', currencyCode: 'PKR'),
    ];
    final members = [
      member(id: 'm1', groupId: 'g1', userId: 'alice'),
      member(id: 'm2', groupId: 'g3', userId: 'alice'),
      member(id: 'm3', groupId: 'g2', userId: 'bob'),
    ];

    final aliceGroups = groupsForPerson(
      personId: 'alice',
      groups: groups,
      members: members,
    );

    expect(aliceGroups.map((g) => g.id).toList(), ['g1', 'g3']);
    expect(aliceGroups.map((g) => g.currencyCode).toList(), ['EUR', 'PKR']);
  });

  test('groupsForPerson returns empty when person has no memberships', () {
    final result = groupsForPerson(
      personId: 'nobody',
      groups: [group(id: 'g1', name: 'Trip', currencyCode: 'USD')],
      members: [member(groupId: 'g1', userId: 'alice')],
    );
    expect(result, isEmpty);
  });

  test('PersonGroupBalance.hasOpenBalance reflects net and debts', () {
    final settled = PersonGroupBalance(
      group: group(id: 'g1', name: 'Trip', currencyCode: 'USD'),
      members: const [],
      netCents: 0,
      debts: const [],
      totalShareCents: 0,
      expenseShares: const [],
    );
    expect(settled.hasOpenBalance, isFalse);

    final withDebt = PersonGroupBalance(
      group: group(id: 'g1', name: 'Trip', currencyCode: 'USD'),
      members: const [],
      netCents: 0,
      debts: const [
        PairwiseDebt(fromUserId: 'a', toUserId: 'b', amountCents: 10),
      ],
      totalShareCents: 0,
      expenseShares: const [],
    );
    expect(withDebt.hasOpenBalance, isTrue);

    final withNet = PersonGroupBalance(
      group: group(id: 'g1', name: 'Trip', currencyCode: 'EUR'),
      members: const [],
      netCents: -500,
      debts: const [],
      totalShareCents: 0,
      expenseShares: const [],
    );
    expect(withNet.hasOpenBalance, isTrue);
  });

  test('two scenes keep separate currencies on PersonDetailData', () {
    final data = PersonDetailData(
      user: User(
        id: 'alice',
        name: 'Alice',
        colorIndex: 0,
        isCurrentUser: false,
        createdAt: now,
      ),
      groups: [
        PersonGroupBalance(
          group: group(id: 'g1', name: 'Berlin', currencyCode: 'EUR'),
          members: const [],
          netCents: -3200,
          debts: const [
            PairwiseDebt(
              fromUserId: 'alice',
              toUserId: 'you',
              amountCents: 3200,
            ),
          ],
          totalShareCents: 5000,
          expenseShares: const [],
        ),
        PersonGroupBalance(
          group: group(id: 'g2', name: 'Murree', currencyCode: 'PKR'),
          members: const [],
          netCents: 450000,
          debts: const [
            PairwiseDebt(
              fromUserId: 'you',
              toUserId: 'alice',
              amountCents: 450000,
            ),
          ],
          totalShareCents: 100000,
          expenseShares: const [],
        ),
      ],
    );

    expect(data.sceneCount, 2);
    expect(data.hasAnyOpenBalance, isTrue);
    expect(data.groups[0].group.currencyCode, 'EUR');
    expect(data.groups[1].group.currencyCode, 'PKR');
    // No merged total — callers must format per group.
    expect(data.groups.map((g) => g.netCents).toList(), [-3200, 450000]);
  });

  test('summarizePersonCurrencyTotals sums same currency across scenes', () {
    final data = PersonDetailData(
      user: User(
        id: 'alice',
        name: 'Alice',
        colorIndex: 0,
        isCurrentUser: false,
        createdAt: now,
      ),
      groups: [
        PersonGroupBalance(
          group: group(id: 'g1', name: 'Dinner', currencyCode: 'USD'),
          members: const [],
          netCents: -1000,
          debts: const [
            PairwiseDebt(
              fromUserId: 'alice',
              toUserId: 'bob',
              amountCents: 1000,
            ),
          ],
          totalShareCents: 0,
          expenseShares: const [],
        ),
        PersonGroupBalance(
          group: group(id: 'g2', name: 'Trip', currencyCode: 'USD'),
          members: const [],
          netCents: 400,
          debts: const [
            PairwiseDebt(
              fromUserId: 'bob',
              toUserId: 'alice',
              amountCents: 400,
            ),
            PairwiseDebt(
              fromUserId: 'alice',
              toUserId: 'cara',
              amountCents: 200,
            ),
          ],
          totalShareCents: 0,
          expenseShares: const [],
        ),
      ],
    );

    final totals = summarizePersonCurrencyTotals(data);
    expect(totals, hasLength(1));
    expect(totals.single.currencyCode, 'USD');
    expect(totals.single.willGiveCents, 1200);
    expect(totals.single.getsCents, 400);
    expect(data.currencyTotals.single.willGiveCents, 1200);
    expect(data.currencyTotals.single.getsCents, 400);
  });

  test('summarizePersonCurrencyTotals keeps currencies separate', () {
    final data = PersonDetailData(
      user: User(
        id: 'alice',
        name: 'Alice',
        colorIndex: 0,
        isCurrentUser: false,
        createdAt: now,
      ),
      groups: [
        PersonGroupBalance(
          group: group(id: 'g1', name: 'Berlin', currencyCode: 'EUR'),
          members: const [],
          netCents: -3200,
          debts: const [
            PairwiseDebt(
              fromUserId: 'alice',
              toUserId: 'you',
              amountCents: 3200,
            ),
          ],
          totalShareCents: 0,
          expenseShares: const [],
        ),
        PersonGroupBalance(
          group: group(id: 'g2', name: 'Murree', currencyCode: 'PKR'),
          members: const [],
          netCents: 450000,
          debts: const [
            PairwiseDebt(
              fromUserId: 'you',
              toUserId: 'alice',
              amountCents: 450000,
            ),
          ],
          totalShareCents: 0,
          expenseShares: const [],
        ),
      ],
    );

    final totals = summarizePersonCurrencyTotals(data);
    expect(totals.map((t) => t.currencyCode).toList(), ['EUR', 'PKR']);
    expect(totals[0].willGiveCents, 3200);
    expect(totals[0].getsCents, 0);
    expect(totals[1].willGiveCents, 0);
    expect(totals[1].getsCents, 450000);
  });

  test('summarizePersonCurrencyTotals omits zero sides and settled scenes', () {
    final settled = PersonDetailData(
      user: User(
        id: 'alice',
        name: 'Alice',
        colorIndex: 0,
        isCurrentUser: false,
        createdAt: now,
      ),
      groups: [
        PersonGroupBalance(
          group: group(id: 'g1', name: 'Trip', currencyCode: 'USD'),
          members: const [],
          netCents: 0,
          debts: const [],
          totalShareCents: 0,
          expenseShares: const [],
        ),
      ],
    );
    expect(summarizePersonCurrencyTotals(settled), isEmpty);

    final onlyGets = PersonDetailData(
      user: User(
        id: 'alice',
        name: 'Alice',
        colorIndex: 0,
        isCurrentUser: false,
        createdAt: now,
      ),
      groups: [
        PersonGroupBalance(
          group: group(id: 'g1', name: 'Trip', currencyCode: 'USD'),
          members: const [],
          netCents: 500,
          debts: const [
            PairwiseDebt(
              fromUserId: 'bob',
              toUserId: 'alice',
              amountCents: 500,
            ),
          ],
          totalShareCents: 0,
          expenseShares: const [],
        ),
      ],
    );
    final totals = summarizePersonCurrencyTotals(onlyGets);
    expect(totals, hasLength(1));
    expect(totals.single.willGiveCents, 0);
    expect(totals.single.getsCents, 500);
  });
}
