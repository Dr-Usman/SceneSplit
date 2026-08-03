import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel product analytics. Typed methods below are the full event catalog.
class AnalyticsService {
  /// Override at build time: `flutter run --dart-define=MIXPANEL_TOKEN=…`
  static const _projectToken = String.fromEnvironment(
    'MIXPANEL_TOKEN',
    defaultValue: 'e79f32f48d8644b9c1060b9330282a38',
  );

  Mixpanel? _mixpanel;
  String? _identifiedUserId;
  Future<void>? _initFuture;

  /// Platform label for event properties (`ios`, `android`, `web`, …).
  static String platformLabel() {
    if (kIsWeb) return 'web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }

  /// Eager init so the first track/identify does not pay cold-start cost alone.
  Future<void> init() => _ensureInitialized();

  bool _appOpenedTracked = false;

  /// Once per process cold start — useful for DAU.
  Future<void> trackAppOpened() async {
    if (_appOpenedTracked) return;
    _appOpenedTracked = true;
    await _track('app_opened', properties: {'platform': platformLabel()});
  }

  /// Links Mixpanel’s distinct id to the local user UUID and sets People props.
  Future<void> identifyUser(
    String userId, {
    String? name,
    String? currencyCode,
    String? localeCode,
  }) async {
    _identifiedUserId = userId;
    await _ensureInitialized();
    final mp = _mixpanel;
    if (mp == null) return;
    await mp.identify(userId);
    final people = mp.getPeople();
    if (name != null && name.isNotEmpty) {
      people.set(r'$name', name);
    }
    if (currencyCode != null) {
      people.set('currency_code', currencyCode);
    }
    if (localeCode != null) {
      await setLocaleCode(localeCode);
    }
  }

  /// Persists language on the user profile and as a super property.
  Future<void> setLocaleCode(String localeCode) async {
    await _ensureInitialized();
    final mp = _mixpanel;
    if (mp == null) return;
    mp.getPeople().set('locale_code', localeCode);
    await mp.registerSuperProperties({'locale_code': localeCode});
  }

  /// Fired when the user explicitly changes language in Profile.
  Future<void> trackLanguageChanged({
    required String localeCode,
    String? previousLocaleCode,
  }) async {
    await setLocaleCode(localeCode);
    await _track(
      'language_changed',
      properties: {
        'locale_code': localeCode,
        'previous_locale_code': ?previousLocaleCode,
      },
    );
  }

  /// Fired after local onboarding creates the device user.
  Future<void> trackSignUpCompleted({
    required String userId,
    required String name,
    required String defaultCurrency,
  }) async {
    await _track(
      'sign_up_completed',
      properties: {
        'user_id': userId,
        'name': name,
        'sign_up_method': 'local',
        'platform': platformLabel(),
        'default_currency': defaultCurrency,
      },
    );
  }

  /// Fired after a group is created.
  Future<void> trackGroupCreated({
    required String groupId,
    required String groupName,
    required String currencyCode,
    required int memberCount,
  }) async {
    await _track(
      'group_created',
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'currency_code': currencyCode,
        'member_count': memberCount,
      },
    );
  }

  /// Fired after a new expense is saved (not on edit).
  Future<void> trackExpenseCreated({
    required String groupId,
    required String groupName,
    required String splitType,
    required String paidByMode,
    required int amountCents,
    required int memberCount,
  }) async {
    await _track(
      'expense_created',
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'split_type': splitType,
        'paid_by_mode': paidByMode,
        'amount_cents': amountCents,
        'member_count': memberCount,
      },
    );
  }

  Future<void> _track(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await _ensureInitialized();
    final mp = _mixpanel;
    if (mp == null) return;
    await mp.track(eventName, properties: properties);
  }

  Future<void> _ensureInitialized() async {
    if (_mixpanel != null) return;
    final token = _projectToken.trim();
    if (token.isEmpty) return;

    _initFuture ??= () async {
      final mp = await Mixpanel.init(token, trackAutomaticEvents: true);
      await mp.registerSuperProperties({'platform': platformLabel()});
      _mixpanel = mp;

      final pendingId = _identifiedUserId;
      if (pendingId != null) {
        await mp.identify(pendingId);
      }
    }();

    try {
      await _initFuture;
    } catch (_) {
      _initFuture = null;
      rethrow;
    }
  }
}
