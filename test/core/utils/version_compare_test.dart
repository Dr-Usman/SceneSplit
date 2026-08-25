import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/utils/version_compare.dart';

void main() {
  group('compareVersions', () {
    test('equal versions', () {
      expect(compareVersions('1.9.0', '1.9.0'), 0);
    });

    test('patch bump', () {
      expect(compareVersions('1.9.0', '1.9.1'), lessThan(0));
      expect(compareVersions('1.9.1', '1.9.0'), greaterThan(0));
    });

    test('minor bump with different segment lengths', () {
      expect(compareVersions('1.9', '1.10.0'), lessThan(0));
      expect(isStoreVersionNewer('1.9.0', '1.10.0'), isTrue);
      expect(isStoreVersionNewer('1.10.0', '1.9.0'), isFalse);
      expect(isStoreVersionNewer('2.0.0', '2.0.0'), isFalse);
    });
  });
}
