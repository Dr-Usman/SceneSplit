import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/expenses/expense_detail_screen.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/data_providers.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

void main() {
  testWidgets(
    'ExpenseDetailScreen shows per-expense net impact and who-owes-whom section',
    (tester) async {
      final now = DateTime(2026, 11, 7);
      final zohaib = User(
        id: 'u1',
        name: 'Zohaib',
        colorIndex: 0,
        createdAt: now,
        isCurrentUser: false,
      );
      final usman = User(
        id: 'u2',
        name: 'Usman Shahbaz',
        colorIndex: 1,
        createdAt: now,
        isCurrentUser: true,
      );

      final group = Group(
        id: 'g1',
        name: 'Foodies',
        emoji: '🍗',
        currencyCode: 'PKR',
        showDecimals: false,
        createdAt: now,
      );

      final expense = Expense(
        id: 'e1',
        groupId: 'g1',
        title: 'Saudi Broast+ Sweet Cream',
        amountCents: 273000, // Rs 2,730
        splitType: 'equal',
        date: now,
        createdAt: now,
      );

      final payers = [
        ExpensePayer(
          id: 'p1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 214000, // Rs 2,140
        ),
        ExpensePayer(
          id: 'p2',
          expenseId: 'e1',
          userId: 'u2',
          amountCents: 59000, // Rs 590
        ),
      ];

      final splits = [
        ExpenseSplit(
          id: 's1',
          expenseId: 'e1',
          userId: 'u1',
          amountCents: 136500, // Rs 1,365
        ),
        ExpenseSplit(
          id: 's2',
          expenseId: 'e1',
          userId: 'u2',
          amountCents: 136500, // Rs 1,365
        ),
      ];

      final item = ExpenseWithSplits(
        expense: expense,
        payers: payers,
        splits: splits,
      );

      final groupData = GroupDetailData(
        group: group,
        members: [GroupMemberInfo(zohaib), GroupMemberInfo(usman)],
        expenses: [item],
        settlements: const [],
        debts: const [],
        myNetCents: -77500,
        memberShareCents: const {},
        memberExpenseShares: const {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupDetailProvider(
              'g1',
            ).overrideWithValue(AsyncValue.data(groupData)),
            userByIdProvider.overrideWithValue({'u1': zohaib, 'u2': usman}),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: ExpenseDetailScreen(
              groupId: 'g1',
              expenseId: 'e1',
              currencyCode: 'PKR',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Share icon in AppBar
      final shareButton = find.byIcon(Icons.share_outlined);
      expect(shareButton, findsOneWidget);

      // Title and expense amount
      expect(find.text('Saudi Broast+ Sweet Cream'), findsOneWidget);
      expect(find.text('Rs 2,730'), findsOneWidget);

      // Paid By section
      expect(find.text('PAID BY'), findsOneWidget);
      expect(find.text('Rs 2,140'), findsOneWidget);
      expect(find.text('Rs 590'), findsOneWidget);

      // Split Breakdown section with Option A net impact
      expect(find.text('SPLIT BREAKDOWN'), findsOneWidget);
      expect(find.text('Rs 1,365'), findsNWidgets(2));
      expect(find.text('gets back Rs 775'), findsOneWidget);
      expect(find.text('owes Rs 775'), findsOneWidget);

      // Who owes whom (for this expense) section
      await tester.scrollUntilVisible(
        find.text('WHO OWES WHOM (FOR THIS EXPENSE)'),
        100,
      );
      expect(find.text('WHO OWES WHOM (FOR THIS EXPENSE)'), findsOneWidget);
      expect(
        find.text(
          'Calculated for this expense only. Group balance reflects all expenses.',
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Usman Shahbaz owes Zohaib'),
        100,
      );
      expect(find.text('Usman Shahbaz owes Zohaib'), findsOneWidget);
      expect(
        find.text('Rs 775'),
        findsOneWidget,
      ); // Standalone amount in OpenDebtTile

      // Tap share button to open format picker sheet
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      expect(find.text('How to share'), findsOneWidget);
      expect(find.text('Image'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
    },
  );

  testWidgets(
    'ExpenseDetailScreen hides who-owes-whom section when fully settled/balanced',
    (tester) async {
      final now = DateTime(2026, 11, 7);
      final zohaib = User(
        id: 'u1',
        name: 'Zohaib',
        colorIndex: 0,
        createdAt: now,
        isCurrentUser: true,
      );

      final group = Group(
        id: 'g1',
        name: 'Solo Expense',
        emoji: '☕️',
        currencyCode: 'PKR',
        showDecimals: false,
        createdAt: now,
      );

      final expense = Expense(
        id: 'e2',
        groupId: 'g1',
        title: 'Coffee',
        amountCents: 50000, // Rs 500
        splitType: 'equal',
        date: now,
        createdAt: now,
      );

      final item = ExpenseWithSplits(
        expense: expense,
        payers: [
          ExpensePayer(
            id: 'p1',
            expenseId: 'e2',
            userId: 'u1',
            amountCents: 50000,
          ),
        ],
        splits: [
          ExpenseSplit(
            id: 's1',
            expenseId: 'e2',
            userId: 'u1',
            amountCents: 50000,
          ),
        ],
      );

      final groupData = GroupDetailData(
        group: group,
        members: [GroupMemberInfo(zohaib)],
        expenses: [item],
        settlements: const [],
        debts: const [],
        myNetCents: 0,
        memberShareCents: const {},
        memberExpenseShares: const {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupDetailProvider(
              'g1',
            ).overrideWithValue(AsyncValue.data(groupData)),
            userByIdProvider.overrideWithValue({'u1': zohaib}),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: ExpenseDetailScreen(
              groupId: 'g1',
              expenseId: 'e2',
              currencyCode: 'PKR',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('settled'), findsOneWidget);
      expect(find.text('WHO OWES WHOM (FOR THIS EXPENSE)'), findsNothing);
    },
  );
}
