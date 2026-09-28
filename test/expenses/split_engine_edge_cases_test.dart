import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/services/split_engine_service.dart';

void main() {
  group('SplitEngineService Edge Cases', () {
    test(
      'equalSplit with 1 cent across 3 people gives 1 cent to first person',
      () {
        final res = SplitEngineService.equalSplit(1, ['u1', 'u2', 'u3']);
        expect(res, {'u1': 1, 'u2': 0, 'u3': 0});
        expect(res.values.fold(0, (a, b) => a + b), 1);
      },
    );

    test(
      'equalSplit with 2 cents across 3 people distributes 1 cent to first two people',
      () {
        final res = SplitEngineService.equalSplit(2, ['u1', 'u2', 'u3']);
        expect(res, {'u1': 1, 'u2': 1, 'u3': 0});
        expect(res.values.fold(0, (a, b) => a + b), 2);
      },
    );

    test(
      'equalSplit with \$1.00 (100 cents) across 3 people distributes remainder 1 cent to first person',
      () {
        final res = SplitEngineService.equalSplit(100, ['u1', 'u2', 'u3']);
        expect(res, {'u1': 34, 'u2': 33, 'u3': 33});
        expect(res.values.fold(0, (a, b) => a + b), 100);
      },
    );

    test(
      'equalSplit with 1,000,000 cents across 7 people preserves every single cent',
      () {
        final members = List.generate(7, (i) => 'user-$i');
        final res = SplitEngineService.equalSplit(1000000, members);

        final totalAssigned = res.values.fold(0, (a, b) => a + b);
        expect(totalAssigned, 1000000);

        // Base: 1000000 ~/ 7 = 142857. Remainder: 1000000 - (142857 * 7) = 1.
        expect(res['user-0'], 142858);
        for (var i = 1; i < 7; i++) {
          expect(res['user-$i'], 142857);
        }
      },
    );

    test('equalSplit with empty member list returns empty map', () {
      expect(SplitEngineService.equalSplit(5000, []), isEmpty);
    });

    test('equalSplit with 0 cents total assigns 0 to all members', () {
      final res = SplitEngineService.equalSplit(0, ['u1', 'u2']);
      expect(res, {'u1': 0, 'u2': 0});
    });

    test(
      'percentageSplit rounds correctly and awards remainder to largest percentage',
      () {
        // Total $10.00 (1000 cents), 70% to u1 (700 cents), 30% to u2 (300 cents)
        final res = SplitEngineService.percentageSplit(1000, {
          'u1': 70.0,
          'u2': 30.0,
        });
        expect(res, {'u1': 700, 'u2': 300});
        expect(res.values.fold(0, (a, b) => a + b), 1000);
      },
    );

    test(
      'percentageSplit with 33.33% / 33.33% / 33.34% across \$10.00 preserves 1000 cents',
      () {
        final res = SplitEngineService.percentageSplit(1000, {
          'u1': 33.33,
          'u2': 33.33,
          'u3': 33.34,
        });
        final total = res.values.fold(0, (a, b) => a + b);
        expect(total, 1000);
      },
    );

    test('percentageSplitsWithinLimits rejects percentages <= 0 or > 100', () {
      expect(
        SplitEngineService.percentageSplitsWithinLimits({
          'u1': 50.0,
          'u2': 50.0,
        }),
        isTrue,
      );
      expect(
        SplitEngineService.percentageSplitsWithinLimits({
          'u1': 0.0,
          'u2': 100.0,
        }),
        isFalse,
      );
      expect(
        SplitEngineService.percentageSplitsWithinLimits({
          'u1': -10.0,
          'u2': 110.0,
        }),
        isFalse,
      );
      expect(
        SplitEngineService.percentageSplitsWithinLimits({'u1': 105.0}),
        isFalse,
      );
      expect(SplitEngineService.percentageSplitsWithinLimits({}), isFalse);
    });

    test('exactSplitsValid verifies exact sum matching', () {
      expect(
        SplitEngineService.exactSplitsValid(5000, {'u1': 3000, 'u2': 2000}),
        isTrue,
      );
      expect(
        SplitEngineService.exactSplitsValid(5000, {'u1': 3000, 'u2': 1999}),
        isFalse,
      );
      expect(
        SplitEngineService.exactSplitsValid(5000, {'u1': 3000, 'u2': 2001}),
        isFalse,
      );
    });
  });
}
