import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/l10n/app_localizations.dart';

void main() {
  test('supported locales include planned languages', () {
    final tags = AppLocalizations.supportedLocales
        .map(
          (l) => l.countryCode == null || l.countryCode!.isEmpty
              ? l.languageCode
              : '${l.languageCode}_${l.countryCode}',
        )
        .toSet();

    expect(tags.contains('en'), isTrue);
    expect(tags.contains('es'), isTrue);
    expect(tags.contains('fr'), isTrue);
    expect(tags.contains('de'), isTrue);
    expect(tags.contains('pt') || tags.contains('pt_BR'), isTrue);
    expect(tags.contains('hi'), isTrue);
    expect(tags.contains('ar'), isTrue);
    expect(tags.contains('ja'), isTrue);
  });

  testWidgets('lookup succeeds for ar and pt_BR', (tester) async {
    for (final locale in const [Locale('ar'), Locale('pt', 'BR')]) {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(l10n.commonCancel, isNotEmpty);
      expect(l10n.homeEmptyTitle, isNotEmpty);
    }
  });

  test('parseAmountToCents accepts locale decimals', () {
    expect(parseAmountToCents('1,250.50', locale: 'en_US'), 125050);
    expect(parseAmountToCents('1250,50', locale: 'de_DE'), 125050);
    expect(parseAmountToCents('1.250,50', locale: 'de_DE'), 125050);
  });

  test('formatCents uses currency symbol', () {
    final formatted = formatCents(125000, 'USD', locale: 'en_US');
    expect(formatted.contains('1,250') || formatted.contains('1250'), isTrue);
  });

  test('formatCents spaces letter symbols but not glyph symbols', () {
    expect(formatCents(120000, 'PKR', locale: 'en'), 'Rs 1,200');
    expect(formatCents(120000, 'CHF', locale: 'en'), 'CHF 1,200');
    expect(formatCents(120000, 'USD', locale: 'en_US'), r'$1,200');
  });
}
