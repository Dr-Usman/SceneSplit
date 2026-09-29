import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'analytics_events.dart';

/// Mixpanel product analytics. Typed methods below are organized by functional domain.
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

  // ===========================================================================
  // 1. App Lifecycle & Onboarding
  // ===========================================================================

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

  /// Persists currency on the user profile.
  Future<void> setCurrencyCode(String currencyCode) async {
    await _ensureInitialized();
    final mp = _mixpanel;
    if (mp == null) return;
    mp.getPeople().set('currency_code', currencyCode);
  }

  /// Fired when the user explicitly changes the app currency in Profile.
  Future<void> trackCurrencyChanged({
    required String currencyCode,
    String? previousCurrencyCode,
  }) async {
    await setCurrencyCode(currencyCode);
    await _track(
      AnalyticsEvents.currencyChanged,
      properties: {
        'currency_code': currencyCode,
        'previous_currency_code': ?previousCurrencyCode,
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

  /// Fired when the user selects a bottom-nav tab (skips no-op same-index).
  ///
  /// [tab] is one of `scenes`, `balances`, `profile`.
  Future<void> trackTabSelected({required String tab}) async {
    await _track(AnalyticsEvents.tabSelected, properties: {'tab': tab});
  }

  // ===========================================================================
  // 2. Groups / Scenes (CRUD)
  // ===========================================================================

  /// Fired after a group is created.
  Future<void> trackGroupCreated({
    required String groupId,
    required String groupName,
    required String currencyCode,
    required int memberCount,
    required bool showDecimals,
  }) async {
    await _track(
      AnalyticsEvents.groupCreated,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'currency_code': currencyCode,
        'member_count': memberCount,
        'show_decimals': showDecimals,
      },
    );
  }

  /// Fired after an existing group is edited and saved.
  Future<void> trackGroupEdited({
    required String groupId,
    required String groupName,
    required String currencyCode,
    required int memberCount,
    required bool showDecimals,
  }) async {
    await _track(
      AnalyticsEvents.groupEdited,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'currency_code': currencyCode,
        'member_count': memberCount,
        'show_decimals': showDecimals,
      },
    );
  }

  /// Fired when a group is deleted.
  Future<void> trackGroupDeleted({
    required String groupId,
    required String groupName,
  }) async {
    await _track(
      AnalyticsEvents.groupDeleted,
      properties: {'group_id': groupId, 'group_name': groupName},
    );
  }

  // ===========================================================================
  // 3. Expenses (CRUD) & Calculator
  // ===========================================================================

  /// Fired after a new expense is saved (not on edit).
  Future<void> trackExpenseCreated({
    required String groupId,
    required String groupName,
    required String splitType,
    required String paidByMode,
    required int amountCents,
    required String currencyCode,
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
        'currency_code': currencyCode,
        'member_count': memberCount,
      },
    );
  }

  /// Fired after an existing expense is edited and saved.
  Future<void> trackExpenseEdited({
    required String groupId,
    required String groupName,
    required String splitType,
    required String paidByMode,
    required int amountCents,
    required String currencyCode,
    required int memberCount,
  }) async {
    await _track(
      AnalyticsEvents.expenseEdited,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'split_type': splitType,
        'paid_by_mode': paidByMode,
        'amount_cents': amountCents,
        'currency_code': currencyCode,
        'member_count': memberCount,
      },
    );
  }

  /// Fired when an expense is deleted.
  Future<void> trackExpenseDeleted({
    required String groupId,
    String? groupName,
    required int amountCents,
    String? currencyCode,
  }) async {
    await _track(
      AnalyticsEvents.expenseDeleted,
      properties: {
        'group_id': groupId,
        'group_name': ?groupName,
        'amount_cents': amountCents,
        'currency_code': ?currencyCode,
      },
    );
  }

  /// Fired when calculator result is applied to the expense amount field.
  Future<void> trackCalculatorUsed({
    required String groupId,
    required String groupName,
  }) async {
    await _track(
      AnalyticsEvents.calculatorUsed,
      properties: {'group_id': groupId, 'group_name': groupName},
    );
  }

  /// Fired after the user successfully opens the share sheet for expenses.
  ///
  /// [format] is `image` or `text`. [range] is `all`, `month`, `7d`, or `custom`.
  Future<void> trackExpensesShared({
    required int expenseCount,
    required String format,
    required String range,
  }) async {
    await _track(
      AnalyticsEvents.expensesShared,
      properties: {
        'expense_count': expenseCount,
        'format': format,
        'range': range,
        'platform': platformLabel(),
      },
    );
  }

  // ===========================================================================
  // 4. Settlements (CRUD)
  // ===========================================================================

  /// Fired after a new settlement is saved (not on edit).
  ///
  /// [source] is one of `scene_detail`, `balances_pair`, `person_detail`, `group_expenses`, `group_report`.
  Future<void> trackSettlementCreated({
    required String groupId,
    String? groupName,
    required int amountCents,
    required String currencyCode,
    required String source,
    required bool hadPrefill,
    bool isCustomDate = false,
  }) async {
    await _track(
      AnalyticsEvents.settlementCreated,
      properties: {
        'group_id': groupId,
        'group_name': ?groupName,
        'amount_cents': amountCents,
        'currency_code': currencyCode,
        'source': source,
        'had_prefill': hadPrefill,
        'is_custom_date': isCustomDate,
      },
    );
  }

  /// Fired after an existing settlement is edited and saved.
  Future<void> trackSettlementEdited({
    required String groupId,
    String? groupName,
    required int amountCents,
    required String currencyCode,
    bool isCustomDate = false,
  }) async {
    await _track(
      AnalyticsEvents.settlementEdited,
      properties: {
        'group_id': groupId,
        'group_name': ?groupName,
        'amount_cents': amountCents,
        'currency_code': currencyCode,
        'is_custom_date': isCustomDate,
      },
    );
  }

  /// Fired when a settlement is deleted.
  Future<void> trackSettlementDeleted({
    required String groupId,
    String? groupName,
    required int amountCents,
    required String currencyCode,
  }) async {
    await _track(
      AnalyticsEvents.settlementDeleted,
      properties: {
        'group_id': groupId,
        'group_name': ?groupName,
        'amount_cents': amountCents,
        'currency_code': currencyCode,
      },
    );
  }

  // ===========================================================================
  // 5. Scene Reports
  // ===========================================================================

  /// Fired once when a group report screen is opened and data loads.
  Future<void> trackReportOpened({
    required String groupId,
    required String groupName,
    required String source,
    required String defaultPreset,
    required int expenseCount,
    required int settlementCount,
  }) async {
    await _track(
      AnalyticsEvents.reportOpened,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'source': source,
        'default_preset': defaultPreset,
        'expense_count': expenseCount,
        'settlement_count': settlementCount,
      },
    );
  }

  /// Fired after the user successfully exports/shares a group report.
  Future<void> trackReportShared({
    required String groupId,
    required String groupName,
    required String format,
    required String rangePreset,
    required bool isSingleMember,
    String? selectedMemberName,
    required int expenseCount,
    required int settlementCount,
  }) async {
    await _track(
      AnalyticsEvents.reportShared,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'format': format,
        'range_preset': rangePreset,
        'is_single_member': isSingleMember,
        'selected_member_name': ?selectedMemberName,
        'expense_count': expenseCount,
        'settlement_count': settlementCount,
        'platform': platformLabel(),
      },
    );
  }

  /// Fired when a filter (date preset or member filter) is applied in group report.
  Future<void> trackReportFilterApplied({
    required String groupId,
    required String groupName,
    required String filterType,
    required String filterValue,
  }) async {
    await _track(
      AnalyticsEvents.reportFilterApplied,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'filter_type': filterType,
        'filter_value': filterValue,
      },
    );
  }

  /// Fired when the sort order is changed in group report.
  Future<void> trackReportSortChanged({
    required String groupId,
    required String groupName,
    required String sortOrder,
  }) async {
    await _track(
      AnalyticsEvents.reportSortChanged,
      properties: {
        'group_id': groupId,
        'group_name': groupName,
        'sort_order': sortOrder,
      },
    );
  }

  // ===========================================================================
  // 6. Balances & Debts
  // ===========================================================================

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

  // ===========================================================================
  // 7. People & Contacts (CRUD)
  // ===========================================================================

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

  /// Fired when a new person is created.
  ///
  /// [source] is one of `profile_people`, `group_create`, `group_edit`.
  Future<void> trackPersonCreated({required String source}) async {
    await _track(AnalyticsEvents.personCreated, properties: {'source': source});
  }

  /// Fired when a person's display name is updated.
  Future<void> trackPersonEdited({required String personId}) async {
    await _track(
      AnalyticsEvents.personEdited,
      properties: {'person_id': personId},
    );
  }

  /// Fired when an unlinked person is deleted.
  Future<void> trackPersonDeleted({required String personId}) async {
    await _track(
      AnalyticsEvents.personDeleted,
      properties: {'person_id': personId},
    );
  }

  /// Fired when the current user updates their own profile display name.
  ///
  /// Updates `$name` in Mixpanel People. The event itself contains 0 PII.
  Future<void> trackProfileNameUpdated({String? name}) async {
    await _ensureInitialized();
    if (name != null && name.trim().isNotEmpty) {
      _mixpanel?.getPeople().set(r'$name', name.trim());
    }
    await _track(AnalyticsEvents.profileNameUpdated);
  }

  // ===========================================================================
  // 8. System, Store & Maintenance
  // ===========================================================================

  /// Fired when the user taps “Share SceneSplit”.
  Future<void> trackShareAppClicked() async {
    await _track(
      AnalyticsEvents.shareAppClicked,
      properties: {'platform': platformLabel()},
    );
  }

  /// Fired when the user taps “Rate SceneSplit” to open the store listing.
  Future<void> trackRateAppClicked({bool available = true}) async {
    await _track(
      AnalyticsEvents.rateAppClicked,
      properties: {'available': available, 'platform': platformLabel()},
    );
  }

  /// Fired when an in-app update prompt or flexible flow is shown.
  Future<void> trackUpdatePrompted({required String platform}) async {
    await _track(
      AnalyticsEvents.updatePrompted,
      properties: {'platform': platform},
    );
  }

  /// Fired when the user accepts / starts downloading an update.
  Future<void> trackUpdateStarted({required String platform}) async {
    await _track(
      AnalyticsEvents.updateStarted,
      properties: {'platform': platform},
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

  /// Fired when a user initiates a feedback, support, or feature request action.
  ///
  /// [type] is one of `support`, `feedback`, `feature_request`.
  Future<void> trackFeedbackInitiated({required String type}) async {
    await _track(
      AnalyticsEvents.feedbackInitiated,
      properties: {'type': type, 'platform': platformLabel()},
    );
  }

  /// Fired when the user views the Privacy Policy.
  Future<void> trackPrivacyPolicyOpened() async {
    await _track(
      AnalyticsEvents.privacyPolicyOpened,
      properties: {'platform': platformLabel()},
    );
  }

  /// Fired when the user views the Terms of Service.
  Future<void> trackTermsOfServiceOpened() async {
    await _track(
      AnalyticsEvents.termsOfServiceOpened,
      properties: {'platform': platformLabel()},
    );
  }

  /// Fired when the user taps More Apps to open the developer store page.
  Future<void> trackMoreAppsClicked() async {
    await _track(
      AnalyticsEvents.moreAppsClicked,
      properties: {'platform': platformLabel()},
    );
  }

  // ===========================================================================
  // Internal Helpers
  // ===========================================================================

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
