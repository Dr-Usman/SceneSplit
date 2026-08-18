// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return '問題が発生しました: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'エラー: $error';
  }

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonDelete => '削除';

  @override
  String get commonSave => '保存';

  @override
  String get commonEdit => '編集';

  @override
  String get commonImport => 'インポート';

  @override
  String commonYouSuffix(String name) {
    return '$name（あなた）';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '「$name」はすでにリストにあります。';
  }

  @override
  String get commonUnknown => '不明';

  @override
  String get onboardingTagline => '友だちと経費を割り勘。\nアカウント不要、手間いらず。';

  @override
  String get onboardingYourName => 'お名前';

  @override
  String get onboardingNameHint => '例: 山田 太郎';

  @override
  String get onboardingCurrency => '通貨';

  @override
  String get onboardingGetStarted => 'はじめる';

  @override
  String get onboardingPrivacyNote => 'すべてのデータは端末内に保存されます。';

  @override
  String get homeNewGroup => '新しいシーン';

  @override
  String get homeGroupsHeader => 'シーン';

  @override
  String get homeYouGetByGroup => 'シーン別の受取予定';

  @override
  String get homeYouWillGiveByGroup => 'シーン別の支払予定';

  @override
  String get homeBreakdownSubtitle => '各シーンの通貨で表示';

  @override
  String get homeYouWillGet => '受取予定';

  @override
  String get homeYouWillGive => '支払予定';

  @override
  String get homeSettledUp => '精算済み';

  @override
  String get homeCardYouWillGet => '受取予定';

  @override
  String get navScenes => 'シーン';

  @override
  String get navBalances => '残高';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get balancesTitle => '残高';

  @override
  String get balancesSubtitle => 'シーン全体で誰が誰に借りているかを確認。';

  @override
  String get balancesWho => '誰が';

  @override
  String get balancesWhom => '誰に';

  @override
  String get balancesFilterTitle => '誰が誰に借りているか';

  @override
  String get balancesFilterHint => '誰が誰に借りているかを選んで未清算の負債を絞り込みます。';

  @override
  String get balancesAnyone => '誰でも';

  @override
  String get balancesOwes => '借りている';

  @override
  String get balancesClear => 'クリア';

  @override
  String get balancesShowResults => '結果を表示';

  @override
  String get balancesClearSelection => '選択をクリア';

  @override
  String get balancesEmpty => 'シーン全体で未精算の借りはありません。';

  @override
  String get balancesEmptyFiltered => 'この選択に一致する未精算はありません。';

  @override
  String get balancesPickPerson => '人を選択';

  @override
  String get balancesNoPeopleFound => '該当する人がいません';

  @override
  String balancesCurrencySection(String currency) {
    return '$currency';
  }

  @override
  String get balancesOpenDebtTotal => '未精算';

  @override
  String balancesOpenDebtCurrency(String currency) {
    return '未精算（$currency）';
  }

  @override
  String get balancesYouAreOwed => '受け取り';

  @override
  String get balancesYouOwe => '支払い';

  @override
  String get balancesHeroOwed => '受け取る';

  @override
  String get balancesHeroOwe => '払う';

  @override
  String balancesHeroOwedBreakdown(String name) {
    return '$nameに借りがある人';
  }

  @override
  String balancesHeroOweBreakdown(String name) {
    return '$nameが借りている相手';
  }

  @override
  String get balancesHeroNetLabel => '差引';

  @override
  String balancesHeroNetOwes(String debtor, String creditor) {
    return '$debtorは$creditorに借りがある';
  }

  @override
  String get balancesShareTotal => '負担合計';

  @override
  String get balancesExpenseTotal => '支出合計';

  @override
  String get balancesScenesHeader => 'シーン';

  @override
  String get balancesSettleInScene => '精算する';

  @override
  String get balancesViewShares => '支出の負担';

  @override
  String get balancesPairSettled => 'この二人の間は精算済みです';

  @override
  String balancesPairBetween(String a, String b) {
    return '$a と $b';
  }

  @override
  String get balancesSelectPerson => 'タップして選択';

  @override
  String get homeCardYouWillGive => '支払予定';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人',
      one: '1人',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'シーンがありません';

  @override
  String get homeEmptyBody => '旅行、ディナー、シェアハウス用の\nシーンを作成して割り勘を始めましょう。';

  @override
  String get groupsNewGroup => '新しいシーン';

  @override
  String get groupsEditGroup => 'シーンを編集';

  @override
  String get groupsGroupName => 'シーン名';

  @override
  String get groupsNameHint => '例: 日本旅行';

  @override
  String get groupsIcon => 'アイコン';

  @override
  String get groupsCurrency => '通貨';

  @override
  String get groupsMembers => 'メンバー';

  @override
  String get groupsAddMemberHint => '名前でメンバーを追加';

  @override
  String get groupsCreateGroup => 'シーンを作成';

  @override
  String get groupsSaveChanges => '変更を保存';

  @override
  String get groupsRemovalBlockedYou => 'このシーンに経費または精算があるため、削除できません。';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name にはこのシーンの経費または精算があるため、削除できません。';
  }

  @override
  String get groupsThisMember => 'このメンバー';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'シーンを削除';

  @override
  String get groupsAddExpense => '経費を追加';

  @override
  String get groupsExpenseBreakdown => '経費の内訳';

  @override
  String groupsMemberShareTitle(String name) {
    return '$nameの分担';
  }

  @override
  String groupsMemberShareExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の支出',
      one: '1件の支出',
    );
    return '$_temp0';
  }

  @override
  String groupsMemberShareOfAmount(String amount) {
    return '/ $amount';
  }

  @override
  String get groupsMemberShareTotalLabel => '分担合計';

  @override
  String groupsMembersHeader(int count) {
    return 'メンバー ($count)';
  }

  @override
  String get groupsManage => '管理';

  @override
  String get groupsWhoOwesWhom => '誰が誰に払うか';

  @override
  String get groupsSettleUp => '精算';

  @override
  String get groupsShareBalances => '共有';

  @override
  String groupsShareBalancesSubject(String groupName) {
    return '残高 — $groupName';
  }

  @override
  String groupsShareBalancesText(String groupName) {
    return '$groupName の貸し借り';
  }

  @override
  String get groupsShareAllSettled => '精算済み';

  @override
  String get groupsExpenseShares => '費用の分担';

  @override
  String get groupsCouldNotShareBalances => '残高を共有できませんでした。';

  @override
  String get groupsShareExpenses => '共有';

  @override
  String get groupsShareExpensesRangeTitle => '日付を選択';

  @override
  String get groupsShareExpensesRangeAll => 'すべての日付';

  @override
  String get groupsShareExpensesRangeAllSubtitle => 'このシーンのすべての支出';

  @override
  String get groupsShareExpensesRangeMonth => '今月';

  @override
  String get groupsShareExpensesRangeMonthSubtitle => '1日から今日まで';

  @override
  String get groupsShareExpensesRangeLast7 => '過去7日間';

  @override
  String get groupsShareExpensesRangeLast7Subtitle => '今日を含む';

  @override
  String get groupsShareExpensesRangeCustom => '期間を指定';

  @override
  String get groupsShareExpensesRangeCustomSubtitle => '開始日と終了日を選ぶ';

  @override
  String get groupsShareExpensesFormatTitle => '共有方法';

  @override
  String get groupsShareExpensesFormatImage => '画像';

  @override
  String get groupsShareExpensesFormatImageSubtitle => 'コンパクトなリストを画像で';

  @override
  String get groupsShareExpensesFormatText => 'テキスト';

  @override
  String get groupsShareExpensesFormatTextSubtitle => '支払った人と各自の分担額';

  @override
  String get groupsShareExpensesEmptyRange => 'この期間に支出はありません。';

  @override
  String get groupsCouldNotShareExpenses => '支出を共有できませんでした。';

  @override
  String groupsShareExpensesSubject(String groupName) {
    return '支出 — $groupName';
  }

  @override
  String groupsShareExpensesCaption(String groupName) {
    return '$groupNameの支出';
  }

  @override
  String groupsShareExpensesCaptionWithRange(String groupName, String range) {
    return '$groupNameの支出（$range）';
  }

  @override
  String groupsShareExpensesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人',
      one: '1人',
    );
    return '$_temp0';
  }

  @override
  String groupsShareExpensesAndMore(int count) {
    return 'ほか$count件';
  }

  @override
  String groupsShareExpensesPayerPaidDatePeople(
    String payer,
    String date,
    String people,
  ) {
    return '$payerが支払い · $date · $people';
  }

  @override
  String groupsShareExpensesPaidDateAmount(
    String payer,
    String date,
    String amount,
  ) {
    return '$payerが支払い · $date · $amount';
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
    return '合計: $amount';
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
  String get groupsShareExpensesByPerson => '人別';

  @override
  String get groupsSettlements => '精算履歴';

  @override
  String get groupsExpenses => '経費';

  @override
  String get groupsSettlementsTitle => '精算履歴';

  @override
  String get groupsExpensesTitle => '経費';

  @override
  String groupsSettlementsScreenTitle(String groupName) {
    return '$groupName · 精算履歴';
  }

  @override
  String groupsExpensesScreenTitle(String groupName) {
    return '$groupName · 経費';
  }

  @override
  String groupsViewAllCount(int count) {
    return 'すべて見る（$count）';
  }

  @override
  String get groupsEmptySettlementsBody => '精算はまだ記録されていません。';

  @override
  String get groupsSwipeToDeleteHint => '左にスワイプして削除';

  @override
  String get groupsDeleteExpenseTitle => '経費を削除しますか？';

  @override
  String groupsDeleteExpenseBody(String title) {
    return '「$title」をこのシーンから削除しますか？';
  }

  @override
  String get groupsDeleteGroupTitle => 'シーンを削除しますか？';

  @override
  String groupsDeleteGroupBody(String name) {
    return '「$name」とすべての経費を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get groupsDeleteSettlementTitle => '精算を削除しますか？';

  @override
  String get groupsDeleteSettlementBody => 'この記録された支払いを削除しますか？';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from → $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer が支払い · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from が $to に支払い';
  }

  @override
  String get groupsEmptyExpensesTitle => '経費がありません';

  @override
  String get groupsEmptyExpensesBody => '「経費を追加」をタップして最初の請求を分割しましょう。';

  @override
  String get expensesEditTitle => '経費を編集';

  @override
  String get expensesAddTitle => '経費を追加';

  @override
  String get expensesDetailTitle => '経費';

  @override
  String get expensesNotFound => '経費が見つかりません';

  @override
  String get expensesAmount => '金額';

  @override
  String get expensesAmountSubtitle => '請求の合計金額';

  @override
  String get expensesDescription => '説明';

  @override
  String get expensesDescriptionHint => '例: 夕食、食料品、タクシー';

  @override
  String get expensesDate => '日付';

  @override
  String get expensesPaidBy => '支払者';

  @override
  String get expensesPaidBySubtitle => 'この請求の支払者';

  @override
  String get expensesPaidByHeader => '支払者';

  @override
  String get expensesPayerSingle => '1人';

  @override
  String get expensesPayerMultiple => '複数';

  @override
  String get expensesSplit => '分割';

  @override
  String get expensesSplitSubtitle => '費用の分け方';

  @override
  String get expensesSplitEqual => '均等';

  @override
  String get expensesSplitExact => '金額指定';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => '金額指定';

  @override
  String get expensesSplitByPercentage => '割合指定';

  @override
  String get expensesSplitEqually => '均等に分割';

  @override
  String get expensesSplitBreakdown => '分割の内訳';

  @override
  String get expensesNote => 'メモ';

  @override
  String get expensesNoteHint => '任意のメモ';

  @override
  String get expensesSaveChanges => '変更を保存';

  @override
  String get expensesSaveExpense => '経費を保存';

  @override
  String get expensesSubtitlePaid => 'が支払い';

  @override
  String get expensesSubtitleAlsoPaid => 'も支払い';

  @override
  String expensesPaymentExceeds(String amount) {
    return '各支払いは $amount を超えられません';
  }

  @override
  String get expensesEnterValidPayments => '有効な支払金額を入力してください';

  @override
  String expensesOverBy(String amount) {
    return '$amount 超過';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return '残り $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return '支払合計 $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return '各分担は $amount を超えられません';
  }

  @override
  String get expensesEnterValidSplits => '有効な分割金額を入力してください';

  @override
  String get expensesPercentOver100 => '各分担は100%以下にしてください';

  @override
  String get expensesEnterValidPercents => '有効な分割割合を入力してください';

  @override
  String expensesPercentReduce(String total, String over) {
    return '合計 $total% — $over% 減らしてください';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return '合計 $total% — 残り $remaining%';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return '合計: $amount';
  }

  @override
  String get settlementsEditTitle => '精算を編集';

  @override
  String get settlementsRecordTitle => '精算を記録';

  @override
  String get settlementsFromPays => '支払者';

  @override
  String get settlementsToReceives => '受取者';

  @override
  String get settlementsAmount => '金額';

  @override
  String get settlementsNoteOptional => 'メモ（任意）';

  @override
  String get settlementsNoteHint => '現金、銀行振込…';

  @override
  String get settlementsSaveChanges => '変更を保存';

  @override
  String get settlementsRecordPayment => '支払いを記録';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileYourName => 'お名前';

  @override
  String get profileLanguage => '言語';

  @override
  String get profileLanguageHint => '言語を選ばない場合は端末の設定に従います。';

  @override
  String get profileLanguageSystem => 'システム';

  @override
  String get profileAppearance => '外観';

  @override
  String get profileAppearanceHint => 'ライトまたはダークを選ばない場合は端末の設定に従います。';

  @override
  String get profileThemeSystem => 'システム';

  @override
  String get profileThemeLight => 'ライト';

  @override
  String get profileThemeDark => 'ダーク';

  @override
  String get profileDefaultCurrencyHeader => 'デフォルト通貨';

  @override
  String get profileDefaultCurrencyHint => '新しいシーンとホームの概要に使用されます。';

  @override
  String get profileDefaultCurrencySheet => 'デフォルト通貨';

  @override
  String get profileManage => '管理';

  @override
  String get profilePeople => 'メンバー';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人',
      one: '1人',
      zero: 'メンバーがいません',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'データとバックアップ';

  @override
  String get profileDataBackupSubtitle => 'データのエクスポートまたはインポート';

  @override
  String get profileApp => 'アプリ';

  @override
  String profileAboutApp(String appName) {
    return '$appName について';
  }

  @override
  String get profileAboutSubtitle => 'プライバシー、連絡、フィードバックと共有';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'メンバー';

  @override
  String get peopleAddPerson => 'メンバーを追加';

  @override
  String get peopleAddHint => '例: さくら';

  @override
  String get peopleEditName => '名前を編集';

  @override
  String get peopleDeleteTitle => 'メンバーを削除しますか？';

  @override
  String peopleDeleteBody(String name) {
    return '$name をメンバーリストから削除しますか？この操作は元に戻せません。';
  }

  @override
  String get peopleIntro => 'すべてのシーンに追加されたメンバー。';

  @override
  String get peopleSearchHint => '名前で検索';

  @override
  String get peopleEmpty => 'メンバーがいません。+ をタップして追加してください。';

  @override
  String get peopleNoMatch => '検索に一致するメンバーがいません。';

  @override
  String get peopleSwipeHint => '左にスワイプして編集・削除';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countシーン',
      one: '1シーン',
      zero: 'シーンなし',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle => '各シーンの通貨で表示';

  @override
  String get peopleDetailEmptyScenes => 'まだどのシーンのメンバーでもありません。';

  @override
  String get peopleDetailAllSettled => 'すべてのシーンで清算済み';

  @override
  String get peopleDetailOpenBalances => '一部のシーンに未清算があります';

  @override
  String peopleDetailGets(String name) {
    return '$nameの合計受取';
  }

  @override
  String peopleDetailWillGive(String name) {
    return '$nameの合計負債';
  }

  @override
  String get peopleDetailYourTotalCredit => 'あなたの合計受取';

  @override
  String get peopleDetailYourTotalDebt => 'あなたの合計負債';

  @override
  String get peopleDetailSettledInScene => '清算済み';

  @override
  String get peopleDetailNoDebts => 'このシーンに未清算の債務はありません';

  @override
  String get peopleDetailViewExpenses => '分担を表示';

  @override
  String get peopleDetailExpensesSection => '支出';

  @override
  String get dataTitle => 'データとバックアップ';

  @override
  String get dataWebBlurb =>
      'バックアップのエクスポートとインポートはモバイルおよびデスクトップアプリで利用できます。データはこのブラウザにローカル保存されています。';

  @override
  String get dataNativeBlurb =>
      'バックアップをエクスポートし、端末に保存するか他の場所で共有してください。インポートするとこの端末のすべてのデータが置き換わります。';

  @override
  String get dataExportBackup => 'バックアップをエクスポート';

  @override
  String get dataImportBackup => 'バックアップをインポート';

  @override
  String get dataCouldNotExport => 'バックアップをエクスポートできませんでした。';

  @override
  String get dataSaveBackupDialog => 'バックアップを保存';

  @override
  String get dataBackupSaved => 'バックアップを保存しました。';

  @override
  String get dataCouldNotSave => 'バックアップを保存できませんでした。';

  @override
  String get dataShareSubject => 'SceneSplit バックアップ';

  @override
  String get dataShareText => 'SceneSplit データベースバックアップ';

  @override
  String get dataCouldNotShare => 'バックアップを共有できませんでした。';

  @override
  String get dataImportTitle => 'バックアップをインポートしますか？';

  @override
  String get dataImportBody =>
      'バックアップをインポートすると、この端末の SceneSplit のすべてのデータが置き換わります。この操作は元に戻せません。';

  @override
  String get dataImportSuccess => 'バックアップを正常にインポートしました。';

  @override
  String get dataCouldNotImport => 'バックアップをインポートできませんでした。';

  @override
  String get dataBackupReady => 'バックアップの準備完了';

  @override
  String get dataSaveToDevice => '端末に保存';

  @override
  String get dataSaveToDeviceSubtitle => 'フォルダとファイル名を選択';

  @override
  String get dataShare => '共有';

  @override
  String get dataShareSubtitle => 'メール、Drive、AirDrop などで送信';

  @override
  String get aboutTitle => 'アプリについて';

  @override
  String get aboutCouldNotOpenEmail => 'メールアプリを開けませんでした';

  @override
  String aboutVersion(String version, String build) {
    return 'バージョン $version ($build)';
  }

  @override
  String get aboutTagline => '友だちと経費を割り勘。\nオフライン優先。アカウント不要。';

  @override
  String get aboutPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get aboutTermsOfService => '利用規約';

  @override
  String get aboutContactUs => 'お問い合わせ';

  @override
  String get aboutEmailSupportSubject => 'SceneSplit サポート';

  @override
  String get aboutSendFeedback => 'フィードバックを送信';

  @override
  String get aboutEmailFeedbackSubject => 'SceneSplit フィードバック';

  @override
  String get aboutSuggestFeature => '機能を提案';

  @override
  String get aboutEmailFeatureSubject => 'SceneSplit 機能提案';

  @override
  String aboutRateApp(String appName) {
    return '$appName を評価';
  }

  @override
  String get aboutShareApp => 'アプリを共有';

  @override
  String aboutShareAppSubject(String appName) {
    return '$appName を試してみて';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return '$appName をチェック — 友だちと支出を割り勘。オフライン優先、アカウント不要。\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'アプリを共有できませんでした。';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'プライバシーポリシー';

  @override
  String get legalTermsTitle => '利用規約';

  @override
  String legalLoadError(String error) {
    return 'ドキュメントを読み込めませんでした: $error';
  }

  @override
  String get sharedSettledTitle => 'すべて精算済みです';

  @override
  String get sharedSettledSubtitle => 'このシーンに未払い残高はありません';

  @override
  String get sharedYouGet => '受取予定';

  @override
  String get sharedYouWillGive => '支払予定';

  @override
  String get sharedNoChartData => 'グラフに表示するデータがありません';

  @override
  String get sharedTotal => '合計';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => '言語を選択';

  @override
  String get sharedChooseCurrency => '通貨を選択';

  @override
  String get sharedCurrencySearchHint => '名前、コード、記号で検索';

  @override
  String get sharedNoCurrenciesFound => '通貨が見つかりません';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'カスタム絵文字';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a と $b';
  }

  @override
  String moneyManyPayers(String name, int count) {
    return '$name +$count';
  }

  @override
  String supportEmailBodyFooter(String appName, String version, String build) {
    return '\n\n---\nアプリ: $appName $version ($build)';
  }

  @override
  String errorUserNameTaken(String name) {
    return '「$name」という名前の人がすでに存在します。';
  }

  @override
  String get errorCannotDeleteSelf => '自分自身を削除することはできません。';

  @override
  String get errorUserHasFinancialActivity => 'この人には経費または精算があるため、削除できません。';

  @override
  String get errorBackupCorrupt =>
      'バックアップファイルを開けませんでした。破損しているか、SQLite データベースではない可能性があります。';

  @override
  String get errorBackupVersionMismatch =>
      'このバックアップは別のアプリバージョンのもので、インポートできません。';

  @override
  String get errorBackupNotSceneSplit => 'このファイルは SceneSplit のバックアップではないようです。';

  @override
  String get errorBackupExportWeb =>
      'Web ではバックアップのエクスポートは利用できません。モバイルまたはデスクトップアプリをご利用ください。';

  @override
  String get errorBackupImportWeb =>
      'Web ではバックアップのインポートは利用できません。モバイルまたはデスクトップアプリをご利用ください。';

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
