import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Canonical Mixpanel event names used by [AnalyticsService].
///
/// Add new product events here first, then wire a typed `track*` method below.
abstract final class AnalyticsEvents {
  static const appOpened = 'app_opened';
  static const signUpCompleted = 'sign_up_completed';
  static const groupCreated = 'group_created';
  static const expenseCreated = 'expense_created';
  static const languageChanged = 'language_changed';
  static const balanceShared = 'balance_shared';
  static const settlementCreated = 'settlement_created';
  static const tabSelected = 'tab_selected';
  static const balancesPairOpened = 'balances_pair_opened';
  static const personDetailOpened = 'person_detail_opened';
  static const balancesFilterApplied = 'balances_filter_applied';
  static const balancesFilterCleared = 'balances_filter_cleared';
  static const appShared = 'app_shared';
  static const reviewPrompted = 'review_prompted';
  static const backupExported = 'backup_exported';
  static const backupImported = 'backup_imported';

  /// Full integrated catalog (order matches product funnel, then feature areas).
  static const List<String> all = [
    appOpened,
    signUpCompleted,
    groupCreated,
    expenseCreated,
    languageChanged,
    balanceShared,
    settlementCreated,
    tabSelected,
    balancesPairOpened,
    personDetailOpened,
    balancesFilterApplied,
    balancesFilterCleared,
    appShared,
    reviewPrompted,
    backupExported,
    backupImported,
  ];
}

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
    await _track(
      AnalyticsEvents.appOpened,
      properties: {'platform': platformLabel()},
    );
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
      AnalyticsEvents.languageChanged,
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
      AnalyticsEvents.signUpCompleted,
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
      AnalyticsEvents.groupCreated,
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
      AnalyticsEvents.expenseCreated,
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

  /// Fired after the user successfully opens the share sheet for balances.
  Future<void> trackBalanceShared({
    required int debtCount,
    required int memberShareCount,
  }) async {
    await _track(
      AnalyticsEvents.balanceShared,
      properties: {
        'debt_count': debtCount,
        'member_share_count': memberShareCount,
        'platform': platformLabel(),
      },
    );
  }

  /// Fired after a new settlement is saved (not on edit).
  ///
  /// [source] is one of `scene_detail`, `balances_pair`, `person_detail`.
  Future<void> trackSettlementCreated({
    required String groupId,
    required int amountCents,
    required String currencyCode,
    required String source,
    required bool hadPrefill,
  }) async {
    await _track(
      AnalyticsEvents.settlementCreated,
      properties: {
        'group_id': groupId,
        'amount_cents': amountCents,
        'currency_code': currencyCode,
        'source': source,
        'had_prefill': hadPrefill,
      },
    );
  }

  /// Fired when the user selects a bottom-nav tab (skips no-op same-index).
  ///
  /// [tab] is one of `scenes`, `balances`, `profile`.
  Future<void> trackTabSelected({required String tab}) async {
    await _track(AnalyticsEvents.tabSelected, properties: {'tab': tab});
  }

  /// Fired when a person-pair is opened from the Balances tab.
  Future<void> trackBalancesPairOpened({
    required bool hasWhoFilter,
    required bool hasWhomFilter,
    required int currencyCount,
  }) async {
    await _track(
      AnalyticsEvents.balancesPairOpened,
      properties: {
        'has_who_filter': hasWhoFilter,
        'has_whom_filter': hasWhomFilter,
        'currency_count': currencyCount,
      },
    );
  }

  /// Fired once when Person detail loads successfully.
  Future<void> trackPersonDetailOpened({
    required int openDebtCount,
    required int sceneCount,
    required bool isSelf,
  }) async {
    await _track(
      AnalyticsEvents.personDetailOpened,
      properties: {
        'open_debt_count': openDebtCount,
        'scene_count': sceneCount,
        'is_self': isSelf,
      },
    );
  }

  /// Fired when Balances filter sheet applies Who/Whom results.
  Future<void> trackBalancesFilterApplied({
    required bool whoSet,
    required bool whomSet,
    required bool whomIsYou,
  }) async {
    await _track(
      AnalyticsEvents.balancesFilterApplied,
      properties: {
        'who_set': whoSet,
        'whom_set': whomSet,
        'whom_is_you': whomIsYou,
      },
    );
  }

  /// Fired when Balances filters are cleared.
  Future<void> trackBalancesFilterCleared() async {
    await _track(AnalyticsEvents.balancesFilterCleared);
  }

  /// Fired after the system share sheet opens for “Share app”.
  Future<void> trackAppShared() async {
    await _track(
      AnalyticsEvents.appShared,
      properties: {'platform': platformLabel()},
    );
  }

  /// Fired when the user taps Rate SceneSplit (native review or store fallback).
  Future<void> trackReviewPrompted({required bool available}) async {
    await _track(
      AnalyticsEvents.reviewPrompted,
      properties: {'available': available, 'platform': platformLabel()},
    );
  }

  /// Fired after a backup file is saved or shared successfully.
  ///
  /// [method] is `save` or `share`.
  Future<void> trackBackupExported({required String method}) async {
    await _track(
      AnalyticsEvents.backupExported,
      properties: {'method': method, 'platform': platformLabel()},
    );
  }

  /// Fired after a backup import completes successfully.
  Future<void> trackBackupImported() async {
    await _track(
      AnalyticsEvents.backupImported,
      properties: {'platform': platformLabel()},
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
