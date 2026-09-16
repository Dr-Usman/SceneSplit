import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/shared/widgets/balance_hero_card.dart';

void main() {
  Widget buildCard({
    required int netCents,
    required String currencyCode,
    bool showDecimals = true,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: BalanceHeroCard(
          netCents: netCents,
          currencyCode: currencyCode,
          showDecimals: showDecimals,
        ),
      ),
    );
  }

  testWidgets(
    'BalanceHeroCard shows checkmark, All settled label, and \$0 when settled',
    (tester) async {
      await tester.pumpWidget(
        buildCard(netCents: 0, currencyCode: 'USD', showDecimals: false),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('All settled'), findsOneWidget);
      expect(find.text(r'$0'), findsOneWidget);
    },
  );

  testWidgets('BalanceHeroCard shows positive balance correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildCard(netCents: 2550, currencyCode: 'USD', showDecimals: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('You get'), findsOneWidget);
    expect(find.text(r'$25.50'), findsOneWidget);
  });

  testWidgets('BalanceHeroCard shows negative balance correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildCard(netCents: -1200, currencyCode: 'USD', showDecimals: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('You give'), findsOneWidget);
    expect(find.text(r'$12'), findsOneWidget);
  });
}
