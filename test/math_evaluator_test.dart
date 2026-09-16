import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/utils/math_evaluator.dart';

void main() {
  group('MathEvaluator', () {
    test('evaluates simple operations', () {
      expect(MathEvaluator.evaluate('10 + 5').value, 15);
      expect(MathEvaluator.evaluate('10 - 4').value, 6);
      expect(MathEvaluator.evaluate('10 * 3').value, 30);
      expect(MathEvaluator.evaluate('10 × 3').value, 30);
      expect(MathEvaluator.evaluate('15 / 3').value, 5);
      expect(MathEvaluator.evaluate('15 ÷ 3').value, 5);
    });

    test('evaluates operator precedence correctly', () {
      expect(MathEvaluator.evaluate('2 + 3 * 4').value, 14);
      expect(MathEvaluator.evaluate('10 - 6 / 2').value, 7);
      expect(MathEvaluator.evaluate('20 - 4 × 2 + 10 ÷ 2').value, 17);
    });

    test('evaluates parentheses', () {
      expect(MathEvaluator.evaluate('(2 + 3) * 4').value, 20);
      expect(MathEvaluator.evaluate('((10 + 5) * 2) / 3').value, 10);
    });

    test('evaluates decimals properly', () {
      expect(MathEvaluator.evaluate('10.5 + 4.25').value, 14.75);
      expect(MathEvaluator.evaluate('0.1 + 0.2').value, closeTo(0.3, 0.0001));
    });

    test('handles division by zero', () {
      final res = MathEvaluator.evaluate('10 / 0');
      expect(res.isSuccess, isFalse);
      expect(res.isDivisionByZero, isTrue);
    });

    test('handles live preview sanitization of trailing operators', () {
      expect(MathEvaluator.evaluate('25 + ', sanitizeTrailing: true).value, 25);
      expect(
        MathEvaluator.evaluate('25 + 15 × ', sanitizeTrailing: true).value,
        40,
      );
      expect(
        MathEvaluator.evaluate('(10 + 5', sanitizeTrailing: true).value,
        15,
      );
      expect(
        MathEvaluator.evaluate('10 + (2 × 3', sanitizeTrailing: true).value,
        16,
      );
    });

    test('handles empty or blank string', () {
      expect(MathEvaluator.evaluate('').value, 0);
      expect(MathEvaluator.evaluate('   ').value, 0);
    });

    test('formatAmount formats decimal and non-decimal values cleanly', () {
      expect(MathEvaluator.formatAmount(50.0), '50');
      expect(MathEvaluator.formatAmount(50.5), '50.5');
      expect(MathEvaluator.formatAmount(50.25), '50.25');
      expect(MathEvaluator.formatAmount(50.258), '50.26');
      expect(MathEvaluator.formatAmount(50.5, showDecimals: false), '51');
      expect(MathEvaluator.formatAmount(50.2, showDecimals: false), '50');
    });
  });
}
