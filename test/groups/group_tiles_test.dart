import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/groups/reports/widgets/compact_expense_tile.dart';
import 'package:scene_split/features/groups/reports/widgets/compact_settlement_tile.dart';
import 'package:scene_split/features/groups/widgets/group_expense_tile.dart';
import 'package:scene_split/features/groups/widgets/group_settlement_tile.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

Widget wrapTile(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  final user1 = User(
    id: 'u1',
    name: 'Alice',
    colorIndex: 0,
    createdAt: DateTime.now(),
    isCurrentUser: true,
  );
  final user2 = User(
    id: 'u2',
    name: 'Bob',
    colorIndex: 1,
    createdAt: DateTime.now(),
    isCurrentUser: false,
  );
  final userMap = {'u1': user1, 'u2': user2};

  group('GroupSettlementTile', () {
    testWidgets('displays weekday along with date (MMMEd format)', (
      tester,
    ) async {
      // 2026-09-25 was a Friday
      final settlementDate = DateTime(2026, 9, 25);
      final settlement = Settlement(
        id: 's1',
        groupId: 'g1',
        fromUserId: 'u1',
        toUserId: 'u2',
        amountCents: 5000,
        date: settlementDate,
        createdAt: settlementDate,
      );

      await tester.pumpWidget(
        wrapTile(
          GroupSettlementTile(
            settlement: settlement,
            users: userMap,
            currencyCode: 'USD',
            locale: 'en',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedDateStr = DateFormat.MMMEd('en').format(settlementDate);
      expect(expectedDateStr, contains('Fri'));
      expect(find.text(expectedDateStr), findsOneWidget);
      expect(find.text('Alice paid Bob'), findsOneWidget);
      expect(find.text(r'$50'), findsOneWidget);
    });

    testWidgets('displays weekday and date with note if note is present', (
      tester,
    ) async {
      final settlementDate = DateTime(2026, 9, 25);
      final settlement = Settlement(
        id: 's1',
        groupId: 'g1',
        fromUserId: 'u2',
        toUserId: 'u1',
        amountCents: 2500,
        note: 'Cab share',
        date: settlementDate,
        createdAt: settlementDate,
      );

      await tester.pumpWidget(
        wrapTile(
          GroupSettlementTile(
            settlement: settlement,
            users: userMap,
            currencyCode: 'USD',
            locale: 'en',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedDateStr = DateFormat.MMMEd('en').format(settlementDate);
      expect(find.text('$expectedDateStr · Cab share'), findsOneWidget);
    });
  });

  group('CompactSettlementTile', () {
    testWidgets('displays weekday along with date', (tester) async {
      final settlementDate = DateTime(2026, 9, 25);
      final settlement = Settlement(
        id: 's2',
        groupId: 'g1',
        fromUserId: 'u1',
        toUserId: 'u2',
        amountCents: 1500,
        date: settlementDate,
        createdAt: settlementDate,
      );

      await tester.pumpWidget(
        wrapTile(
          CompactSettlementTile(
            settlement: settlement,
            users: userMap,
            currencyCode: 'USD',
            locale: 'en',
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final expectedDateStr = DateFormat.MMMEd('en').format(settlementDate);
      expect(find.text(expectedDateStr), findsOneWidget);
    });
  });

  group('GroupExpenseTile', () {
    testWidgets('displays single row title/price and subtitle with weekday', (
      tester,
    ) async {
      final expenseDate = DateTime(2026, 9, 25);
      final expense = Expense(
        id: 'e1',
        groupId: 'g1',
        title: 'Dinner with team',
        amountCents: 12000,
        date: expenseDate,
        splitType: 'equal',
        createdAt: expenseDate,
      );
      final payers = [
        ExpensePayer(
          id: 'p1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 12000,
        ),
      ];
      final splits = [
        ExpenseSplit(
          id: 's1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 6000,
        ),
        ExpenseSplit(
          id: 's2',
          expenseId: 'e1',
          userId: 'u2',
          amountCents: 6000,
        ),
      ];

      final item = ExpenseWithSplits(
        expense: expense,
        payers: payers,
        splits: splits,
      );

      await tester.pumpWidget(
        wrapTile(
          GroupExpenseTile(
            item: item,
            users: userMap,
            currencyCode: 'USD',
            locale: 'en',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dinner with team'), findsOneWidget);
      expect(find.text(r'$120'), findsOneWidget);

      final dateStr = DateFormat.MMMEd('en').format(expenseDate);
      expect(
        find.text('$dateStr · Alice paid · 2 people · Equal'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notes_outlined), findsNothing);
    });

    testWidgets('displays note row with icon when note is present', (
      tester,
    ) async {
      final expenseDate = DateTime(2026, 9, 25);
      final expense = Expense(
        id: 'e1',
        groupId: 'g1',
        title: 'Team dinner',
        amountCents: 9000,
        note: 'Steakhouse dinner celebration',
        date: expenseDate,
        splitType: 'equal',
        createdAt: expenseDate,
      );
      final payers = [
        ExpensePayer(
          id: 'p1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 9000,
        ),
      ];
      final splits = [
        ExpenseSplit(
          id: 's1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 4500,
        ),
        ExpenseSplit(
          id: 's2',
          expenseId: 'e1',
          userId: 'u2',
          amountCents: 4500,
        ),
      ];

      final item = ExpenseWithSplits(
        expense: expense,
        payers: payers,
        splits: splits,
      );

      await tester.pumpWidget(
        wrapTile(
          GroupExpenseTile(
            item: item,
            users: userMap,
            currencyCode: 'USD',
            locale: 'en',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Team dinner'), findsOneWidget);
      expect(find.text(r'$90'), findsOneWidget);
      expect(find.text('Steakhouse dinner celebration'), findsOneWidget);
      expect(find.byIcon(Icons.notes_outlined), findsOneWidget);
    });
  });

  group('CompactExpenseTile', () {
    testWidgets(
      'displays single row title/price and full width subtitle without chevron',
      (tester) async {
        final expenseDate = DateTime(2026, 9, 25);
        final expense = Expense(
          id: 'e2',
          groupId: 'g1',
          title: 'Lunch meeting',
          amountCents: 4500,
          date: expenseDate,
          splitType: 'equal',
          createdAt: expenseDate,
        );
        final payers = [
          ExpensePayer(
            id: 'p2',
            expenseId: 'e2',
            userId: 'u1',
            amountCents: 4500,
          ),
        ];
        final splits = [
          ExpenseSplit(
            id: 's3',
            expenseId: 'e2',
            userId: 'u1',
            amountCents: 2250,
          ),
          ExpenseSplit(
            id: 's4',
            expenseId: 'e2',
            userId: 'u2',
            amountCents: 2250,
          ),
        ];

        final item = ExpenseWithSplits(
          expense: expense,
          payers: payers,
          splits: splits,
        );

        await tester.pumpWidget(
          wrapTile(
            CompactExpenseTile(
              item: item,
              users: userMap,
              currencyCode: 'USD',
              locale: 'en',
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Lunch meeting'), findsOneWidget);
        expect(find.text(r'$45'), findsOneWidget);

        final dateStr = DateFormat.MMMEd('en').format(expenseDate);
        expect(
          find.text('$dateStr · Alice paid · 2 people · Equal'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      },
    );
  });
}
