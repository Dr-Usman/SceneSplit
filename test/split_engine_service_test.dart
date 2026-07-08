import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/services/split_engine_service.dart';

void main() {
  group('SplitEngineService.equalSplit', () {
    test('distributes remainder one cent at a time', () {
      final result = SplitEngineService.equalSplit(100, ['a', 'b', 'c']);

      expect(result, {'a': 34, 'b': 33, 'c': 33});
      expect(result.values.fold(0, (a, b) => a + b), 100);
    });

    test('returns empty map for no participants', () {
      expect(SplitEngineService.equalSplit(100, []), isEmpty);
    });
  });

  group('SplitEngineService.percentageSplit', () {
    test('allocates cents and remainder by largest share', () {
      final result = SplitEngineService.percentageSplit(100, {
        'a': 33.33,
        'b': 33.33,
        'c': 33.34,
      });

      expect(result.values.fold(0, (a, b) => a + b), 100);
      expect(result['c'], greaterThanOrEqualTo(result['a']!));
    });
  });

  group('SplitEngineService validation', () {
    test('exactSplitsValid checks total', () {
      expect(
        SplitEngineService.exactSplitsValid(100, {'a': 60, 'b': 40}),
        isTrue,
      );
      expect(
        SplitEngineService.exactSplitsValid(100, {'a': 60, 'b': 39}),
        isFalse,
      );
    });

    test('percentageSplitsValid allows small floating drift', () {
      expect(
        SplitEngineService.percentageSplitsValid({'a': 50, 'b': 50}),
        isTrue,
      );
      expect(
        SplitEngineService.percentageSplitsValid({'a': 33.33, 'b': 33.33, 'c': 33.34}),
        isTrue,
      );
      expect(
        SplitEngineService.percentageSplitsValid({'a': 50, 'b': 49}),
        isFalse,
      );
    });
  });
}
