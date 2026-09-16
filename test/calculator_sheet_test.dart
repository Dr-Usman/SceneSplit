import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/shared/widgets/calculator_sheet.dart';

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
    home: Scaffold(body: child),
  );
}

void main() {
  group('CalculatorSheet', () {
    testWidgets('renders calculator keys and performs calculation', (
      tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        _wrapWithApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showCalculatorSheet(
                  context,
                  currencyCode: 'USD',
                  initialValue: '',
                  showDecimals: true,
                );
              },
              child: const Text('Open Calculator'),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Calculator'));
      await tester.pumpAndSettle();

      // Verify calculator is shown
      expect(find.text('Calculator'), findsOneWidget);

      // Tap 2, 5, +, 1, 5
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // Live preview should show = $ 40
      expect(find.text('= \$ 40'), findsOneWidget);

      // Tap Apply
      await tester.tap(find.text('Apply \$ 40'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed and result returned
      expect(result, '40');
    });

    testWidgets('prefills existing amount and allows continuing calculation', (
      tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        _wrapWithApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showCalculatorSheet(
                  context,
                  currencyCode: 'USD',
                  initialValue: '50',
                  showDecimals: true,
                );
              },
              child: const Text('Open Calculator'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Calculator'));
      await tester.pumpAndSettle();

      // Expression should have 50 and preview = $ 50
      expect(find.text('= \$ 50'), findsOneWidget);

      // Tap +, 2, 5
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(find.text('= \$ 75'), findsOneWidget);

      await tester.tap(find.text('Apply \$ 75'));
      await tester.pumpAndSettle();

      expect(result, '75');
    });

    testWidgets('handles division by zero properly', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await showCalculatorSheet(
                  context,
                  currencyCode: 'USD',
                  initialValue: '',
                  showDecimals: true,
                );
              },
              child: const Text('Open Calculator'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Calculator'));
      await tester.pumpAndSettle();

      // Tap 1, 0, ÷, 0, =
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('÷'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      expect(find.text('Cannot divide by 0'), findsOneWidget);
    });
  });
}
