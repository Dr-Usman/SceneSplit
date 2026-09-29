/// Canonical Mixpanel event names used by [AnalyticsService].
///
/// Organized logically by functional domain. Add new product events here first,
/// then wire a typed `track*` method in [AnalyticsService].
abstract final class AnalyticsEvents {
  // 1. App Lifecycle & Onboarding
  static const appOpened = 'app_opened';
  static const signUpCompleted = 'sign_up_completed';
  static const tabSelected = 'tab_selected';
  static const languageChanged = 'language_changed';
  static const currencyChanged = 'currency_changed';

  // 2. Groups / Scenes (CRUD)
  static const groupCreated = 'group_created';
  static const groupEdited = 'group_edited';
  static const groupDeleted = 'group_deleted';

  // 3. Expenses (CRUD) & Calculator
  static const expenseCreated = 'expense_created';
  static const expenseEdited = 'expense_edited';
  static const expenseDeleted = 'expense_deleted';
  static const calculatorUsed = 'calculator_used';
  static const expensesShared = 'expenses_shared';

  // 4. Settlements (CRUD)
  static const settlementCreated = 'settlement_created';
  static const settlementEdited = 'settlement_edited';
  static const settlementDeleted = 'settlement_deleted';

  // 5. Scene Reports
  static const reportOpened = 'report_opened';
  static const reportShared = 'report_shared';
  static const reportFilterApplied = 'report_filter_applied';
  static const reportSortChanged = 'report_sort_changed';

  // 6. Balances & Debts
  static const balanceShared = 'balance_shared';
  static const balancesPairOpened = 'balances_pair_opened';
  static const balancesFilterApplied = 'balances_filter_applied';
  static const balancesFilterCleared = 'balances_filter_cleared';

  // 7. People & Contacts (CRUD)
  static const personCreated = 'person_created';
  static const personEdited = 'person_edited';
  static const personDeleted = 'person_deleted';
  static const personDetailOpened = 'person_detail_opened';
  static const profileNameUpdated = 'profile_name_updated';

  // 8. System, Store & Maintenance
  static const shareAppClicked = 'share_app_clicked';
  static const rateAppClicked = 'rate_app_clicked';
  static const updatePrompted = 'update_prompted';
  static const updateStarted = 'update_started';
  static const backupExported = 'backup_exported';
  static const backupImported = 'backup_imported';
  static const feedbackInitiated = 'feedback_initiated';
  static const privacyPolicyOpened = 'privacy_policy_opened';
  static const termsOfServiceOpened = 'terms_of_service_opened';
  static const moreAppsClicked = 'more_apps_clicked';

  /// Complete integrated catalog of all 39 events organized by functional domain.
  static const List<String> all = [
    // 1. App Lifecycle & Onboarding
    appOpened,
    signUpCompleted,
    tabSelected,
    languageChanged,
    currencyChanged,

    // 2. Groups / Scenes
    groupCreated,
    groupEdited,
    groupDeleted,

    // 3. Expenses & Calculator
    expenseCreated,
    expenseEdited,
    expenseDeleted,
    calculatorUsed,
    expensesShared,

    // 4. Settlements
    settlementCreated,
    settlementEdited,
    settlementDeleted,

    // 5. Scene Reports
    reportOpened,
    reportShared,
    reportFilterApplied,
    reportSortChanged,

    // 6. Balances & Debts
    balanceShared,
    balancesPairOpened,
    balancesFilterApplied,
    balancesFilterCleared,

    // 7. People & Contacts
    personCreated,
    personEdited,
    personDeleted,
    personDetailOpened,
    profileNameUpdated,

    // 8. System, Store & Maintenance
    shareAppClicked,
    rateAppClicked,
    updatePrompted,
    updateStarted,
    backupExported,
    backupImported,
    feedbackInitiated,
    privacyPolicyOpened,
    termsOfServiceOpened,
    moreAppsClicked,
  ];
}
