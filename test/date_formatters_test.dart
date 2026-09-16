import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scene_split/core/utils/date_formatters.dart';
import 'package:scene_split/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await initializeDateFormatting('en');
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('formatRelativeActivityTime', () {
    // 2026-09-16 is a Wednesday
    final baseNow = DateTime(2026, 9, 16, 14, 30, 0);

    test('returns Just now for current or future times within 1 minute', () {
      expect(
        formatRelativeActivityTime(
          baseNow.subtract(const Duration(seconds: 30)),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Just now',
      );
      expect(
        formatRelativeActivityTime(
          baseNow.add(const Duration(seconds: 10)),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Just now',
      );
    });

    test('returns Today with time for earlier activities today', () {
      expect(
        formatRelativeActivityTime(
          DateTime(2026, 9, 16, 10, 15),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Today, 10:15 AM',
      );
    });

    test('returns Yesterday with time for yesterday activities', () {
      expect(
        formatRelativeActivityTime(
          DateTime(2026, 9, 15, 16, 45),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Yesterday, 4:45 PM',
      );
    });

    test('returns day of week with time for dates within the past 6 days', () {
      // Sep 13, 2026 is Sunday
      expect(
        formatRelativeActivityTime(
          DateTime(2026, 9, 13, 11, 20),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Sun, 11:20 AM',
      );
    });

    test(
      'returns day of week with month and day for older dates in current year',
      () {
        // Jul 20, 2026 is Monday
        expect(
          formatRelativeActivityTime(
            DateTime(2026, 7, 20, 9, 0),
            now: baseNow,
            locale: 'en',
            l10n: l10n,
          ),
          'Mon, Jul 20',
        );
      },
    );

    test('returns day of week, date, and year for older years', () {
      // Nov 20, 2025 is Thursday
      expect(
        formatRelativeActivityTime(
          DateTime(2025, 11, 20, 10, 0),
          now: baseNow,
          locale: 'en',
          l10n: l10n,
        ),
        'Thu, Nov 20, 2025',
      );
    });
  });
}
