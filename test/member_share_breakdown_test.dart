import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

void main() {
  final createdAt = DateTime(2026, 3, 1);

  Expense expense({
    required String id,
    required String title,
    required DateTime date,
    int amountCents = 100,
  }) {
    return Expense(
      id: id,
      groupId: 'g1',
      title: title,
      amountCents: amountCents,
      splitType: 'equal',
      date: date,
      createdAt: createdAt,
    );
  }

  ExpensePayer payer({
    required String expenseId,
    required String userId,
    required int amountCents,
  }) {
    return ExpensePayer(
      id: 'p-$expenseId-$userId',
      expenseId: expenseId,
      userId: userId,
      amountCents: amountCents,
    );
  }

  ExpenseSplit split({
    required String expenseId,
    required String userId,
    required int amountCents,
  }) {
    return ExpenseSplit(
      id: 's-$expenseId-$userId',
      expenseId: expenseId,
      userId: userId,
      amountCents: amountCents,
    );
  }

  group('buildMemberShareBreakdown', () {
    test('aggregates share totals and per-expense rows per member', () {
      final dinner = expense(
        id: 'e1',
        title: 'Dinner',
        date: DateTime(2026, 3, 3),
        amountCents: 100,
      );
      final hotel = expense(
        id: 'e2',
        title: 'Hotel',
        date: DateTime(2026, 3, 1),
        amountCents: 200,
      );

      final breakdown = buildMemberShareBreakdown([
        ExpenseWithSplits(
          expense: dinner,
          payers: [payer(expenseId: 'e1', userId: 'alice', amountCents: 100)],
          splits: [
            split(expenseId: 'e1', userId: 'alice', amountCents: 50),
            split(expenseId: 'e1', userId: 'bob', amountCents: 50),
          ],
        ),
        ExpenseWithSplits(
          expense: hotel,
          payers: [payer(expenseId: 'e2', userId: 'bob', amountCents: 200)],
          splits: [
            split(expenseId: 'e2', userId: 'alice', amountCents: 100),
            split(expenseId: 'e2', userId: 'bob', amountCents: 100),
          ],
        ),
      ]);

      expect(breakdown.shareCents['alice'], 150);
      expect(breakdown.shareCents['bob'], 150);

      final aliceRows = breakdown.expenseShares['alice']!;
      expect(aliceRows.map((r) => r.expense.id), ['e1', 'e2']);
      expect(aliceRows.map((r) => r.shareCents), [50, 100]);
      expect(aliceRows[0].alsoPaid, isTrue);
      expect(aliceRows[1].alsoPaid, isFalse);

      final bobRows = breakdown.expenseShares['bob']!;
      expect(bobRows.map((r) => r.expense.id), ['e1', 'e2']);
      expect(bobRows[1].alsoPaid, isTrue);
    });

    test('sorts each member list by expense date descending', () {
      final older = expense(
        id: 'old',
        title: 'Old',
        date: DateTime(2026, 1, 1),
      );
      final newer = expense(
        id: 'new',
        title: 'New',
        date: DateTime(2026, 2, 1),
      );

      // Intentionally pass older first so sort must reorder.
      final breakdown = buildMemberShareBreakdown([
        ExpenseWithSplits(
          expense: older,
          payers: [payer(expenseId: 'old', userId: 'alice', amountCents: 40)],
          splits: [split(expenseId: 'old', userId: 'alice', amountCents: 40)],
        ),
        ExpenseWithSplits(
          expense: newer,
          payers: [payer(expenseId: 'new', userId: 'alice', amountCents: 60)],
          splits: [split(expenseId: 'new', userId: 'alice', amountCents: 60)],
        ),
      ]);

      expect(breakdown.expenseShares['alice']!.map((r) => r.expense.id), [
        'new',
        'old',
      ]);
    });

    test('skips zero-amount splits and members with no positive share', () {
      final e = expense(
        id: 'e1',
        title: 'Solo',
        date: DateTime(2026, 3, 1),
        amountCents: 50,
      );

      final breakdown = buildMemberShareBreakdown([
        ExpenseWithSplits(
          expense: e,
          payers: [payer(expenseId: 'e1', userId: 'alice', amountCents: 50)],
          splits: [
            split(expenseId: 'e1', userId: 'alice', amountCents: 50),
            split(expenseId: 'e1', userId: 'bob', amountCents: 0),
          ],
        ),
      ]);

      expect(breakdown.shareCents.keys, ['alice']);
      expect(breakdown.expenseShares.containsKey('bob'), isFalse);
    });
  });
}
