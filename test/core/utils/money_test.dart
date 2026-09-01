import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/constants/currencies.dart';
import 'package:scene_split/core/utils/money.dart';

void main() {
  group('defaultDecimalsForCurrency', () {
    test('returns false for zero/low decimal currencies', () {
      expect(defaultDecimalsForCurrency('PKR'), isFalse);
      expect(defaultDecimalsForCurrency('INR'), isFalse);
      expect(defaultDecimalsForCurrency('JPY'), isFalse);
      expect(defaultDecimalsForCurrency('KRW'), isFalse);
      expect(defaultDecimalsForCurrency('VND'), isFalse);
      expect(defaultDecimalsForCurrency('IDR'), isFalse);
      expect(defaultDecimalsForCurrency('HUF'), isFalse);
    });

    test('returns true for standard decimal currencies', () {
      expect(defaultDecimalsForCurrency('USD'), isTrue);
      expect(defaultDecimalsForCurrency('EUR'), isTrue);
      expect(defaultDecimalsForCurrency('GBP'), isTrue);
      expect(defaultDecimalsForCurrency('AED'), isTrue);
      expect(defaultDecimalsForCurrency('SAR'), isTrue);
      expect(defaultDecimalsForCurrency('CAD'), isTrue);
      expect(defaultDecimalsForCurrency('AUD'), isTrue);
    });
  });

  group('formatCents with showDecimals', () {
    test(
      'formats whole numbers without decimals when showDecimals is false',
      () {
        final formatted = formatCents(150000, 'PKR', showDecimals: false);
        expect(formatted, contains('1,500'));
        expect(formatted, isNot(contains('.00')));
      },
    );

    test(
      'rounds fractional amounts to nearest whole when showDecimals is false',
      () {
        // 1500.33 PKR (150033 cents) -> 1,500
        final roundedDown = formatCents(150033, 'PKR', showDecimals: false);
        expect(roundedDown, contains('1,500'));
        expect(roundedDown, isNot(contains('.')));

        // 1500.67 PKR (150067 cents) -> 1,501
        final roundedUp = formatCents(150067, 'PKR', showDecimals: false);
        expect(roundedUp, contains('1,501'));
        expect(roundedUp, isNot(contains('.')));
      },
    );

    test(
      'preserves decimals on non-whole amounts when showDecimals is true',
      () {
        final fractional = formatCents(1250, 'USD', showDecimals: true);
        expect(fractional, contains('12.50'));

        final threeWaySplit = formatCents(333, 'USD', showDecimals: true);
        expect(threeWaySplit, contains('3.33'));
      },
    );

    test(
      'hides .00 on whole numbers when showDecimals is true (auto mode)',
      () {
        final whole = formatCents(1000, 'USD', showDecimals: true);
        expect(whole, contains('10'));
        expect(whole, isNot(contains('.00')));
      },
    );
  });
}
