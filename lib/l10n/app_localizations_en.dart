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
  String get homeNewGroup => 'New scene';

  @override
  String get homeGroupsHeader => 'SCENES';

  @override
  String get homeYouGetByGroup => 'You get by scene';

  @override
  String get homeYouWillGiveByGroup => 'You will give by scene';

  @override
  String get homeBreakdownSubtitle => 'Amounts shown in each scene\'s currency';

  @override
  String get homeYouWillGet => 'You will get';

  @override
  String get homeYouWillGive => 'You will give';

  @override
  String get homeSettledUp => 'settled up';

  @override
  String get homeCardYouWillGet => 'you will get';

  @override
  String get navScenes => 'Scenes';

  @override
  String get navBalances => 'Balances';

  @override
  String get navProfile => 'Profile';

  @override
  String get balancesTitle => 'Balances';

  @override
  String get balancesSubtitle => 'See who owes whom across your scenes.';

  @override
  String get balancesWho => 'Who';

  @override
  String get balancesWhom => 'Whom';

  @override
  String get balancesFilterTitle => 'Who owes whom';

  @override
  String get balancesFilterHint => 'Choose who owes whom to filter open debts.';

  @override
  String get balancesAnyone => 'Anyone';

  @override
  String get balancesOwes => 'owes';

  @override
  String get balancesClear => 'Clear';

  @override
  String get balancesShowResults => 'Show results';

  @override
  String get balancesClearSelection => 'Clear selection';

  @override
  String get balancesEmpty => 'No open debts across your scenes.';

  @override
  String get balancesEmptyFiltered => 'No open debts match this selection.';

  @override
  String get balancesPickPerson => 'Select a person';

  @override
  String get balancesNoPeopleFound => 'No people found';

  @override
  String balancesCurrencySection(String currency) {
    return '$currency';
  }

  @override
  String get balancesOpenDebtTotal => 'Open debt';

  @override
  String balancesOpenDebtCurrency(String currency) {
    return 'Open debt ($currency)';
  }

  @override
  String get balancesYouAreOwed => 'You\'re owed';

  @override
  String get balancesYouOwe => 'You owe';

  @override
  String get balancesHeroOwed => 'They get';

  @override
  String get balancesHeroOwe => 'They owe';

  @override
  String balancesHeroOwedBreakdown(String name) {
    return 'Who owes $name';
  }

  @override
  String balancesHeroOweBreakdown(String name) {
    return 'Whom $name owes';
  }

  @override
  String get balancesHeroNetLabel => 'Net';

  @override
  String balancesHeroNetOwes(String debtor, String creditor) {
    return '$debtor owes $creditor';
  }

  @override
  String get balancesShareTotal => 'Total share';

  @override
  String get balancesExpenseTotal => 'Total expenses';

  @override
  String get balancesScenesHeader => 'SCENES';

  @override
  String get balancesSettleInScene => 'Settle up';

  @override
  String get balancesViewShares => 'Expense shares';

  @override
  String get balancesPairSettled => 'Settled between these people';

  @override
  String balancesPairBetween(String a, String b) {
    return '$a & $b';
  }

  @override
  String get balancesSelectPerson => 'Tap to select';

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
  String get homeEmptyTitle => 'No scenes yet';

  @override
  String get homeEmptyBody =>
      'Create a scene for a trip, dinner,\nor shared home to start splitting.';

  @override
  String get groupsNewGroup => 'New scene';

  @override
  String get groupsEditGroup => 'Edit scene';

  @override
  String get groupsGroupName => 'SCENE NAME';

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
  String get groupsCreateGroup => 'Create scene';

  @override
  String get groupsSaveChanges => 'Save changes';

  @override
  String get groupsRemovalBlockedYou =>
      'You have expenses or settlements in this scene and cannot be removed.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name has expenses or settlements in this scene and cannot be removed.';
  }

  @override
  String get groupsThisMember => 'This member';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Delete scene';

  @override
  String get groupsAddExpense => 'Add expense';

  @override
  String get groupsExpenseBreakdown => 'EXPENSE BREAKDOWN';

  @override
  String groupsMemberShareTitle(String name) {
    return '$name\'s share';
  }

  @override
  String groupsMemberShareExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String groupsMemberShareOfAmount(String amount) {
    return 'of $amount';
  }

  @override
  String get groupsMemberShareTotalLabel => 'Total share';

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
  String get groupsShareBalances => 'Share';

  @override
  String groupsShareBalancesSubject(String groupName) {
    return 'Balances — $groupName';
  }

  @override
  String groupsShareBalancesText(String groupName) {
    return 'Who owes whom in $groupName';
  }

  @override
  String get groupsShareAllSettled => 'All settled';

  @override
  String get groupsExpenseShares => 'Expense shares';

  @override
  String get groupsCouldNotShareBalances => 'Could not share balances.';

  @override
  String get groupsShareExpenses => 'Share';

  @override
  String get groupsShareExpensesRangeTitle => 'Choose dates';

  @override
  String get groupsShareExpensesRangeAll => 'All dates';

  @override
  String get groupsShareExpensesRangeAllSubtitle =>
      'Every expense in this scene';

  @override
  String get groupsShareExpensesRangeMonth => 'This month';

  @override
  String get groupsShareExpensesRangeMonthSubtitle =>
      'From the 1st through today';

  @override
  String get groupsShareExpensesRangeLast7 => 'Last 7 days';

  @override
  String get groupsShareExpensesRangeLast7Subtitle => 'Including today';

  @override
  String get groupsShareExpensesRangeCustom => 'Custom range';

  @override
  String get groupsShareExpensesRangeCustomSubtitle =>
      'Pick start and end dates';

  @override
  String get groupsShareExpensesFormatTitle => 'How to share';

  @override
  String get groupsShareExpensesFormatImage => 'Image';

  @override
  String get groupsShareExpensesFormatImageSubtitle =>
      'Compact list as a picture';

  @override
  String get groupsShareExpensesFormatText => 'Text';

  @override
  String get groupsShareExpensesFormatTextSubtitle =>
      'Who paid and each person\'s share';

  @override
  String get groupsShareExpensesEmptyRange => 'No expenses in this date range.';

  @override
  String get groupsCouldNotShareExpenses => 'Could not share expenses.';

  @override
  String groupsShareExpensesSubject(String groupName) {
    return 'Expenses — $groupName';
  }

  @override
  String groupsShareExpensesCaption(String groupName) {
    return 'Expenses in $groupName';
  }

  @override
  String groupsShareExpensesCaptionWithRange(String groupName, String range) {
    return 'Expenses in $groupName ($range)';
  }

  @override
  String groupsShareExpensesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String groupsShareExpensesAndMore(int count) {
    return 'and $count more';
  }

  @override
  String groupsShareExpensesPayerPaidDatePeople(
    String payer,
    String date,
    String people,
  ) {
    return '$payer paid · $date · $people';
  }

  @override
  String groupsShareExpensesPaidDateAmount(
    String payer,
    String date,
    String amount,
  ) {
    return '$payer paid · $date · $amount';
  }

  @override
  String groupsShareExpensesNameAmount(String name, String amount) {
    return '$name $amount';
  }

  @override
  String groupsShareExpensesHeaderMeta(String range, String countLabel) {
    return '$range · $countLabel';
  }

  @override
  String groupsShareExpensesRangeSpan(String start, String end) {
    return '$start – $end';
  }

  @override
  String groupsShareExpensesTotalLine(String amount) {
    return 'Total: $amount';
  }

  @override
  String groupsShareExpensesMemberTotalLine(
    String name,
    String parts,
    String total,
  ) {
    return '$name: $parts = $total';
  }

  @override
  String groupsShareExpensesMemberSingle(String name, String total) {
    return '$name: $total';
  }

  @override
  String get groupsShareExpensesByPerson => 'By person';

  @override
  String get groupsSettlements => 'SETTLEMENTS';

  @override
  String get groupsExpenses => 'EXPENSES';

  @override
  String get groupsSettlementsTitle => 'Settlements';

  @override
  String get groupsExpensesTitle => 'Expenses';

  @override
  String groupsSettlementsScreenTitle(String groupName) {
    return '$groupName · Settlements';
  }

  @override
  String groupsExpensesScreenTitle(String groupName) {
    return '$groupName · Expenses';
  }

  @override
  String groupsViewAllCount(int count) {
    return 'See all ($count)';
  }

  @override
  String get groupsEmptySettlementsBody => 'No settlements recorded yet.';

  @override
  String get groupsSwipeToDeleteHint => 'Swipe left to delete';

  @override
  String get groupsDeleteExpenseTitle => 'Delete expense?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'Remove \"$title\" from this scene?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Delete scene?';

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
      'Used for new scenes and the home summary.';

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
  String get peopleIntro => 'Everyone added across your scenes.';

  @override
  String get peopleSearchHint => 'Search by name';

  @override
  String get peopleEmpty => 'No people yet. Tap + to add someone.';

  @override
  String get peopleNoMatch => 'No people match your search.';

  @override
  String get peopleSwipeHint => 'Swipe left on a person for edit and delete';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes',
      one: '1 scene',
      zero: 'Not in any scenes',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle =>
      'Amounts shown in each scene\'s currency';

  @override
  String get peopleDetailEmptyScenes => 'Not a member of any scenes yet.';

  @override
  String get peopleDetailAllSettled => 'All settled across scenes';

  @override
  String get peopleDetailOpenBalances => 'Open balances in some scenes';

  @override
  String peopleDetailGets(String name) {
    return '$name\'s total credit';
  }

  @override
  String peopleDetailWillGive(String name) {
    return '$name\'s total debt';
  }

  @override
  String get peopleDetailYourTotalCredit => 'Your total credit';

  @override
  String get peopleDetailYourTotalDebt => 'Your total debt';

  @override
  String get peopleDetailSettledInScene => 'Settled';

  @override
  String get peopleDetailNoDebts => 'No open debts in this scene';

  @override
  String get peopleDetailViewExpenses => 'View expense shares';

  @override
  String get peopleDetailExpensesSection => 'EXPENSES';

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
  String get sharedSettledSubtitle => 'No outstanding balances in this scene';

  @override
  String get sharedYouGet => 'You get';

  @override
  String get sharedYouWillGive => 'You give';

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
