import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String commonSomethingWentWrong(String error);

  /// No description provided for @commonErrorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorWithDetail(String error);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @commonYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String commonYouSuffix(String name);

  /// No description provided for @commonNameAlreadyInList.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already in the list.'**
  String commonNameAlreadyInList(String name);

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Split expenses with friends.\nNo accounts, no fuss.'**
  String get onboardingTagline;

  /// No description provided for @onboardingYourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get onboardingYourName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get onboardingNameHint;

  /// No description provided for @onboardingCurrency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get onboardingCurrency;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on your device.'**
  String get onboardingPrivacyNote;

  /// No description provided for @homeNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New scene'**
  String get homeNewGroup;

  /// No description provided for @homeGroupsHeader.
  ///
  /// In en, this message translates to:
  /// **'SCENES'**
  String get homeGroupsHeader;

  /// No description provided for @homeYouGetByGroup.
  ///
  /// In en, this message translates to:
  /// **'You get by scene'**
  String get homeYouGetByGroup;

  /// No description provided for @homeYouWillGiveByGroup.
  ///
  /// In en, this message translates to:
  /// **'You will give by scene'**
  String get homeYouWillGiveByGroup;

  /// No description provided for @homeBreakdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amounts shown in each scene\'s currency'**
  String get homeBreakdownSubtitle;

  /// No description provided for @homeYouWillGet.
  ///
  /// In en, this message translates to:
  /// **'You will get'**
  String get homeYouWillGet;

  /// No description provided for @homeYouWillGive.
  ///
  /// In en, this message translates to:
  /// **'You will give'**
  String get homeYouWillGive;

  /// No description provided for @homeSettledUp.
  ///
  /// In en, this message translates to:
  /// **'settled up'**
  String get homeSettledUp;

  /// No description provided for @homeCardYouWillGet.
  ///
  /// In en, this message translates to:
  /// **'you will get'**
  String get homeCardYouWillGet;

  /// No description provided for @homeCardYouWillGive.
  ///
  /// In en, this message translates to:
  /// **'you will give'**
  String get homeCardYouWillGive;

  /// No description provided for @homeMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String homeMemberCount(int count);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scenes yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a scene for a trip, dinner,\nor shared home to start splitting.'**
  String get homeEmptyBody;

  /// No description provided for @groupsNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New scene'**
  String get groupsNewGroup;

  /// No description provided for @groupsEditGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit scene'**
  String get groupsEditGroup;

  /// No description provided for @groupsGroupName.
  ///
  /// In en, this message translates to:
  /// **'SCENE NAME'**
  String get groupsGroupName;

  /// No description provided for @groupsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Trip to Japan'**
  String get groupsNameHint;

  /// No description provided for @groupsIcon.
  ///
  /// In en, this message translates to:
  /// **'ICON'**
  String get groupsIcon;

  /// No description provided for @groupsCurrency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get groupsCurrency;

  /// No description provided for @groupsMembers.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get groupsMembers;

  /// No description provided for @groupsAddMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Add member by name'**
  String get groupsAddMemberHint;

  /// No description provided for @groupsCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create scene'**
  String get groupsCreateGroup;

  /// No description provided for @groupsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get groupsSaveChanges;

  /// No description provided for @groupsRemovalBlockedYou.
  ///
  /// In en, this message translates to:
  /// **'You have expenses or settlements in this scene and cannot be removed.'**
  String get groupsRemovalBlockedYou;

  /// No description provided for @groupsRemovalBlockedOther.
  ///
  /// In en, this message translates to:
  /// **'{name} has expenses or settlements in this scene and cannot be removed.'**
  String groupsRemovalBlockedOther(String name);

  /// No description provided for @groupsThisMember.
  ///
  /// In en, this message translates to:
  /// **'This member'**
  String get groupsThisMember;

  /// No description provided for @groupsCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol} — {name} ({code})'**
  String groupsCurrencySubtitle(String symbol, String name, String code);

  /// No description provided for @groupsDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete scene'**
  String get groupsDeleteGroup;

  /// No description provided for @groupsAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get groupsAddExpense;

  /// No description provided for @groupsExpenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE BREAKDOWN'**
  String get groupsExpenseBreakdown;

  /// No description provided for @groupsMemberShareTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s share'**
  String groupsMemberShareTitle(String name);

  /// No description provided for @groupsMemberShareExpenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String groupsMemberShareExpenseCount(int count);

  /// No description provided for @groupsMemberShareOfAmount.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String groupsMemberShareOfAmount(String amount);

  /// No description provided for @groupsMemberShareTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total share'**
  String get groupsMemberShareTotalLabel;

  /// No description provided for @groupsMembersHeader.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS ({count})'**
  String groupsMembersHeader(int count);

  /// No description provided for @groupsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get groupsManage;

  /// No description provided for @groupsWhoOwesWhom.
  ///
  /// In en, this message translates to:
  /// **'WHO OWES WHOM'**
  String get groupsWhoOwesWhom;

  /// No description provided for @groupsSettleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get groupsSettleUp;

  /// No description provided for @groupsShareBalances.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get groupsShareBalances;

  /// No description provided for @groupsShareBalancesSubject.
  ///
  /// In en, this message translates to:
  /// **'Balances — {groupName}'**
  String groupsShareBalancesSubject(String groupName);

  /// No description provided for @groupsShareBalancesText.
  ///
  /// In en, this message translates to:
  /// **'Who owes whom in {groupName}'**
  String groupsShareBalancesText(String groupName);

  /// No description provided for @groupsShareAllSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled'**
  String get groupsShareAllSettled;

  /// No description provided for @groupsExpenseShares.
  ///
  /// In en, this message translates to:
  /// **'Expense shares'**
  String get groupsExpenseShares;

  /// No description provided for @groupsCouldNotShareBalances.
  ///
  /// In en, this message translates to:
  /// **'Could not share balances.'**
  String get groupsCouldNotShareBalances;

  /// No description provided for @groupsSettlements.
  ///
  /// In en, this message translates to:
  /// **'SETTLEMENTS'**
  String get groupsSettlements;

  /// No description provided for @groupsExpenses.
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get groupsExpenses;

  /// No description provided for @groupsSwipeToDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get groupsSwipeToDeleteHint;

  /// No description provided for @groupsDeleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get groupsDeleteExpenseTitle;

  /// No description provided for @groupsDeleteExpenseBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from this scene?'**
  String groupsDeleteExpenseBody(String title);

  /// No description provided for @groupsDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete scene?'**
  String get groupsDeleteGroupTitle;

  /// No description provided for @groupsDeleteGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and all its expenses? This cannot be undone.'**
  String groupsDeleteGroupBody(String name);

  /// No description provided for @groupsDeleteSettlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete settlement?'**
  String get groupsDeleteSettlementTitle;

  /// No description provided for @groupsDeleteSettlementBody.
  ///
  /// In en, this message translates to:
  /// **'Remove this recorded payment?'**
  String get groupsDeleteSettlementBody;

  /// No description provided for @groupsOwesTemplate.
  ///
  /// In en, this message translates to:
  /// **'{from} owes {to}'**
  String groupsOwesTemplate(String from, String to);

  /// No description provided for @groupsPayerPaidDate.
  ///
  /// In en, this message translates to:
  /// **'{payer} paid · {date}'**
  String groupsPayerPaidDate(String payer, String date);

  /// No description provided for @groupsSettlementPaid.
  ///
  /// In en, this message translates to:
  /// **'{from} paid {to}'**
  String groupsSettlementPaid(String from, String to);

  /// No description provided for @groupsEmptyExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get groupsEmptyExpensesTitle;

  /// No description provided for @groupsEmptyExpensesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add expense\" to split your first bill.'**
  String get groupsEmptyExpensesBody;

  /// No description provided for @expensesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expensesEditTitle;

  /// No description provided for @expensesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expensesAddTitle;

  /// No description provided for @expensesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expensesDetailTitle;

  /// No description provided for @expensesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found'**
  String get expensesNotFound;

  /// No description provided for @expensesAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expensesAmount;

  /// No description provided for @expensesAmountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Total bill amount'**
  String get expensesAmountSubtitle;

  /// No description provided for @expensesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expensesDescription;

  /// No description provided for @expensesDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dinner, Groceries, Taxi'**
  String get expensesDescriptionHint;

  /// No description provided for @expensesDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expensesDate;

  /// No description provided for @expensesPaidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expensesPaidBy;

  /// No description provided for @expensesPaidBySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who covered this bill'**
  String get expensesPaidBySubtitle;

  /// No description provided for @expensesPaidByHeader.
  ///
  /// In en, this message translates to:
  /// **'PAID BY'**
  String get expensesPaidByHeader;

  /// No description provided for @expensesPayerSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get expensesPayerSingle;

  /// No description provided for @expensesPayerMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple'**
  String get expensesPayerMultiple;

  /// No description provided for @expensesSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get expensesSplit;

  /// No description provided for @expensesSplitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How to divide the cost'**
  String get expensesSplitSubtitle;

  /// No description provided for @expensesSplitEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get expensesSplitEqual;

  /// No description provided for @expensesSplitExact.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get expensesSplitExact;

  /// No description provided for @expensesSplitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get expensesSplitPercent;

  /// No description provided for @expensesSplitExactAmounts.
  ///
  /// In en, this message translates to:
  /// **'Exact amounts'**
  String get expensesSplitExactAmounts;

  /// No description provided for @expensesSplitByPercentage.
  ///
  /// In en, this message translates to:
  /// **'By percentage'**
  String get expensesSplitByPercentage;

  /// No description provided for @expensesSplitEqually.
  ///
  /// In en, this message translates to:
  /// **'Split equally'**
  String get expensesSplitEqually;

  /// No description provided for @expensesSplitBreakdown.
  ///
  /// In en, this message translates to:
  /// **'SPLIT BREAKDOWN'**
  String get expensesSplitBreakdown;

  /// No description provided for @expensesNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expensesNote;

  /// No description provided for @expensesNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get expensesNoteHint;

  /// No description provided for @expensesSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get expensesSaveChanges;

  /// No description provided for @expensesSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get expensesSaveExpense;

  /// No description provided for @expensesSubtitlePaid.
  ///
  /// In en, this message translates to:
  /// **'paid'**
  String get expensesSubtitlePaid;

  /// No description provided for @expensesSubtitleAlsoPaid.
  ///
  /// In en, this message translates to:
  /// **'also paid'**
  String get expensesSubtitleAlsoPaid;

  /// No description provided for @expensesPaymentExceeds.
  ///
  /// In en, this message translates to:
  /// **'Each payment must not exceed {amount}'**
  String expensesPaymentExceeds(String amount);

  /// No description provided for @expensesEnterValidPayments.
  ///
  /// In en, this message translates to:
  /// **'Enter valid payment amounts'**
  String get expensesEnterValidPayments;

  /// No description provided for @expensesOverBy.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String expensesOverBy(String amount);

  /// No description provided for @expensesAmountRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String expensesAmountRemaining(String amount);

  /// No description provided for @expensesPaymentsTotal.
  ///
  /// In en, this message translates to:
  /// **'Payments total {amount}'**
  String expensesPaymentsTotal(String amount);

  /// No description provided for @expensesShareExceeds.
  ///
  /// In en, this message translates to:
  /// **'Each share must not exceed {amount}'**
  String expensesShareExceeds(String amount);

  /// No description provided for @expensesEnterValidSplits.
  ///
  /// In en, this message translates to:
  /// **'Enter valid split amounts'**
  String get expensesEnterValidSplits;

  /// No description provided for @expensesPercentOver100.
  ///
  /// In en, this message translates to:
  /// **'Each share must be 100% or less'**
  String get expensesPercentOver100;

  /// No description provided for @expensesEnterValidPercents.
  ///
  /// In en, this message translates to:
  /// **'Enter valid split percentages'**
  String get expensesEnterValidPercents;

  /// No description provided for @expensesPercentReduce.
  ///
  /// In en, this message translates to:
  /// **'Total {total}% — reduce by {over}%'**
  String expensesPercentReduce(String total, String over);

  /// No description provided for @expensesPercentRemaining.
  ///
  /// In en, this message translates to:
  /// **'Total {total}% — {remaining}% remaining'**
  String expensesPercentRemaining(String total, String remaining);

  /// No description provided for @expensesPayerLine.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount}'**
  String expensesPayerLine(String name, String amount);

  /// No description provided for @expensesPreviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String expensesPreviewTotal(String amount);

  /// No description provided for @settlementsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit settlement'**
  String get settlementsEditTitle;

  /// No description provided for @settlementsRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record settlement'**
  String get settlementsRecordTitle;

  /// No description provided for @settlementsFromPays.
  ///
  /// In en, this message translates to:
  /// **'FROM (PAYS)'**
  String get settlementsFromPays;

  /// No description provided for @settlementsToReceives.
  ///
  /// In en, this message translates to:
  /// **'TO (RECEIVES)'**
  String get settlementsToReceives;

  /// No description provided for @settlementsAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get settlementsAmount;

  /// No description provided for @settlementsNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'NOTE (OPTIONAL)'**
  String get settlementsNoteOptional;

  /// No description provided for @settlementsNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Cash, bank transfer…'**
  String get settlementsNoteHint;

  /// No description provided for @settlementsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settlementsSaveChanges;

  /// No description provided for @settlementsRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get settlementsRecordPayment;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileYourName;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get profileLanguage;

  /// No description provided for @profileLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device unless you choose a language.'**
  String get profileLanguageHint;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileLanguageSystem;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get profileAppearance;

  /// No description provided for @profileAppearanceHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device unless you choose Light or Dark.'**
  String get profileAppearanceHint;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileDefaultCurrencyHeader.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT CURRENCY'**
  String get profileDefaultCurrencyHeader;

  /// No description provided for @profileDefaultCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Used for new scenes and the home summary.'**
  String get profileDefaultCurrencyHint;

  /// No description provided for @profileDefaultCurrencySheet.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get profileDefaultCurrencySheet;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get profileManage;

  /// No description provided for @profilePeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get profilePeople;

  /// No description provided for @profilePeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No people yet} =1{1 person} other{{count} people}}'**
  String profilePeopleCount(int count);

  /// No description provided for @profileDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get profileDataBackup;

  /// No description provided for @profileDataBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export or import your data'**
  String get profileDataBackupSubtitle;

  /// No description provided for @profileApp.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get profileApp;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String profileAboutApp(String appName);

  /// No description provided for @profileAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy, contact, feedback & share'**
  String get profileAboutSubtitle;

  /// No description provided for @profileVersionFooter.
  ///
  /// In en, this message translates to:
  /// **'{appName} v{version} ({build})'**
  String profileVersionFooter(String appName, String version, String build);

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// No description provided for @peopleAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get peopleAddPerson;

  /// No description provided for @peopleAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alice'**
  String get peopleAddHint;

  /// No description provided for @peopleEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get peopleEditName;

  /// No description provided for @peopleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete person?'**
  String get peopleDeleteTitle;

  /// No description provided for @peopleDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your people list? This cannot be undone.'**
  String peopleDeleteBody(String name);

  /// No description provided for @peopleIntro.
  ///
  /// In en, this message translates to:
  /// **'Everyone added across your scenes.'**
  String get peopleIntro;

  /// No description provided for @peopleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get peopleSearchHint;

  /// No description provided for @peopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No people yet. Tap + to add someone.'**
  String get peopleEmpty;

  /// No description provided for @peopleNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No people match your search.'**
  String get peopleNoMatch;

  /// No description provided for @peopleSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on a person for edit and delete'**
  String get peopleSwipeHint;

  /// No description provided for @peopleSceneCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not in any scenes} =1{1 scene} other{{count} scenes}}'**
  String peopleSceneCount(int count);

  /// No description provided for @peopleDetailCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amounts shown in each scene\'s currency'**
  String get peopleDetailCurrencySubtitle;

  /// No description provided for @peopleDetailEmptyScenes.
  ///
  /// In en, this message translates to:
  /// **'Not a member of any scenes yet.'**
  String get peopleDetailEmptyScenes;

  /// No description provided for @peopleDetailAllSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled across scenes'**
  String get peopleDetailAllSettled;

  /// No description provided for @peopleDetailOpenBalances.
  ///
  /// In en, this message translates to:
  /// **'Open balances in some scenes'**
  String get peopleDetailOpenBalances;

  /// No description provided for @peopleDetailGets.
  ///
  /// In en, this message translates to:
  /// **'{name} gets'**
  String peopleDetailGets(String name);

  /// No description provided for @peopleDetailWillGive.
  ///
  /// In en, this message translates to:
  /// **'{name} will give'**
  String peopleDetailWillGive(String name);

  /// No description provided for @peopleDetailSettledInScene.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get peopleDetailSettledInScene;

  /// No description provided for @peopleDetailNoDebts.
  ///
  /// In en, this message translates to:
  /// **'No open debts in this scene'**
  String get peopleDetailNoDebts;

  /// No description provided for @peopleDetailViewExpenses.
  ///
  /// In en, this message translates to:
  /// **'View expense shares'**
  String get peopleDetailViewExpenses;

  /// No description provided for @peopleDetailExpensesSection.
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get peopleDetailExpensesSection;

  /// No description provided for @dataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get dataTitle;

  /// No description provided for @dataWebBlurb.
  ///
  /// In en, this message translates to:
  /// **'Backup export and import are available in the mobile and desktop apps. Your data is stored locally in this browser.'**
  String get dataWebBlurb;

  /// No description provided for @dataNativeBlurb.
  ///
  /// In en, this message translates to:
  /// **'Export a backup, then save it on your device or share it elsewhere. Import replaces everything on this device.'**
  String get dataNativeBlurb;

  /// No description provided for @dataExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get dataExportBackup;

  /// No description provided for @dataImportBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get dataImportBackup;

  /// No description provided for @dataCouldNotExport.
  ///
  /// In en, this message translates to:
  /// **'Could not export backup.'**
  String get dataCouldNotExport;

  /// No description provided for @dataSaveBackupDialog.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get dataSaveBackupDialog;

  /// No description provided for @dataBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get dataBackupSaved;

  /// No description provided for @dataCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save backup.'**
  String get dataCouldNotSave;

  /// No description provided for @dataShareSubject.
  ///
  /// In en, this message translates to:
  /// **'SceneSplit backup'**
  String get dataShareSubject;

  /// No description provided for @dataShareText.
  ///
  /// In en, this message translates to:
  /// **'SceneSplit database backup'**
  String get dataShareText;

  /// No description provided for @dataCouldNotShare.
  ///
  /// In en, this message translates to:
  /// **'Could not share backup.'**
  String get dataCouldNotShare;

  /// No description provided for @dataImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup?'**
  String get dataImportTitle;

  /// No description provided for @dataImportBody.
  ///
  /// In en, this message translates to:
  /// **'Importing a backup will replace all data currently in SceneSplit on this device. This cannot be undone.'**
  String get dataImportBody;

  /// No description provided for @dataImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully.'**
  String get dataImportSuccess;

  /// No description provided for @dataCouldNotImport.
  ///
  /// In en, this message translates to:
  /// **'Could not import backup.'**
  String get dataCouldNotImport;

  /// No description provided for @dataBackupReady.
  ///
  /// In en, this message translates to:
  /// **'Backup ready'**
  String get dataBackupReady;

  /// No description provided for @dataSaveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get dataSaveToDevice;

  /// No description provided for @dataSaveToDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose folder and filename'**
  String get dataSaveToDeviceSubtitle;

  /// No description provided for @dataShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get dataShare;

  /// No description provided for @dataShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send via email, Drive, AirDrop, etc.'**
  String get dataShareSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutCouldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get aboutCouldNotOpenEmail;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Split expenses with friends.\nOffline-first. No account required.'**
  String get aboutTagline;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTermsOfService;

  /// No description provided for @aboutContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get aboutContactUs;

  /// No description provided for @aboutEmailSupportSubject.
  ///
  /// In en, this message translates to:
  /// **'SceneSplit Support'**
  String get aboutEmailSupportSubject;

  /// No description provided for @aboutSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get aboutSendFeedback;

  /// No description provided for @aboutEmailFeedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'SceneSplit Feedback'**
  String get aboutEmailFeedbackSubject;

  /// No description provided for @aboutSuggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest a feature'**
  String get aboutSuggestFeature;

  /// No description provided for @aboutEmailFeatureSubject.
  ///
  /// In en, this message translates to:
  /// **'SceneSplit Feature Suggestion'**
  String get aboutEmailFeatureSubject;

  /// No description provided for @aboutRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate {appName}'**
  String aboutRateApp(String appName);

  /// No description provided for @aboutShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get aboutShareApp;

  /// No description provided for @aboutShareAppSubject.
  ///
  /// In en, this message translates to:
  /// **'Try {appName}'**
  String aboutShareAppSubject(String appName);

  /// No description provided for @aboutShareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out {appName} — split expenses with friends. Offline-first, no account required.\n\n{links}'**
  String aboutShareAppMessage(String appName, String links);

  /// No description provided for @aboutCouldNotShare.
  ///
  /// In en, this message translates to:
  /// **'Could not share the app.'**
  String get aboutCouldNotShare;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} {appName}'**
  String aboutCopyright(int year, String appName);

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load document: {error}'**
  String legalLoadError(String error);

  /// No description provided for @sharedSettledTitle.
  ///
  /// In en, this message translates to:
  /// **'You are all settled up'**
  String get sharedSettledTitle;

  /// No description provided for @sharedSettledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No outstanding balances in this scene'**
  String get sharedSettledSubtitle;

  /// No description provided for @sharedYouGet.
  ///
  /// In en, this message translates to:
  /// **'You get'**
  String get sharedYouGet;

  /// No description provided for @sharedYouWillGive.
  ///
  /// In en, this message translates to:
  /// **'You will give'**
  String get sharedYouWillGive;

  /// No description provided for @sharedNoChartData.
  ///
  /// In en, this message translates to:
  /// **'No data to chart'**
  String get sharedNoChartData;

  /// No description provided for @sharedTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get sharedTotal;

  /// No description provided for @sharedPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String sharedPercentLabel(String percent);

  /// No description provided for @sharedChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get sharedChooseLanguage;

  /// No description provided for @sharedChooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get sharedChooseCurrency;

  /// No description provided for @sharedCurrencySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code, or symbol'**
  String get sharedCurrencySearchHint;

  /// No description provided for @sharedNoCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get sharedNoCurrenciesFound;

  /// No description provided for @sharedCurrencyFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'{code} — {name}'**
  String sharedCurrencyFieldLabel(String code, String name);

  /// No description provided for @sharedCustomEmoji.
  ///
  /// In en, this message translates to:
  /// **'Custom emoji'**
  String get sharedCustomEmoji;

  /// No description provided for @moneyTwoPayers.
  ///
  /// In en, this message translates to:
  /// **'{a} & {b}'**
  String moneyTwoPayers(String a, String b);

  /// No description provided for @moneyManyPayers.
  ///
  /// In en, this message translates to:
  /// **'{name} +{count}'**
  String moneyManyPayers(String name, int count);

  /// No description provided for @supportEmailBodyFooter.
  ///
  /// In en, this message translates to:
  /// **'\n\n---\nApp: {appName} {version} ({build})'**
  String supportEmailBodyFooter(String appName, String version, String build);

  /// No description provided for @errorUserNameTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone named \"{name}\" already exists.'**
  String errorUserNameTaken(String name);

  /// No description provided for @errorCannotDeleteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete yourself.'**
  String get errorCannotDeleteSelf;

  /// No description provided for @errorUserHasFinancialActivity.
  ///
  /// In en, this message translates to:
  /// **'This person has expenses or settlements and cannot be deleted.'**
  String get errorUserHasFinancialActivity;

  /// No description provided for @errorBackupCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Could not open backup file. It may be corrupt or not a SQLite database.'**
  String get errorBackupCorrupt;

  /// No description provided for @errorBackupVersionMismatch.
  ///
  /// In en, this message translates to:
  /// **'This backup is from a different app version and cannot be imported.'**
  String get errorBackupVersionMismatch;

  /// No description provided for @errorBackupNotSceneSplit.
  ///
  /// In en, this message translates to:
  /// **'This file does not look like a SceneSplit backup.'**
  String get errorBackupNotSceneSplit;

  /// No description provided for @errorBackupExportWeb.
  ///
  /// In en, this message translates to:
  /// **'Backup export is not available on web. Use the mobile or desktop app to export backups.'**
  String get errorBackupExportWeb;

  /// No description provided for @errorBackupImportWeb.
  ///
  /// In en, this message translates to:
  /// **'Backup import is not available on web. Use the mobile or desktop app to import backups.'**
  String get errorBackupImportWeb;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePortuguese;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
