import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/group_detail_provider.dart';
import 'package:scene_split/services/balance_service.dart';

void main() {
  const currencyCode = 'USD';
  const locale = 'en';

  Expense makeExpense({
    required String id,
    required String title,
    required DateTime date,
    required int amountCents,
    String? note,
  }) {
    return Expense(
      id: id,
      groupId: 'g1',
      title: title,
      amountCents: amountCents,
      splitType: 'equal',
      date: date,
      note: note,
      createdAt: date,
    );
  }

  Settlement makeSettlement({
    required String id,
    required String fromUserId,
    required String toUserId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) {
    return Settlement(
      id: id,
      groupId: 'g1',
      fromUserId: fromUserId,
      toUserId: toUserId,
      amountCents: amountCents,
      date: date,
      note: note,
      createdAt: date,
    );
  }

  // Mirrors the exact filtering logic from GroupReportScreen
  bool matchesExpenseSearch(
    String query,
    ExpenseWithSplits item, {
    required String currencyCode,
    required String locale,
    bool showDecimals = true,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final title = item.expense.title.toLowerCase();
    if (title.contains(q)) return true;
    final note = item.expense.note?.toLowerCase();
    if (note != null && note.contains(q)) return true;

    final amountCents = item.expense.amountCents;
    if (amountCents.toString().contains(q)) return true;
    final plainAmount = (amountCents / 100.0).toString();
    if (plainAmount.contains(q)) return true;
    final plainFixed = (amountCents / 100.0).toStringAsFixed(2);
    if (plainFixed.contains(q)) return true;
    final formatted = formatCents(
      amountCents,
      currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    ).toLowerCase();
    if (formatted.contains(q)) return true;

    return false;
  }

  bool matchesSettlementSearch(
    String query,
    Settlement settlement, {
    required String currencyCode,
    required String locale,
    bool showDecimals = true,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final note = settlement.note?.toLowerCase();
    if (note != null && note.contains(q)) return true;

    final amountCents = settlement.amountCents;
    if (amountCents.toString().contains(q)) return true;
    final plainAmount = (amountCents / 100.0).toString();
    if (plainAmount.contains(q)) return true;
    final plainFixed = (amountCents / 100.0).toStringAsFixed(2);
    if (plainFixed.contains(q)) return true;
    final formatted = formatCents(
      amountCents,
      currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    ).toLowerCase();
    if (formatted.contains(q)) return true;

    return false;
  }

  group('Group Report: Search Filtering Edge Cases', () {
    final item = ExpenseWithSplits(
      expense: makeExpense(
        id: 'e1',
        title: 'Fancy Sushi Dinner',
        date: DateTime(2026, 3, 10, 19, 30),
        amountCents: 12550, // $125.50
        note: 'Celebrated Alice birthday at downtown bistro',
      ),
      payers: [
        const ExpensePayer(
          id: 'p1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 12550,
        ),
      ],
      splits: [
        const ExpenseSplit(
          id: 's1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 6275,
        ),
        const ExpenseSplit(
          id: 's2',
          expenseId: 'e1',
          userId: 'u2',
          amountCents: 6275,
        ),
      ],
    );

    final settlement = makeSettlement(
      id: 'st1',
      fromUserId: 'u2',
      toUserId: 'u1',
      amountCents: 5000, // $50.00
      date: DateTime(2026, 3, 11, 14, 0),
      note: 'Partial payback via Revolut',
    );

    test('empty or whitespace query matches everything', () {
      expect(
        matchesExpenseSearch(
          '',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          '   ',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesSettlementSearch(
          '',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
    });

    test('case-insensitive title matching', () {
      expect(
        matchesExpenseSearch(
          'sushi',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          'FANCY',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          'Dinner',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          'burger',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isFalse,
      );
    });

    test('note matching for expenses and settlements', () {
      expect(
        matchesExpenseSearch(
          'birthday',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          'downtown',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesSettlementSearch(
          'revolut',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesSettlementSearch(
          'cash',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isFalse,
      );
    });

    test('amount matching by cents, decimal, and formatted currency', () {
      // Matches '125.5' or '125.50'
      expect(
        matchesExpenseSearch(
          '125.5',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesExpenseSearch(
          '125.50',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      // Matches integer cents string '12550'
      expect(
        matchesExpenseSearch(
          '12550',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      // Matches currency symbol '$125.50'
      expect(
        matchesExpenseSearch(
          '\$125.50',
          item,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );

      // Settlement $50.00
      expect(
        matchesSettlementSearch(
          '50',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesSettlementSearch(
          '50.00',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
      expect(
        matchesSettlementSearch(
          '\$50',
          settlement,
          currencyCode: currencyCode,
          locale: locale,
        ),
        isTrue,
      );
    });
  });

  group('Group Report: Member Involvement Filtering Edge Cases', () {
    final multiPayerExpense = ExpenseWithSplits(
      expense: makeExpense(
        id: 'e2',
        title: 'Airbnb',
        date: DateTime(2026, 3, 15),
        amountCents: 30000,
      ),
      payers: [
        const ExpensePayer(
          id: 'p1',
          expenseId: 'e2',
          userId: 'alice',
          amountCents: 20000,
        ),
        const ExpensePayer(
          id: 'p2',
          expenseId: 'e2',
          userId: 'bob',
          amountCents: 10000,
        ),
      ],
      splits: [
        const ExpenseSplit(
          id: 's1',
          expenseId: 'e2',
          userId: 'alice',
          amountCents: 10000,
        ),
        const ExpenseSplit(
          id: 's2',
          expenseId: 'e2',
          userId: 'bob',
          amountCents: 10000,
        ),
        const ExpenseSplit(
          id: 's3',
          expenseId: 'e2',
          userId: 'charlie',
          amountCents: 10000,
        ),
        const ExpenseSplit(
          id: 's4',
          expenseId: 'e2',
          userId: 'david',
          amountCents: 0,
        ), // 0 share
      ],
    );

    final settlement = makeSettlement(
      id: 'st2',
      fromUserId: 'charlie',
      toUserId: 'alice',
      amountCents: 10000,
      date: DateTime(2026, 3, 16),
    );

    bool isMemberInvolvedInExpense(ExpenseWithSplits exp, String? memberId) {
      if (memberId == null) return true;
      final isPayer = exp.payers.any((p) => p.userId == memberId);
      final isSplitter = exp.splits.any(
        (s) => s.userId == memberId && s.amountCents > 0,
      );
      return isPayer || isSplitter;
    }

    bool isMemberInvolvedInSettlement(Settlement st, String? memberId) {
      if (memberId == null) return true;
      return st.fromUserId == memberId || st.toUserId == memberId;
    }

    test('all members (null ID) includes all transactions', () {
      expect(isMemberInvolvedInExpense(multiPayerExpense, null), isTrue);
      expect(isMemberInvolvedInSettlement(settlement, null), isTrue);
    });

    test('member who paid is included in expense', () {
      expect(isMemberInvolvedInExpense(multiPayerExpense, 'alice'), isTrue);
      expect(isMemberInvolvedInExpense(multiPayerExpense, 'bob'), isTrue);
    });

    test(
      'member with positive split is included in expense even if not payer',
      () {
        expect(isMemberInvolvedInExpense(multiPayerExpense, 'charlie'), isTrue);
      },
    );

    test('member with zero share and zero paid is NOT included in expense', () {
      expect(isMemberInvolvedInExpense(multiPayerExpense, 'david'), isFalse);
    });

    test('unrelated member is NOT included', () {
      expect(isMemberInvolvedInExpense(multiPayerExpense, 'eve'), isFalse);
      expect(isMemberInvolvedInSettlement(settlement, 'eve'), isFalse);
    });

    test(
      'settlement payer and receiver are included, third parties are not',
      () {
        expect(isMemberInvolvedInSettlement(settlement, 'charlie'), isTrue);
        expect(isMemberInvolvedInSettlement(settlement, 'alice'), isTrue);
        expect(isMemberInvolvedInSettlement(settlement, 'bob'), isFalse);
      },
    );
  });

  group('Group Report: Sorting Edge Cases', () {
    final eEarly = ExpenseWithSplits(
      expense: makeExpense(
        id: 'e1',
        title: 'Breakfast',
        date: DateTime(2026, 3, 1, 8, 0),
        amountCents: 1500,
      ),
      payers: const [],
      splits: const [],
    );
    final eMid = ExpenseWithSplits(
      expense: makeExpense(
        id: 'e2',
        title: 'Lunch',
        date: DateTime(2026, 3, 1, 13, 0),
        amountCents: 2500,
      ),
      payers: const [],
      splits: const [],
    );
    final eLate = ExpenseWithSplits(
      expense: makeExpense(
        id: 'e3',
        title: 'Dinner',
        date: DateTime(2026, 3, 5, 20, 0),
        amountCents: 4500,
      ),
      payers: const [],
      splits: const [],
    );

    test('date descending puts newest first', () {
      final list = [eMid, eEarly, eLate];
      list.sort((a, b) => b.expense.date.compareTo(a.expense.date));
      expect(list.map((e) => e.expense.id).toList(), ['e3', 'e2', 'e1']);
    });

    test('date ascending puts oldest first', () {
      final list = [eMid, eEarly, eLate];
      list.sort((a, b) => a.expense.date.compareTo(b.expense.date));
      expect(list.map((e) => e.expense.id).toList(), ['e1', 'e2', 'e3']);
    });

    test('settlement sorting by date ascending and descending', () {
      final s1 = makeSettlement(
        id: 's1',
        fromUserId: 'u1',
        toUserId: 'u2',
        amountCents: 10,
        date: DateTime(2026, 3, 1),
      );
      final s2 = makeSettlement(
        id: 's2',
        fromUserId: 'u1',
        toUserId: 'u2',
        amountCents: 20,
        date: DateTime(2026, 3, 4),
      );

      final desc = [s1, s2]..sort((a, b) => b.date.compareTo(a.date));
      expect(desc.first.id, 's2');

      final asc = [s1, s2]..sort((a, b) => a.date.compareTo(b.date));
      expect(asc.first.id, 's1');
    });
  });

  group('Group Report: Pagination Calculation Edge Cases', () {
    test('initial limit is 10 and step is 15', () {
      const initialLimit = 10;
      const step = 15;
      const totalItems = 32;

      // Page 1
      var limit = initialLimit;
      var displayedCount = totalItems > limit ? limit : totalItems;
      var remaining = totalItems - displayedCount;
      expect(displayedCount, 10);
      expect(remaining, 22);

      // Load More 1
      limit += step; // 25
      displayedCount = totalItems > limit ? limit : totalItems;
      remaining = totalItems - displayedCount;
      expect(displayedCount, 25);
      expect(remaining, 7);

      // Load More 2
      limit += step; // 40
      displayedCount = totalItems > limit ? limit : totalItems;
      remaining = totalItems - displayedCount;
      expect(displayedCount, 32);
      expect(remaining, 0);
    });

    test('no load more button when items <= initial limit', () {
      const initialLimit = 10;
      const totalItems = 7;
      final displayedCount = totalItems > initialLimit
          ? initialLimit
          : totalItems;
      final remaining = totalItems - displayedCount;
      expect(displayedCount, 7);
      expect(remaining, 0);
    });
  });

  group('Group Report: Date Range Boundaries Edge Cases', () {
    test(
      'single-day range includes timestamps from 00:00 to 23:59:59 on that day',
      () {
        final day = DateTime(2026, 3, 15);
        final range = DateTimeRange(start: day, end: day);

        expect(
          isDateInInclusiveRange(
            DateTime(2026, 3, 15, 0, 0, 0),
            range.start,
            range.end,
          ),
          isTrue,
        );
        expect(
          isDateInInclusiveRange(
            DateTime(2026, 3, 15, 12, 30, 0),
            range.start,
            range.end,
          ),
          isTrue,
        );
        expect(
          isDateInInclusiveRange(
            DateTime(2026, 3, 15, 23, 59, 59),
            range.start,
            range.end,
          ),
          isTrue,
        );

        // 1 minute before or after
        expect(
          isDateInInclusiveRange(
            DateTime(2026, 3, 14, 23, 59, 59),
            range.start,
            range.end,
          ),
          isFalse,
        );
        expect(
          isDateInInclusiveRange(
            DateTime(2026, 3, 16, 0, 0, 1),
            range.start,
            range.end,
          ),
          isFalse,
        );
      },
    );
  });

  group('Group Report: Text Sharing', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      await initializeDateFormatting('en');
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('buildGroupReportShareText formats full report correctly', () {
      final text = buildGroupReportShareText(
        groupEmoji: '✈️',
        groupName: 'Tokyo Trip',
        rangeLabel: 'All time',
        totalSpendCents: 245000,
        totalSettledCents: 45000,
        openDebtCents: 20000,
        debts: const [
          OpenDebt(fromUserId: 'u2', toUserId: 'u1', amountCents: 20000),
        ],
        memberSummaries: const [
          GroupPeriodMemberSummary(
            userId: 'u1',
            name: 'Alice',
            paidCents: 180000,
            shareCents: 85000,
            netCents: 95000,
          ),
          GroupPeriodMemberSummary(
            userId: 'u2',
            name: 'Bob',
            paidCents: 65000,
            shareCents: 160000,
            netCents: -95000,
          ),
        ],
        expenses: [
          ExpenseWithSplits(
            expense: makeExpense(
              id: 'e1',
              title: 'Hotel',
              date: DateTime(2026, 9, 25),
              amountCents: 120000,
              note: 'Booking ref #123',
            ),
            splits: const [],
            payers: const [
              ExpensePayer(
                id: 'p1',
                expenseId: 'e1',
                userId: 'u1',
                amountCents: 120000,
              ),
            ],
          ),
        ],
        settlements: [
          makeSettlement(
            id: 's1',
            fromUserId: 'u2',
            toUserId: 'u1',
            amountCents: 45000,
            date: DateTime(2026, 9, 26),
          ),
        ],
        userNames: const {'u1': 'Alice', 'u2': 'Bob'},
        l10n: l10n,
        currencyCode: currencyCode,
        locale: locale,
      );

      expect(text, contains('✈️ Tokyo Trip'));
      expect(text, contains('All time · 1 expense · 1 settlement'));
      expect(text, contains('TOTALS'));
      expect(text, contains('\$2,450'));
      expect(text, contains('\$450'));
      expect(text, contains('\$200 (Pending)'));
      expect(text, contains('WHO OWES WHOM'));
      expect(text, contains('Bob owes Alice: \$200'));
      expect(text, contains('MEMBER BREAKDOWN'));
      expect(text, contains('Alice: Paid \$1,800 | Share \$850 | Net: +\$950'));
      expect(text, contains('Bob: Paid \$650 | Share \$1,600 | Net: -\$950'));
      expect(text, contains('Hotel: \$1,200'));
      expect(text, contains('Note: Booking ref #123'));
      expect(text, contains('Bob paid Alice: \$450'));
      expect(text, contains('Shared via SceneSplit'));
    });

    test('buildGroupReportShareText handles settled state cleanly', () {
      final text = buildGroupReportShareText(
        groupEmoji: '🏠',
        groupName: 'Flat',
        rangeLabel: 'This month',
        totalSpendCents: 10000,
        totalSettledCents: 10000,
        openDebtCents: 0,
        debts: const [],
        memberSummaries: const [],
        expenses: const [],
        settlements: const [],
        userNames: const {},
        l10n: l10n,
        currencyCode: currencyCode,
        locale: locale,
      );

      expect(text, contains('Settled'));
      expect(text, contains('\$0'));
    });
  });
}
