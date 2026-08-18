import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

void main() {
  late AppLocalizations l10n;
  const locale = 'en';
  const currency = 'USD';
  const names = {
    'alex': 'Alex',
    'sam': 'Sam',
    'jordan': 'Jordan',
    'riley': 'Riley',
  };

  final createdAt = DateTime(2026, 3, 1);

  Expense expense({
    required String id,
    required String title,
    required DateTime date,
    required int amountCents,
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

  ExpenseWithSplits dinner() {
    return ExpenseWithSplits(
      expense: expense(
        id: 'e1',
        title: 'Dinner',
        date: DateTime(2026, 3, 3, 19, 30),
        amountCents: 4200,
      ),
      payers: [payer(expenseId: 'e1', userId: 'alex', amountCents: 4200)],
      splits: [
        split(expenseId: 'e1', userId: 'alex', amountCents: 1050),
        split(expenseId: 'e1', userId: 'sam', amountCents: 1050),
        split(expenseId: 'e1', userId: 'jordan', amountCents: 1050),
        split(expenseId: 'e1', userId: 'riley', amountCents: 1050),
      ],
    );
  }

  ExpenseWithSplits groceries() {
    return ExpenseWithSplits(
      expense: expense(
        id: 'e2',
        title: 'Groceries',
        date: DateTime(2026, 3, 5),
        amountCents: 4200,
      ),
      payers: [
        payer(expenseId: 'e2', userId: 'alex', amountCents: 3000),
        payer(expenseId: 'e2', userId: 'sam', amountCents: 1200),
      ],
      splits: [
        split(expenseId: 'e2', userId: 'alex', amountCents: 1400),
        split(expenseId: 'e2', userId: 'sam', amountCents: 1400),
        split(expenseId: 'e2', userId: 'jordan', amountCents: 1400),
        split(expenseId: 'e2', userId: 'riley', amountCents: 0),
      ],
    );
  }

  setUpAll(() async {
    await initializeDateFormatting('en');
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('date-only range', () {
    test('isDateInInclusiveRange ignores time of day', () {
      final start = DateTime(2026, 3, 1);
      final end = DateTime(2026, 3, 15);
      expect(
        isDateInInclusiveRange(DateTime(2026, 3, 1, 23, 59), start, end),
        isTrue,
      );
      expect(
        isDateInInclusiveRange(DateTime(2026, 3, 15, 0, 1), start, end),
        isTrue,
      );
      expect(
        isDateInInclusiveRange(DateTime(2026, 2, 28, 23, 59), start, end),
        isFalse,
      );
      expect(
        isDateInInclusiveRange(DateTime(2026, 3, 16), start, end),
        isFalse,
      );
    });

    test('this month is the 1st through today', () {
      final range = thisMonthRange(DateTime(2026, 3, 18, 16, 0));
      expect(range.start, DateTime(2026, 3, 1));
      expect(range.end, DateTime(2026, 3, 18));
    });

    test('last 7 days is today inclusive (6 days back)', () {
      final range = last7DaysRange(DateTime(2026, 3, 18, 9));
      expect(range.start, DateTime(2026, 3, 12));
      expect(range.end, DateTime(2026, 3, 18));
    });

    test('last 7 days crosses month boundary', () {
      final range = last7DaysRange(DateTime(2026, 3, 3));
      expect(range.start, DateTime(2026, 2, 25));
      expect(range.end, DateTime(2026, 3, 3));
    });

    test('resolveExpenseShareRange maps presets', () {
      final now = DateTime(2026, 8, 18);
      expect(
        resolveExpenseShareRange(ExpenseShareRangePreset.all, now: now),
        isNull,
      );
      expect(
        resolveExpenseShareRange(ExpenseShareRangePreset.month, now: now),
        DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 18)),
      );
      expect(
        resolveExpenseShareRange(ExpenseShareRangePreset.last7, now: now),
        DateTimeRange(start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 18)),
      );
      final custom = DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      expect(
        resolveExpenseShareRange(
          ExpenseShareRangePreset.custom,
          now: now,
          custom: custom,
        ),
        custom,
      );
    });

    test('filterExpensesByDateRange is inclusive and keeps order', () {
      final items = [
        dinner(),
        groceries(),
        ExpenseWithSplits(
          expense: expense(
            id: 'e3',
            title: 'Taxi',
            date: DateTime(2026, 2, 28),
            amountCents: 100,
          ),
          payers: [payer(expenseId: 'e3', userId: 'alex', amountCents: 100)],
          splits: [split(expenseId: 'e3', userId: 'alex', amountCents: 100)],
        ),
      ];
      final filtered = filterExpensesByDateRange(
        items,
        DateTimeRange(start: DateTime(2026, 3, 3), end: DateTime(2026, 3, 5)),
      );
      expect(filtered.map((e) => e.expense.title), ['Dinner', 'Groceries']);
    });

    test('null range keeps all expenses', () {
      final items = [dinner(), groceries()];
      expect(filterExpensesByDateRange(items, null).map((e) => e.expense.id), [
        'e1',
        'e2',
      ]);
    });
  });

  group('range labels', () {
    test('all dates uses All dates copy', () {
      expect(
        formatExpenseShareRangeLabel(null, l10n: l10n, locale: locale),
        'All dates',
      );
    });

    test('single day is one formatted date', () {
      final label = formatExpenseShareRangeLabel(
        DateTimeRange(start: DateTime(2026, 3, 3), end: DateTime(2026, 3, 3)),
        l10n: l10n,
        locale: locale,
      );
      expect(label, contains('Mar'));
      expect(label, contains('3'));
      expect(label.contains('–'), isFalse);
    });

    test('span uses start and end', () {
      final label = formatExpenseShareRangeLabel(
        DateTimeRange(start: DateTime(2026, 3, 1), end: DateTime(2026, 3, 15)),
        l10n: l10n,
        locale: locale,
      );
      expect(label, contains('Mar'));
      expect(label, contains('1'));
      expect(label, contains('15'));
      expect(label, contains('–'));
    });
  });

  group('image content', () {
    test('compact rows omit per-person amounts and count people', () {
      final content = buildExpenseShareImageContent(
        [dinner(), groceries()],
        userNames: names,
        l10n: l10n,
        currencyCode: currency,
        locale: locale,
      );
      expect(content.rows, hasLength(2));
      expect(content.overflowCount, 0);
      expect(content.totalCents, 8400);
      expect(content.rows.first.title, 'Dinner');
      expect(content.rows.first.subtitle, contains('Alex paid'));
      expect(content.rows.first.subtitle, contains('4 people'));
      expect(content.rows.first.subtitle.contains(r'$10.50'), isFalse);
      expect(content.rows[1].subtitle, contains('Alex & Sam'));
      expect(content.rows[1].subtitle, contains('3 people'));
    });

    test('caps at 30 rows and reports overflow; total includes all', () {
      final many = [
        for (var i = 0; i < 35; i++)
          ExpenseWithSplits(
            expense: expense(
              id: 'e$i',
              title: 'Item $i',
              date: DateTime(2026, 3, 1).add(Duration(days: i)),
              amountCents: 100,
            ),
            payers: [payer(expenseId: 'e$i', userId: 'alex', amountCents: 100)],
            splits: [split(expenseId: 'e$i', userId: 'alex', amountCents: 100)],
          ),
      ];
      final content = buildExpenseShareImageContent(
        many,
        userNames: names,
        l10n: l10n,
        currencyCode: currency,
        locale: locale,
      );
      expect(content.rows, hasLength(30));
      expect(content.overflowCount, 5);
      expect(content.totalCents, 3500);
    });
  });

  group('member totals', () {
    test('sums shares in expense order and sorts by total', () {
      final rows = buildExpenseShareMemberTotals([
        dinner(),
        groceries(),
      ], userNames: names);
      expect(rows.map((r) => r.name), ['Alex', 'Jordan', 'Sam', 'Riley']);
      expect(rows.first.partsCents, [1050, 1400]);
      expect(rows.first.totalCents, 2450);
      expect(rows.last.name, 'Riley');
      expect(rows.last.partsCents, [1050]);
      expect(rows.last.totalCents, 1050);
    });

    test('formats addition line without currency symbols', () {
      final row = ExpenseShareMemberTotal(
        name: 'Alex',
        partsCents: [65000, 20000, 18000, 17000],
        totalCents: 120000,
      );
      expect(
        formatExpenseShareMemberTotalLine(row, l10n: l10n, locale: locale),
        'Alex: 650 + 200 + 180 + 170 = 1,200',
      );
    });
  });

  group('text body', () {
    test('includes payer amounts and member shares', () {
      final range = DateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 15),
      );
      final text = buildExpenseShareText(
        [dinner(), groceries()],
        groupName: 'Weekend trip',
        rangeLabel: formatExpenseShareRangeLabel(
          range,
          l10n: l10n,
          locale: locale,
        ),
        userNames: names,
        l10n: l10n,
        currencyCode: currency,
        locale: locale,
      );

      expect(text, startsWith('Weekend trip\n'));
      expect(text, contains('2 expenses'));
      expect(text, contains('Dinner'));
      expect(text, contains('Alex paid'));
      expect(text, contains(r'$42'));
      expect(
        text,
        contains(r'Alex $10.50 · Sam $10.50 · Jordan $10.50 · Riley $10.50'),
      );
      expect(text, contains('Groceries'));
      expect(text, contains(r'Alex $30 & Sam $12 paid'));
      expect(text, contains(r'Alex $14 · Sam $14 · Jordan $14'));
      expect(text, contains('By person'));
      expect(text, contains('Alex: 10.50 + 14 = 24.50'));
      expect(text, contains('Sam: 10.50 + 14 = 24.50'));
      expect(text, contains('Jordan: 10.50 + 14 = 24.50'));
      expect(text, contains('Riley: 10.50'));
      expect(text, contains(r'Total: $84'));
    });
  });
}
