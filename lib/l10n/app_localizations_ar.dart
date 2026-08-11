// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'حدث خطأ ما: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'خطأ: $error';
  }

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonImport => 'استيراد';

  @override
  String commonYouSuffix(String name) {
    return '$name (أنت)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '\"$name\" موجود بالفعل في القائمة.';
  }

  @override
  String get commonUnknown => 'غير معروف';

  @override
  String get onboardingTagline =>
      'قسّم النفقات مع الأصدقاء.\nبدون حسابات، بدون تعقيد.';

  @override
  String get onboardingYourName => 'اسمك';

  @override
  String get onboardingNameHint => 'مثال: أحمد محمد';

  @override
  String get onboardingCurrency => 'العملة';

  @override
  String get onboardingGetStarted => 'ابدأ';

  @override
  String get onboardingPrivacyNote => 'كل شيء يبقى على جهازك.';

  @override
  String get homeNewGroup => 'مشهد جديد';

  @override
  String get homeGroupsHeader => 'المشاهد';

  @override
  String get homeYouGetByGroup => 'ما ستستلمه حسب المشهد';

  @override
  String get homeYouWillGiveByGroup => 'ما ستدفعه حسب المشهد';

  @override
  String get homeBreakdownSubtitle => 'المبالغ معروضة بعملة كل مشهد';

  @override
  String get homeYouWillGet => 'ستستلم';

  @override
  String get homeYouWillGive => 'ستدفع';

  @override
  String get homeSettledUp => 'تمت التسوية';

  @override
  String get homeCardYouWillGet => 'ستستلم';

  @override
  String get navScenes => 'المشاهد';

  @override
  String get navBalances => 'الأرصدة';

  @override
  String get navProfile => 'الملف';

  @override
  String get balancesTitle => 'الأرصدة';

  @override
  String get balancesSubtitle => 'اطلع على من يدين لمن عبر مشاهدك.';

  @override
  String get balancesWho => 'من';

  @override
  String get balancesWhom => 'لمن';

  @override
  String get balancesFilterTitle => 'من يدين لمن';

  @override
  String get balancesFilterHint => 'اختر من يدين لمن لتصفية الديون المفتوحة.';

  @override
  String get balancesAnyone => 'أي شخص';

  @override
  String get balancesOwes => 'مدين لـ';

  @override
  String get balancesClear => 'مسح';

  @override
  String get balancesShowResults => 'عرض النتائج';

  @override
  String get balancesClearSelection => 'مسح التحديد';

  @override
  String get balancesEmpty => 'لا توجد ديون مفتوحة في مشاهدك.';

  @override
  String get balancesEmptyFiltered => 'لا توجد ديون مفتوحة تطابق هذا الاختيار.';

  @override
  String get balancesPickPerson => 'اختر شخصًا';

  @override
  String get balancesNoPeopleFound => 'لم يتم العثور على أشخاص';

  @override
  String balancesCurrencySection(String currency) {
    return '$currency';
  }

  @override
  String get balancesOpenDebtTotal => 'دين مفتوح';

  @override
  String balancesOpenDebtCurrency(String currency) {
    return 'دين مفتوح ($currency)';
  }

  @override
  String get balancesYouAreOwed => 'مستحق لك';

  @override
  String get balancesYouOwe => 'عليك دين';

  @override
  String get balancesHeroOwed => 'يحصلون';

  @override
  String get balancesHeroOwe => 'يمدينون';

  @override
  String balancesHeroOwedBreakdown(String name) {
    return 'من يدين لـ $name';
  }

  @override
  String balancesHeroOweBreakdown(String name) {
    return 'لمن يدين $name';
  }

  @override
  String get balancesHeroNetLabel => 'الصافي';

  @override
  String balancesHeroNetOwes(String debtor, String creditor) {
    return '$debtor يدين لـ $creditor';
  }

  @override
  String get balancesShareTotal => 'إجمالي الحصة';

  @override
  String get balancesExpenseTotal => 'إجمالي المصروفات';

  @override
  String get balancesScenesHeader => 'المشاهد';

  @override
  String get balancesSettleInScene => 'تسوية';

  @override
  String get balancesViewShares => 'حصص المصروفات';

  @override
  String get balancesPairSettled => 'تمت التسوية بين هذين الشخصين';

  @override
  String get balancesSelectPerson => 'اضغط للاختيار';

  @override
  String get homeCardYouWillGive => 'ستدفع';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'لا توجد مشاهد بعد';

  @override
  String get homeEmptyBody =>
      'أنشئ مشهداً لرحلة أو عشاء\nأو منزل مشترك لبدء تقسيم النفقات.';

  @override
  String get groupsNewGroup => 'مشهد جديد';

  @override
  String get groupsEditGroup => 'تعديل المشهد';

  @override
  String get groupsGroupName => 'اسم المشهد';

  @override
  String get groupsNameHint => 'مثال: رحلة إلى اليابان';

  @override
  String get groupsIcon => 'الأيقونة';

  @override
  String get groupsCurrency => 'العملة';

  @override
  String get groupsMembers => 'الأعضاء';

  @override
  String get groupsAddMemberHint => 'أضف عضوًا بالاسم';

  @override
  String get groupsCreateGroup => 'إنشاء مشهد';

  @override
  String get groupsSaveChanges => 'حفظ التغييرات';

  @override
  String get groupsRemovalBlockedYou =>
      'لديك نفقات أو تسويات في هذا المشهد ولا يمكن إزالتك.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return 'لدى $name نفقات أو تسويات في هذا المشهد ولا يمكن إزالته.';
  }

  @override
  String get groupsThisMember => 'هذا العضو';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'حذف المشهد';

  @override
  String get groupsAddExpense => 'إضافة نفقة';

  @override
  String get groupsExpenseBreakdown => 'تفصيل النفقات';

  @override
  String groupsMemberShareTitle(String name) {
    return 'حصة $name';
  }

  @override
  String groupsMemberShareExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروفات',
      one: 'مصروف واحد',
    );
    return '$_temp0';
  }

  @override
  String groupsMemberShareOfAmount(String amount) {
    return 'من $amount';
  }

  @override
  String get groupsMemberShareTotalLabel => 'الحصة الإجمالية';

  @override
  String groupsMembersHeader(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String get groupsManage => 'إدارة';

  @override
  String get groupsWhoOwesWhom => 'من يدين لمن';

  @override
  String get groupsSettleUp => 'تسوية';

  @override
  String get groupsShareBalances => 'مشاركة';

  @override
  String groupsShareBalancesSubject(String groupName) {
    return 'الأرصدة — $groupName';
  }

  @override
  String groupsShareBalancesText(String groupName) {
    return 'من يدين لمن في $groupName';
  }

  @override
  String get groupsShareAllSettled => 'تمت التسوية بالكامل';

  @override
  String get groupsExpenseShares => 'حصص المصروفات';

  @override
  String get groupsCouldNotShareBalances => 'تعذّرت مشاركة الأرصدة.';

  @override
  String get groupsSettlements => 'التسويات';

  @override
  String get groupsExpenses => 'النفقات';

  @override
  String get groupsSettlementsTitle => 'التسويات';

  @override
  String get groupsExpensesTitle => 'النفقات';

  @override
  String groupsSettlementsScreenTitle(String groupName) {
    return '$groupName · التسويات';
  }

  @override
  String groupsExpensesScreenTitle(String groupName) {
    return '$groupName · النفقات';
  }

  @override
  String groupsViewAllCount(int count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get groupsEmptySettlementsBody => 'لا توجد تسويات مسجّلة بعد.';

  @override
  String get groupsSwipeToDeleteHint => 'اسحب لليسار للحذف';

  @override
  String get groupsDeleteExpenseTitle => 'حذف النفقة؟';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'هل تريد إزالة \"$title\" من هذا المشهد؟';
  }

  @override
  String get groupsDeleteGroupTitle => 'حذف المشهد؟';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'هل تريد حذف \"$name\" وجميع نفقاتها؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'حذف التسوية؟';

  @override
  String get groupsDeleteSettlementBody => 'هل تريد إزالة هذا الدفع المسجّل؟';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from يدين لـ $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return 'دفع $payer · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return 'دفع $from لـ $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'لا توجد نفقات بعد';

  @override
  String get groupsEmptyExpensesBody =>
      'اضغط \"إضافة نفقة\" لتقسيم أول فاتورة.';

  @override
  String get expensesEditTitle => 'تعديل النفقة';

  @override
  String get expensesAddTitle => 'إضافة نفقة';

  @override
  String get expensesDetailTitle => 'نفقة';

  @override
  String get expensesNotFound => 'النفقة غير موجودة';

  @override
  String get expensesAmount => 'المبلغ';

  @override
  String get expensesAmountSubtitle => 'إجمالي مبلغ الفاتورة';

  @override
  String get expensesDescription => 'الوصف';

  @override
  String get expensesDescriptionHint => 'مثال: عشاء، بقالة، تاكسي';

  @override
  String get expensesDate => 'التاريخ';

  @override
  String get expensesPaidBy => 'دفع بواسطة';

  @override
  String get expensesPaidBySubtitle => 'من غطّى هذه الفاتورة';

  @override
  String get expensesPaidByHeader => 'دفع بواسطة';

  @override
  String get expensesPayerSingle => 'واحد';

  @override
  String get expensesPayerMultiple => 'متعدد';

  @override
  String get expensesSplit => 'تقسيم';

  @override
  String get expensesSplitSubtitle => 'كيفية تقسيم التكلفة';

  @override
  String get expensesSplitEqual => 'متساوٍ';

  @override
  String get expensesSplitExact => 'دقيق';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'مبالغ دقيقة';

  @override
  String get expensesSplitByPercentage => 'حسب النسبة المئوية';

  @override
  String get expensesSplitEqually => 'تقسيم متساوٍ';

  @override
  String get expensesSplitBreakdown => 'تفصيل التقسيم';

  @override
  String get expensesNote => 'ملاحظة';

  @override
  String get expensesNoteHint => 'ملاحظة اختيارية';

  @override
  String get expensesSaveChanges => 'حفظ التغييرات';

  @override
  String get expensesSaveExpense => 'حفظ النفقة';

  @override
  String get expensesSubtitlePaid => 'دفع';

  @override
  String get expensesSubtitleAlsoPaid => 'دفع أيضًا';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'يجب ألا يتجاوز كل دفع $amount';
  }

  @override
  String get expensesEnterValidPayments => 'أدخل مبالغ دفع صالحة';

  @override
  String expensesOverBy(String amount) {
    return 'زيادة بمقدار $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'متبقٍ $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'إجمالي المدفوعات $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'يجب ألا يتجاوز كل حصة $amount';
  }

  @override
  String get expensesEnterValidSplits => 'أدخل مبالغ تقسيم صالحة';

  @override
  String get expensesPercentOver100 => 'يجب أن تكون كل حصة 100% أو أقل';

  @override
  String get expensesEnterValidPercents => 'أدخل نسب تقسيم صالحة';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'الإجمالي $total% — قلّل بمقدار $over%';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'الإجمالي $total% — متبقٍ $remaining%';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return 'الإجمالي: $amount';
  }

  @override
  String get settlementsEditTitle => 'تعديل التسوية';

  @override
  String get settlementsRecordTitle => 'تسجيل تسوية';

  @override
  String get settlementsFromPays => 'من (يدفع)';

  @override
  String get settlementsToReceives => 'إلى (يستلم)';

  @override
  String get settlementsAmount => 'المبلغ';

  @override
  String get settlementsNoteOptional => 'ملاحظة (اختياري)';

  @override
  String get settlementsNoteHint => 'نقد، تحويل بنكي…';

  @override
  String get settlementsSaveChanges => 'حفظ التغييرات';

  @override
  String get settlementsRecordPayment => 'تسجيل الدفع';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileYourName => 'اسمك';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLanguageHint => 'تتبع لغة جهازك ما لم تختر لغة.';

  @override
  String get profileLanguageSystem => 'النظام';

  @override
  String get profileAppearance => 'المظهر';

  @override
  String get profileAppearanceHint =>
      'يتبع إعدادات جهازك ما لم تختر فاتحًا أو داكنًا.';

  @override
  String get profileThemeSystem => 'النظام';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get profileDefaultCurrencyHeader => 'العملة الافتراضية';

  @override
  String get profileDefaultCurrencyHint =>
      'تُستخدم للمشاهد الجديدة وملخص الصفحة الرئيسية.';

  @override
  String get profileDefaultCurrencySheet => 'العملة الافتراضية';

  @override
  String get profileManage => 'إدارة';

  @override
  String get profilePeople => 'الأشخاص';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      one: 'شخص واحد',
      zero: 'لا يوجد أشخاص بعد',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'البيانات والنسخ الاحتياطي';

  @override
  String get profileDataBackupSubtitle => 'صدّر أو استورد بياناتك';

  @override
  String get profileApp => 'التطبيق';

  @override
  String profileAboutApp(String appName) {
    return 'حول $appName';
  }

  @override
  String get profileAboutSubtitle => 'الخصوصية، التواصل، الملاحظات والمشاركة';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'الأشخاص';

  @override
  String get peopleAddPerson => 'إضافة شخص';

  @override
  String get peopleAddHint => 'مثال: سارة';

  @override
  String get peopleEditName => 'تعديل الاسم';

  @override
  String get peopleDeleteTitle => 'حذف الشخص؟';

  @override
  String peopleDeleteBody(String name) {
    return 'هل تريد إزالة $name من قائمة الأشخاص؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get peopleIntro => 'جميع الأشخاص المضافين عبر مشاهدك.';

  @override
  String get peopleSearchHint => 'البحث بالاسم';

  @override
  String get peopleEmpty => 'لا يوجد أشخاص بعد. اضغط + لإضافة شخص.';

  @override
  String get peopleNoMatch => 'لا يوجد أشخاص مطابقون لبحثك.';

  @override
  String get peopleSwipeHint => 'اسحب لليسار للتعديل أو الحذف';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشاهد',
      one: 'مشهد واحد',
      zero: 'ليس في أي مشهد',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle => 'المبالغ معروضة بعملة كل مشهد';

  @override
  String get peopleDetailEmptyScenes => 'ليس عضواً في أي مشهد بعد.';

  @override
  String get peopleDetailAllSettled => 'تم تسوية الكل عبر المشاهد';

  @override
  String get peopleDetailOpenBalances => 'أرصدة مفتوحة في بعض المشاهد';

  @override
  String peopleDetailGets(String name) {
    return 'إجمالي مستحقات $name';
  }

  @override
  String peopleDetailWillGive(String name) {
    return 'إجمالي دين $name';
  }

  @override
  String get peopleDetailYourTotalCredit => 'إجمالي مستحقاتك';

  @override
  String get peopleDetailYourTotalDebt => 'إجمالي دينك';

  @override
  String get peopleDetailSettledInScene => 'مسوّى';

  @override
  String get peopleDetailNoDebts => 'لا ديون مفتوحة في هذا المشهد';

  @override
  String get peopleDetailViewExpenses => 'عرض حصص المصروفات';

  @override
  String get peopleDetailExpensesSection => 'المصروفات';

  @override
  String get dataTitle => 'البيانات والنسخ الاحتياطي';

  @override
  String get dataWebBlurb =>
      'تصدير واستيراد النسخ الاحتياطي متاح في تطبيقات الجوال وسطح المكتب. بياناتك مخزّنة محليًا في هذا المتصفّح.';

  @override
  String get dataNativeBlurb =>
      'صدّر نسخة احتياطية، ثم احفظها على جهازك أو شاركها في مكان آخر. الاستيراد يستبدل كل شيء على هذا الجهاز.';

  @override
  String get dataExportBackup => 'تصدير النسخة الاحتياطية';

  @override
  String get dataImportBackup => 'استيراد النسخة الاحتياطية';

  @override
  String get dataCouldNotExport => 'تعذّر تصدير النسخة الاحتياطية.';

  @override
  String get dataSaveBackupDialog => 'حفظ النسخة الاحتياطية';

  @override
  String get dataBackupSaved => 'تم حفظ النسخة الاحتياطية.';

  @override
  String get dataCouldNotSave => 'تعذّر حفظ النسخة الاحتياطية.';

  @override
  String get dataShareSubject => 'نسخة SceneSplit الاحتياطية';

  @override
  String get dataShareText => 'نسخة SceneSplit الاحتياطية لقاعدة البيانات';

  @override
  String get dataCouldNotShare => 'تعذّر مشاركة النسخة الاحتياطية.';

  @override
  String get dataImportTitle => 'استيراد النسخة الاحتياطية؟';

  @override
  String get dataImportBody =>
      'استيراد نسخة احتياطية سيستبدل جميع البيانات الحالية في SceneSplit على هذا الجهاز. لا يمكن التراجع عن هذا.';

  @override
  String get dataImportSuccess => 'تم استيراد النسخة الاحتياطية بنجاح.';

  @override
  String get dataCouldNotImport => 'تعذّر استيراد النسخة الاحتياطية.';

  @override
  String get dataBackupReady => 'النسخة الاحتياطية جاهزة';

  @override
  String get dataSaveToDevice => 'حفظ على الجهاز';

  @override
  String get dataSaveToDeviceSubtitle => 'اختر المجلد واسم الملف';

  @override
  String get dataShare => 'مشاركة';

  @override
  String get dataShareSubtitle => 'إرسال عبر البريد أو Drive أو AirDrop وغيرها';

  @override
  String get aboutTitle => 'حول';

  @override
  String get aboutCouldNotOpenEmail => 'تعذّر فتح تطبيق البريد';

  @override
  String aboutVersion(String version, String build) {
    return 'الإصدار $version ($build)';
  }

  @override
  String get aboutTagline =>
      'قسّم النفقات مع الأصدقاء.\nيعمل دون اتصال. لا يلزم حساب.';

  @override
  String get aboutPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutTermsOfService => 'شروط الخدمة';

  @override
  String get aboutContactUs => 'تواصل معنا';

  @override
  String get aboutEmailSupportSubject => 'دعم SceneSplit';

  @override
  String get aboutSendFeedback => 'إرسال ملاحظات';

  @override
  String get aboutEmailFeedbackSubject => 'ملاحظات SceneSplit';

  @override
  String get aboutSuggestFeature => 'اقتراح ميزة';

  @override
  String get aboutEmailFeatureSubject => 'اقتراح ميزة لـ SceneSplit';

  @override
  String aboutRateApp(String appName) {
    return 'قيّم $appName';
  }

  @override
  String get aboutShareApp => 'مشاركة التطبيق';

  @override
  String aboutShareAppSubject(String appName) {
    return 'جرّب $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'تعرّف على $appName — قسّم النفقات مع الأصدقاء. يعمل دون اتصال، بلا حساب.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'تعذّرت مشاركة التطبيق.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get legalTermsTitle => 'شروط الخدمة';

  @override
  String legalLoadError(String error) {
    return 'تعذّر تحميل المستند: $error';
  }

  @override
  String get sharedSettledTitle => 'تمت تسوية جميع الحسابات';

  @override
  String get sharedSettledSubtitle => 'لا توجد أرصدة مستحقة في هذا المشهد';

  @override
  String get sharedYouGet => 'ستستلم';

  @override
  String get sharedYouWillGive => 'ستدفع';

  @override
  String get sharedNoChartData => 'لا توجد بيانات للرسم البياني';

  @override
  String get sharedTotal => 'الإجمالي';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => 'اختر اللغة';

  @override
  String get sharedChooseCurrency => 'اختر العملة';

  @override
  String get sharedCurrencySearchHint => 'البحث بالاسم أو الرمز أو الكود';

  @override
  String get sharedNoCurrenciesFound => 'لم يتم العثور على عملات';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'رمز تعبيري مخصص';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a و$b';
  }

  @override
  String moneyManyPayers(String name, int count) {
    return '$name +$count';
  }

  @override
  String supportEmailBodyFooter(String appName, String version, String build) {
    return '\n\n---\nالتطبيق: $appName $version ($build)';
  }

  @override
  String errorUserNameTaken(String name) {
    return 'يوجد شخص باسم \"$name\" بالفعل.';
  }

  @override
  String get errorCannotDeleteSelf => 'لا يمكنك حذف نفسك.';

  @override
  String get errorUserHasFinancialActivity =>
      'لدى هذا الشخص نفقات أو تسويات ولا يمكن حذفه.';

  @override
  String get errorBackupCorrupt =>
      'تعذّر فتح ملف النسخة الاحتياطية. قد يكون تالفًا أو ليس قاعدة بيانات SQLite.';

  @override
  String get errorBackupVersionMismatch =>
      'هذه النسخة الاحتياطية من إصدار مختلف من التطبيق ولا يمكن استيرادها.';

  @override
  String get errorBackupNotSceneSplit =>
      'يبدو أن هذا الملف ليس نسخة احتياطية من SceneSplit.';

  @override
  String get errorBackupExportWeb =>
      'تصدير النسخة الاحتياطية غير متاح على الويب. استخدم تطبيق الجوال أو سطح المكتب لتصدير النسخ الاحتياطية.';

  @override
  String get errorBackupImportWeb =>
      'استيراد النسخة الاحتياطية غير متاح على الويب. استخدم تطبيق الجوال أو سطح المكتب لاستيراد النسخ الاحتياطية.';

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
