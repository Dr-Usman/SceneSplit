import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/home/home_screen.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/database_provider.dart';
import 'package:scene_split/providers/home_provider.dart';
import 'package:scene_split/shared/widgets/app_card.dart';

void main() {
  testWidgets(
    'HomeScreen group card shows only amount with symbol and no "Settled up" text when settled',
    (tester) async {
      final now = DateTime.now();
      final group = Group(
        id: 'g1',
        name: 'Weekend Trip',
        emoji: '🏖',
        currencyCode: 'USD',
        showDecimals: false,
        createdAt: now,
      );

      final homeData = HomeData(
        totalOwedToMeCents: 0,
        totalIOweCents: 0,
        groups: [
          GroupSummary(
            group: group,
            memberCount: 3,
            myNetCents: 0, // settled
            lastActivityAt: now,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeDataProvider.overrideWithValue(AsyncValue.data(homeData)),
            currencyCodeProvider.overrideWithValue(
              const AsyncValue.data('USD'),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Group name and subtitle with relative time
      expect(find.text('Weekend Trip'), findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);

      // Balance amount with symbol inside the group card
      expect(
        find.descendant(of: find.byType(AppCard), matching: find.text(r'$0')),
        findsOneWidget,
      );

      // Explicit user requirement: no "Settled up" text
      expect(find.text('Settled up'), findsNothing);
      expect(find.text('settled up'), findsNothing);
    },
  );

  testWidgets('HomeScreen group card shows "you will get" when owed', (
    tester,
  ) async {
    final now = DateTime.now();
    final group = Group(
      id: 'g2',
      name: 'Dinner',
      emoji: '🍕',
      currencyCode: 'USD',
      showDecimals: true,
      createdAt: now,
    );

    final homeData = HomeData(
      totalOwedToMeCents: 1500,
      totalIOweCents: 0,
      groups: [
        GroupSummary(
          group: group,
          memberCount: 2,
          myNetCents: 1500,
          lastActivityAt: now,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWithValue(AsyncValue.data(homeData)),
          currencyCodeProvider.overrideWithValue(const AsyncValue.data('USD')),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('you will get'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppCard), matching: find.text(r'$15')),
      findsOneWidget,
    );
  });
}
