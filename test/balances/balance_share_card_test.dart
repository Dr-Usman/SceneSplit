import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/shared/widgets/balance_share_card.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('BalanceShareCard', () {
    const debts = [
      BalanceShareDebtRow(
        fromName: 'Alice',
        toName: 'Bob',
        amountCents: 1050, // $10.50
      ),
    ];

    const memberShares = [
      BalanceShareMemberRow(
        name: 'Alice',
        colorIndex: 0,
        shareCents: 1050, // $10.50
      ),
    ];

    testWidgets('formats amounts with decimals when showDecimals is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BalanceShareCard(
            groupEmoji: '🏖️',
            groupName: 'Trip',
            currencyCode: 'USD',
            locale: 'en',
            debts: debts,
            memberShares: memberShares,
            showDecimals: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debts, member shares, and total should format with decimals ($10.50)
      expect(find.text(r'$10.50'), findsNWidgets(3));
    });

    testWidgets('formats amounts without decimals when showDecimals is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const BalanceShareCard(
            groupEmoji: '🏖️',
            groupName: 'Trip',
            currencyCode: 'USD',
            locale: 'en',
            debts: debts,
            memberShares: memberShares,
            showDecimals: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When showDecimals is false, 1050 cents rounds to $11 with no decimals
      expect(find.text(r'$11'), findsNWidgets(3));
      expect(find.text(r'$10.50'), findsNothing);
    });
  });
}
