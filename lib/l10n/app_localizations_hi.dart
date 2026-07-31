// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'कुछ गलत हो गया: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonImport => 'आयात करें';

  @override
  String commonYouSuffix(String name) {
    return '$name (आप)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '\"$name\" पहले से सूची में है।';
  }

  @override
  String get commonUnknown => 'अज्ञात';

  @override
  String get onboardingTagline =>
      'दोस्तों के साथ खर्च बाँटें।\nकोई खाता नहीं, कोई झंझट नहीं।';

  @override
  String get onboardingYourName => 'आपका नाम';

  @override
  String get onboardingNameHint => 'जैसे राहुल शर्मा';

  @override
  String get onboardingCurrency => 'मुद्रा';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingPrivacyNote => 'सब कुछ आपके डिवाइस पर ही रहता है।';

  @override
  String get homeNewGroup => 'नया समूह';

  @override
  String get homeGroupsHeader => 'समूह';

  @override
  String get homeYouGetByGroup => 'समूह के अनुसार आपको मिलेगा';

  @override
  String get homeYouWillGiveByGroup => 'समूह के अनुसार आपको देना होगा';

  @override
  String get homeBreakdownSubtitle =>
      'प्रत्येक समूह की मुद्रा में राशि दिखाई गई है';

  @override
  String get homeYouWillGet => 'आपको मिलेगा';

  @override
  String get homeYouWillGive => 'आपको देना होगा';

  @override
  String get homeSettledUp => 'निपटान हो गया';

  @override
  String get homeCardYouWillGet => 'आपको मिलेगा';

  @override
  String get homeCardYouWillGive => 'आपको देना होगा';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'अभी कोई समूह नहीं';

  @override
  String get homeEmptyBody =>
      'अपनी यात्रा, घर या\nदोस्तों के लिए समूह बनाकर बँटवारा शुरू करें।';

  @override
  String get groupsNewGroup => 'नया समूह';

  @override
  String get groupsEditGroup => 'समूह संपादित करें';

  @override
  String get groupsGroupName => 'समूह का नाम';

  @override
  String get groupsNameHint => 'जैसे जापान यात्रा';

  @override
  String get groupsIcon => 'आइकन';

  @override
  String get groupsCurrency => 'मुद्रा';

  @override
  String get groupsMembers => 'सदस्य';

  @override
  String get groupsAddMemberHint => 'नाम से सदस्य जोड़ें';

  @override
  String get groupsCreateGroup => 'समूह बनाएँ';

  @override
  String get groupsSaveChanges => 'बदलाव सहेजें';

  @override
  String get groupsRemovalBlockedYou =>
      'इस समूह में आपके खर्च या निपटान हैं, इसलिए आपको हटाया नहीं जा सकता।';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name के इस समूह में खर्च या निपटान हैं, इसलिए उन्हें हटाया नहीं जा सकता।';
  }

  @override
  String get groupsThisMember => 'यह सदस्य';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'समूह हटाएँ';

  @override
  String get groupsAddExpense => 'खर्च जोड़ें';

  @override
  String get groupsExpenseBreakdown => 'खर्च विवरण';

  @override
  String groupsMembersHeader(int count) {
    return 'सदस्य ($count)';
  }

  @override
  String get groupsManage => 'प्रबंधित करें';

  @override
  String get groupsWhoOwesWhom => 'किस पर कितना बकाया';

  @override
  String get groupsSettleUp => 'निपटान करें';

  @override
  String get groupsSettlements => 'निपटान';

  @override
  String get groupsExpenses => 'खर्च';

  @override
  String get groupsDeleteExpenseTitle => 'खर्च हटाएँ?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'क्या \"$title\" को इस समूह से हटाना है?';
  }

  @override
  String get groupsDeleteGroupTitle => 'समूह हटाएँ?';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'क्या \"$name\" और उसके सभी खर्च हटाने हैं? यह वापस नहीं हो सकता।';
  }

  @override
  String get groupsDeleteSettlementTitle => 'निपटान हटाएँ?';

  @override
  String get groupsDeleteSettlementBody => 'क्या यह दर्ज भुगतान हटाना है?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from पर $to का बकाया';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer ने भुगतान किया · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from ने $to को भुगतान किया';
  }

  @override
  String get groupsEmptyExpensesTitle => 'अभी कोई खर्च नहीं';

  @override
  String get groupsEmptyExpensesBody =>
      'पहला बिल बाँटने के लिए \"खर्च जोड़ें\" पर टैप करें।';

  @override
  String get expensesEditTitle => 'खर्च संपादित करें';

  @override
  String get expensesAddTitle => 'खर्च जोड़ें';

  @override
  String get expensesDetailTitle => 'खर्च';

  @override
  String get expensesNotFound => 'खर्च नहीं मिला';

  @override
  String get expensesAmount => 'राशि';

  @override
  String get expensesAmountSubtitle => 'कुल बिल की राशि';

  @override
  String get expensesDescription => 'विवरण';

  @override
  String get expensesDescriptionHint => 'जैसे डिनर, किराना, टैक्सी';

  @override
  String get expensesDate => 'तारीख';

  @override
  String get expensesPaidBy => 'भुगतानकर्ता';

  @override
  String get expensesPaidBySubtitle => 'इस बिल का भुगतान किसने किया';

  @override
  String get expensesPaidByHeader => 'भुगतानकर्ता';

  @override
  String get expensesPayerSingle => 'एक';

  @override
  String get expensesPayerMultiple => 'कई';

  @override
  String get expensesSplit => 'बँटवारा';

  @override
  String get expensesSplitSubtitle => 'खर्च कैसे बाँटना है';

  @override
  String get expensesSplitEqual => 'बराबर';

  @override
  String get expensesSplitExact => 'सटीक';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'सटीक राशि';

  @override
  String get expensesSplitByPercentage => 'प्रतिशत के अनुसार';

  @override
  String get expensesSplitEqually => 'बराबर बाँटें';

  @override
  String get expensesSplitBreakdown => 'बँटवारा विवरण';

  @override
  String get expensesNote => 'नोट';

  @override
  String get expensesNoteHint => 'वैकल्पिक नोट';

  @override
  String get expensesSaveChanges => 'बदलाव सहेजें';

  @override
  String get expensesSaveExpense => 'खर्च सहेजें';

  @override
  String get expensesSubtitlePaid => 'ने भुगतान किया';

  @override
  String get expensesSubtitleAlsoPaid => 'ने भी भुगतान किया';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'प्रत्येक भुगतान $amount से अधिक नहीं हो सकता';
  }

  @override
  String get expensesEnterValidPayments => 'मान्य भुगतान राशि दर्ज करें';

  @override
  String expensesOverBy(String amount) {
    return '$amount अधिक';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return '$amount शेष';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'कुल भुगतान $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'प्रत्येक हिस्सा $amount से अधिक नहीं हो सकता';
  }

  @override
  String get expensesEnterValidSplits => 'मान्य बँटवारा राशि दर्ज करें';

  @override
  String get expensesPercentOver100 =>
      'प्रत्येक हिस्सा 100% या उससे कम होना चाहिए';

  @override
  String get expensesEnterValidPercents => 'मान्य बँटवारा प्रतिशत दर्ज करें';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'कुल $total% — $over% कम करें';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'कुल $total% — $remaining% शेष';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return 'कुल: $amount';
  }

  @override
  String get settlementsEditTitle => 'निपटान संपादित करें';

  @override
  String get settlementsRecordTitle => 'निपटान दर्ज करें';

  @override
  String get settlementsFromPays => 'से (भुगतानकर्ता)';

  @override
  String get settlementsToReceives => 'को (प्राप्तकर्ता)';

  @override
  String get settlementsAmount => 'राशि';

  @override
  String get settlementsNoteOptional => 'नोट (वैकल्पिक)';

  @override
  String get settlementsNoteHint => 'नकद, बैंक ट्रांसफर…';

  @override
  String get settlementsSaveChanges => 'बदलाव सहेजें';

  @override
  String get settlementsRecordPayment => 'भुगतान दर्ज करें';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get profileYourName => 'आपका नाम';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLanguageHint =>
      'जब तक आप भाषा न चुनें, डिवाइस की भाषा का पालन होगा।';

  @override
  String get profileLanguageSystem => 'सिस्टम';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get profileAppearanceHint =>
      'जब तक आप लाइट या डार्क न चुनें, डिवाइस की सेटिंग का पालन होगा।';

  @override
  String get profileThemeSystem => 'सिस्टम';

  @override
  String get profileThemeLight => 'लाइट';

  @override
  String get profileThemeDark => 'डार्क';

  @override
  String get profileDefaultCurrencyHeader => 'डिफ़ॉल्ट मुद्रा';

  @override
  String get profileDefaultCurrencyHint =>
      'नए समूहों और होम सारांश के लिए उपयोग होती है।';

  @override
  String get profileDefaultCurrencySheet => 'डिफ़ॉल्ट मुद्रा';

  @override
  String get profileManage => 'प्रबंधित करें';

  @override
  String get profilePeople => 'लोग';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count व्यक्ति',
      one: '1 व्यक्ति',
      zero: 'अभी कोई व्यक्ति नहीं',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'डेटा और बैकअप';

  @override
  String get profileDataBackupSubtitle => 'अपना डेटा निर्यात या आयात करें';

  @override
  String get profileApp => 'ऐप';

  @override
  String profileAboutApp(String appName) {
    return '$appName के बारे में';
  }

  @override
  String get profileAboutSubtitle => 'गोपनीयता, संपर्क, प्रतिक्रिया और शेयर';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'लोग';

  @override
  String get peopleAddPerson => 'व्यक्ति जोड़ें';

  @override
  String get peopleAddHint => 'जैसे प्रिया';

  @override
  String get peopleEditName => 'नाम संपादित करें';

  @override
  String get peopleDeleteTitle => 'व्यक्ति हटाएँ?';

  @override
  String peopleDeleteBody(String name) {
    return 'क्या $name को अपनी लोगों की सूची से हटाना है? यह वापस नहीं हो सकता।';
  }

  @override
  String get peopleIntro => 'आपके सभी समूहों में जोड़े गए लोग।';

  @override
  String get peopleSearchHint => 'नाम से खोजें';

  @override
  String get peopleEmpty =>
      'अभी कोई व्यक्ति नहीं। जोड़ने के लिए + पर टैप करें।';

  @override
  String get peopleNoMatch => 'आपकी खोज से कोई व्यक्ति मेल नहीं खाता।';

  @override
  String get dataTitle => 'डेटा और बैकअप';

  @override
  String get dataWebBlurb =>
      'मोबाइल और डेस्कटॉप ऐप में बैकअप निर्यात और आयात उपलब्ध है। आपका डेटा इस ब्राउज़र में स्थानीय रूप से संग्रहीत है।';

  @override
  String get dataNativeBlurb =>
      'बैकअप निर्यात करें, फिर इसे अपने डिवाइस पर सहेजें या कहीं और साझा करें। आयात इस डिवाइस का सारा डेटा बदल देगा।';

  @override
  String get dataExportBackup => 'बैकअप निर्यात करें';

  @override
  String get dataImportBackup => 'बैकअप आयात करें';

  @override
  String get dataCouldNotExport => 'बैकअप निर्यात नहीं हो सका।';

  @override
  String get dataSaveBackupDialog => 'बैकअप सहेजें';

  @override
  String get dataBackupSaved => 'बैकअप सहेजा गया।';

  @override
  String get dataCouldNotSave => 'बैकअप सहेजा नहीं जा सका।';

  @override
  String get dataShareSubject => 'SceneSplit बैकअप';

  @override
  String get dataShareText => 'SceneSplit डेटाबेस बैकअप';

  @override
  String get dataCouldNotShare => 'बैकअप साझा नहीं हो सका।';

  @override
  String get dataImportTitle => 'बैकअप आयात करें?';

  @override
  String get dataImportBody =>
      'बैकअप आयात करने से इस डिवाइस पर SceneSplit का सारा मौजूदा डेटा बदल जाएगा। यह वापस नहीं हो सकता।';

  @override
  String get dataImportSuccess => 'बैकअप सफलतापूर्वक आयात हुआ।';

  @override
  String get dataCouldNotImport => 'बैकअप आयात नहीं हो सका।';

  @override
  String get dataBackupReady => 'बैकअप तैयार';

  @override
  String get dataSaveToDevice => 'डिवाइस पर सहेजें';

  @override
  String get dataSaveToDeviceSubtitle => 'फ़ोल्डर और फ़ाइल नाम चुनें';

  @override
  String get dataShare => 'साझा करें';

  @override
  String get dataShareSubtitle => 'ईमेल, Drive, AirDrop आदि से भेजें';

  @override
  String get aboutTitle => 'परिचय';

  @override
  String get aboutCouldNotOpenEmail => 'ईमेल ऐप नहीं खुल सका';

  @override
  String aboutVersion(String version, String build) {
    return 'संस्करण $version ($build)';
  }

  @override
  String get aboutTagline =>
      'दोस्तों के साथ खर्च बाँटें।\nऑफ़लाइन-प्रथम। कोई खाता आवश्यक नहीं।';

  @override
  String get aboutPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get aboutTermsOfService => 'सेवा की शर्तें';

  @override
  String get aboutContactUs => 'हमसे संपर्क करें';

  @override
  String get aboutEmailSupportSubject => 'SceneSplit सहायता';

  @override
  String get aboutSendFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get aboutEmailFeedbackSubject => 'SceneSplit प्रतिक्रिया';

  @override
  String get aboutSuggestFeature => 'सुविधा सुझाएँ';

  @override
  String get aboutEmailFeatureSubject => 'SceneSplit सुविधा सुझाव';

  @override
  String aboutRateApp(String appName) {
    return '$appName को रेट करें';
  }

  @override
  String get aboutShareApp => 'ऐप शेयर करें';

  @override
  String aboutShareAppSubject(String appName) {
    return '$appName आज़माएँ';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return '$appName देखें — दोस्तों के साथ खर्च बाँटें। ऑफ़लाइन-पहले, बिना खाते के।\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'ऐप शेयर नहीं हो सका।';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'गोपनीयता नीति';

  @override
  String get legalTermsTitle => 'सेवा की शर्तें';

  @override
  String legalLoadError(String error) {
    return 'दस्तावेज़ लोड नहीं हो सका: $error';
  }

  @override
  String get sharedSettledTitle => 'आप सभी का निपटान कर चुके हैं';

  @override
  String get sharedSettledSubtitle => 'इस समूह में कोई बकाया शेष नहीं';

  @override
  String get sharedYouGet => 'आपको मिलेगा';

  @override
  String get sharedYouWillGive => 'आपको देना होगा';

  @override
  String get sharedNoChartData => 'चार्ट के लिए कोई डेटा नहीं';

  @override
  String get sharedTotal => 'कुल';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => 'भाषा चुनें';

  @override
  String get sharedChooseCurrency => 'मुद्रा चुनें';

  @override
  String get sharedCurrencySearchHint => 'नाम, कोड या प्रतीक से खोजें';

  @override
  String get sharedNoCurrenciesFound => 'कोई मुद्रा नहीं मिली';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'कस्टम इमोजी';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a और $b';
  }

  @override
  String moneyManyPayers(String name, int count) {
    return '$name +$count';
  }

  @override
  String supportEmailBodyFooter(String appName, String version, String build) {
    return '\n\n---\nऐप: $appName $version ($build)';
  }

  @override
  String errorUserNameTaken(String name) {
    return '\"$name\" नाम का कोई व्यक्ति पहले से मौजूद है।';
  }

  @override
  String get errorCannotDeleteSelf => 'आप स्वयं को हटा नहीं सकते।';

  @override
  String get errorUserHasFinancialActivity =>
      'इस व्यक्ति के खर्च या निपटान हैं, इसलिए उन्हें हटाया नहीं जा सकता।';

  @override
  String get errorBackupCorrupt =>
      'बैकअप फ़ाइल नहीं खुल सकी। हो सकता है यह दूषित हो या SQLite डेटाबेस न हो।';

  @override
  String get errorBackupVersionMismatch =>
      'यह बैकअप किसी अन्य ऐप संस्करण का है और आयात नहीं हो सकता।';

  @override
  String get errorBackupNotSceneSplit =>
      'यह फ़ाइल SceneSplit बैकअप जैसी नहीं लगती।';

  @override
  String get errorBackupExportWeb =>
      'वेब पर बैकअप निर्यात उपलब्ध नहीं है। बैकअप निर्यात के लिए मोबाइल या डेस्कटॉप ऐप का उपयोग करें।';

  @override
  String get errorBackupImportWeb =>
      'वेब पर बैकअप आयात उपलब्ध नहीं है। बैकअप आयात के लिए मोबाइल या डेस्कटॉप ऐप का उपयोग करें।';

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
