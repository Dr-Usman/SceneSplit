import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/analytics_service.dart';
import 'database_provider.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = AnalyticsService();
  // Fire-and-forget cold-start open; callers still await via track/identify.
  () async {
    await analytics.init();
    await analytics.trackAppOpened();
  }();
  return analytics;
});

/// Keeps Mixpanel identity + locale in sync with local settings / current user.
final analyticsBootstrapProvider = Provider<void>((ref) {
  final analytics = ref.watch(analyticsServiceProvider);

  ref.listen<AsyncValue<User?>>(currentUserProvider, (previous, next) {
    next.whenData((user) {
      if (user == null) return;
      final localeCode = ref.read(localeCodeProvider).value ?? 'system';
      analytics.identifyUser(user.id, name: user.name, localeCode: localeCode);
    });
  }, fireImmediately: true);

  ref.listen<AsyncValue<String>>(localeCodeProvider, (previous, next) {
    next.whenData((localeCode) {
      // Profile updates (no event) — language_changed is fired from the picker.
      analytics.setLocaleCode(localeCode);
    });
  }, fireImmediately: true);
});
