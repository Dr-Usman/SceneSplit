// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonImport => 'Import';

  @override
  String commonYouSuffix(String name) {
    return '$name (you)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '\"$name\" is already in the list.';
  }

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get onboardingTagline =>
      'Split expenses with friends.\nNo accounts, no fuss.';

  @override
  String get onboardingYourName => 'YOUR NAME';

  @override
  String get onboardingNameHint => 'e.g. John Doe';

  @override
  String get onboardingCurrency => 'CURRENCY';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingPrivacyNote => 'Everything stays on your device.';

  @override
  String get homeNewGroup => 'New group';

  @override
  String get homeGroupsHeader => 'GROUPS';

  @override
  String get homeYouGetByGroup => 'You get by group';

  @override
  String get homeYouWillGiveByGroup => 'You will give by group';

  @override
  String get homeBreakdownSubtitle => 'Amounts shown in each group\'s currency';

  @override
  String get homeYouWillGet => 'You will get';

  @override
  String get homeYouWillGive => 'You will give';

  @override
  String get homeSettledUp => 'settled up';

  @override
  String get homeCardYouWillGet => 'you will get';

  @override
  String get homeCardYouWillGive => 'you will give';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'No groups yet';

  @override
  String get homeEmptyBody =>
      'Create a group for your trip, home,\nor friends to start splitting.';

  @override
  String get groupsNewGroup => 'New group';

  @override
  String get groupsEditGroup => 'Edit group';

  @override
  String get groupsGroupName => 'GROUP NAME';

  @override
  String get groupsNameHint => 'e.g. Trip to Japan';

  @override
  String get groupsIcon => 'ICON';

  @override
  String get groupsCurrency => 'CURRENCY';

  @override
  String get groupsMembers => 'MEMBERS';

  @override
  String get groupsAddMemberHint => 'Add member by name';

  @override
  String get groupsCreateGroup => 'Create group';

  @override
  String get groupsSaveChanges => 'Save changes';

  @override
  String get groupsRemovalBlockedYou =>
      'You have expenses or settlements in this group and cannot be removed.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name has expenses or settlements in this group and cannot be removed.';
  }

  @override
  String get groupsThisMember => 'This member';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Delete group';

  @override
  String get groupsAddExpense => 'Add expense';

  @override
  String get groupsExpenseBreakdown => 'EXPENSE BREAKDOWN';

  @override
  String groupsMembersHeader(int count) {
    return 'MEMBERS ($count)';
  }

  @override
  String get groupsManage => 'Manage';

  @override
  String get groupsWhoOwesWhom => 'WHO OWES WHOM';

  @override
  String get groupsSettleUp => 'Settle up';

  @override
  String get groupsSettlements => 'SETTLEMENTS';

  @override
  String get groupsExpenses => 'EXPENSES';

  @override
  String get groupsDeleteExpenseTitle => 'Delete expense?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'Remove \"$title\" from this group?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Delete group?';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'Delete \"$name\" and all its expenses? This cannot be undone.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'Delete settlement?';

  @override
  String get groupsDeleteSettlementBody => 'Remove this recorded payment?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from owes $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer paid · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from paid $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'No expenses yet';

  @override
  String get groupsEmptyExpensesBody =>
      'Tap \"Add expense\" to split your first bill.';

  @override
  String get expensesEditTitle => 'Edit expense';

  @override
  String get expensesAddTitle => 'Add expense';

  @override
  String get expensesDetailTitle => 'Expense';

  @override
  String get expensesNotFound => 'Expense not found';

  @override
  String get expensesAmount => 'Amount';

  @override
  String get expensesAmountSubtitle => 'Total bill amount';

  @override
  String get expensesDescription => 'Description';

  @override
  String get expensesDescriptionHint => 'e.g. Dinner, Groceries, Taxi';

  @override
  String get expensesDate => 'Date';

  @override
  String get expensesPaidBy => 'Paid by';

  @override
  String get expensesPaidBySubtitle => 'Who covered this bill';

  @override
  String get expensesPaidByHeader => 'PAID BY';

  @override
  String get expensesPayerSingle => 'Single';

  @override
  String get expensesPayerMultiple => 'Multiple';

  @override
  String get expensesSplit => 'Split';

  @override
  String get expensesSplitSubtitle => 'How to divide the cost';

  @override
  String get expensesSplitEqual => 'Equal';

  @override
  String get expensesSplitExact => 'Exact';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Exact amounts';

  @override
  String get expensesSplitByPercentage => 'By percentage';

  @override
  String get expensesSplitEqually => 'Split equally';

  @override
  String get expensesSplitBreakdown => 'SPLIT BREAKDOWN';

  @override
  String get expensesNote => 'Note';

  @override
  String get expensesNoteHint => 'Optional note';

  @override
  String get expensesSaveChanges => 'Save changes';

  @override
  String get expensesSaveExpense => 'Save expense';

  @override
  String get expensesSubtitlePaid => 'paid';

  @override
  String get expensesSubtitleAlsoPaid => 'also paid';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Each payment must not exceed $amount';
  }

  @override
  String get expensesEnterValidPayments => 'Enter valid payment amounts';

  @override
  String expensesOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Payments total $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Each share must not exceed $amount';
  }

  @override
  String get expensesEnterValidSplits => 'Enter valid split amounts';

  @override
  String get expensesPercentOver100 => 'Each share must be 100% or less';

  @override
  String get expensesEnterValidPercents => 'Enter valid split percentages';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Total $total% — reduce by $over%';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Total $total% — $remaining% remaining';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get settlementsEditTitle => 'Edit settlement';

  @override
  String get settlementsRecordTitle => 'Record settlement';

  @override
  String get settlementsFromPays => 'FROM (PAYS)';

  @override
  String get settlementsToReceives => 'TO (RECEIVES)';

  @override
  String get settlementsAmount => 'AMOUNT';

  @override
  String get settlementsNoteOptional => 'NOTE (OPTIONAL)';

  @override
  String get settlementsNoteHint => 'Cash, bank transfer…';

  @override
  String get settlementsSaveChanges => 'Save changes';

  @override
  String get settlementsRecordPayment => 'Record payment';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileYourName => 'Your name';

  @override
  String get profileLanguage => 'LANGUAGE';

  @override
  String get profileLanguageHint =>
      'Follows your device unless you choose a language.';

  @override
  String get profileLanguageSystem => 'System';

  @override
  String get profileAppearance => 'APPEARANCE';

  @override
  String get profileAppearanceHint =>
      'Follows your device unless you choose Light or Dark.';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileDefaultCurrencyHeader => 'DEFAULT CURRENCY';

  @override
  String get profileDefaultCurrencyHint =>
      'Used for new groups and the home summary.';

  @override
  String get profileDefaultCurrencySheet => 'Default currency';

  @override
  String get profileManage => 'MANAGE';

  @override
  String get profilePeople => 'People';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'No people yet',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Data & backup';

  @override
  String get profileDataBackupSubtitle => 'Export or import your data';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'About $appName';
  }

  @override
  String get profileAboutSubtitle => 'Privacy, contact, feedback & share';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'People';

  @override
  String get peopleAddPerson => 'Add person';

  @override
  String get peopleAddHint => 'e.g. Alice';

  @override
  String get peopleEditName => 'Edit name';

  @override
  String get peopleDeleteTitle => 'Delete person?';

  @override
  String peopleDeleteBody(String name) {
    return 'Remove $name from your people list? This cannot be undone.';
  }

  @override
  String get peopleIntro => 'Everyone added across your groups.';

  @override
  String get peopleSearchHint => 'Search by name';

  @override
  String get peopleEmpty => 'No people yet. Tap + to add someone.';

  @override
  String get peopleNoMatch => 'No people match your search.';

  @override
  String get dataTitle => 'Data & backup';

  @override
  String get dataWebBlurb =>
      'Backup export and import are available in the mobile and desktop apps. Your data is stored locally in this browser.';

  @override
  String get dataNativeBlurb =>
      'Export a backup, then save it on your device or share it elsewhere. Import replaces everything on this device.';

  @override
  String get dataExportBackup => 'Export backup';

  @override
  String get dataImportBackup => 'Import backup';

  @override
  String get dataCouldNotExport => 'Could not export backup.';

  @override
  String get dataSaveBackupDialog => 'Save backup';

  @override
  String get dataBackupSaved => 'Backup saved.';

  @override
  String get dataCouldNotSave => 'Could not save backup.';

  @override
  String get dataShareSubject => 'SceneSplit backup';

  @override
  String get dataShareText => 'SceneSplit database backup';

  @override
  String get dataCouldNotShare => 'Could not share backup.';

  @override
  String get dataImportTitle => 'Import backup?';

  @override
  String get dataImportBody =>
      'Importing a backup will replace all data currently in SceneSplit on this device. This cannot be undone.';

  @override
  String get dataImportSuccess => 'Backup imported successfully.';

  @override
  String get dataCouldNotImport => 'Could not import backup.';

  @override
  String get dataBackupReady => 'Backup ready';

  @override
  String get dataSaveToDevice => 'Save to device';

  @override
  String get dataSaveToDeviceSubtitle => 'Choose folder and filename';

  @override
  String get dataShare => 'Share';

  @override
  String get dataShareSubtitle => 'Send via email, Drive, AirDrop, etc.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutCouldNotOpenEmail => 'Could not open email app';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Split expenses with friends.\nOffline-first. No account required.';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutTermsOfService => 'Terms of Service';

  @override
  String get aboutContactUs => 'Contact us';

  @override
  String get aboutEmailSupportSubject => 'SceneSplit Support';

  @override
  String get aboutSendFeedback => 'Send feedback';

  @override
  String get aboutEmailFeedbackSubject => 'SceneSplit Feedback';

  @override
  String get aboutSuggestFeature => 'Suggest a feature';

  @override
  String get aboutEmailFeatureSubject => 'SceneSplit Feature Suggestion';

  @override
  String aboutRateApp(String appName) {
    return 'Rate $appName';
  }

  @override
  String get aboutShareApp => 'Share app';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Try $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Check out $appName — split expenses with friends. Offline-first, no account required.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'Could not share the app.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String legalLoadError(String error) {
    return 'Could not load document: $error';
  }

  @override
  String get sharedSettledTitle => 'You are all settled up';

  @override
  String get sharedSettledSubtitle => 'No outstanding balances in this group';

  @override
  String get sharedYouGet => 'You get';

  @override
  String get sharedYouWillGive => 'You will give';

  @override
  String get sharedNoChartData => 'No data to chart';

  @override
  String get sharedTotal => 'Total';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => 'Choose language';

  @override
  String get sharedChooseCurrency => 'Choose currency';

  @override
  String get sharedCurrencySearchHint => 'Search by name, code, or symbol';

  @override
  String get sharedNoCurrenciesFound => 'No currencies found';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Custom emoji';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a & $b';
  }

  @override
  String moneyManyPayers(String name, int count) {
    return '$name +$count';
  }

  @override
  String supportEmailBodyFooter(String appName, String version, String build) {
    return '\n\n---\nApp: $appName $version ($build)';
  }

  @override
  String errorUserNameTaken(String name) {
    return 'Someone named \"$name\" already exists.';
  }

  @override
  String get errorCannotDeleteSelf => 'You cannot delete yourself.';

  @override
  String get errorUserHasFinancialActivity =>
      'This person has expenses or settlements and cannot be deleted.';

  @override
  String get errorBackupCorrupt =>
      'Could not open backup file. It may be corrupt or not a SQLite database.';

  @override
  String get errorBackupVersionMismatch =>
      'This backup is from a different app version and cannot be imported.';

  @override
  String get errorBackupNotSceneSplit =>
      'This file does not look like a SceneSplit backup.';

  @override
  String get errorBackupExportWeb =>
      'Backup export is not available on web. Use the mobile or desktop app to export backups.';

  @override
  String get errorBackupImportWeb =>
      'Backup import is not available on web. Use the mobile or desktop app to import backups.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageJapanese => '日本語';
}
