// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Fehler: $error';
  }

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonImport => 'Importieren';

  @override
  String commonYouSuffix(String name) {
    return '$name (du)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '«$name» ist bereits in der Liste.';
  }

  @override
  String get commonUnknown => 'Unbekannt';

  @override
  String get onboardingTagline =>
      'Ausgaben mit Freunden teilen.\nKeine Konten, kein Aufwand.';

  @override
  String get onboardingYourName => 'DEIN NAME';

  @override
  String get onboardingNameHint => 'z. B. Max Mustermann';

  @override
  String get onboardingCurrency => 'WÄHRUNG';

  @override
  String get onboardingGetStarted => 'Loslegen';

  @override
  String get onboardingPrivacyNote => 'Alles bleibt auf deinem Gerät.';

  @override
  String get homeNewGroup => 'Neue Gruppe';

  @override
  String get homeGroupsHeader => 'GRUPPEN';

  @override
  String get homeYouGetByGroup => 'Du erhältst nach Gruppe';

  @override
  String get homeYouWillGiveByGroup => 'Du schuldest nach Gruppe';

  @override
  String get homeBreakdownSubtitle =>
      'Beträge in der Währung jeder Gruppe angezeigt';

  @override
  String get homeYouWillGet => 'Du erhältst';

  @override
  String get homeYouWillGive => 'Du schuldest';

  @override
  String get homeSettledUp => 'ausgeglichen';

  @override
  String get homeCardYouWillGet => 'du erhältst';

  @override
  String get homeCardYouWillGive => 'du schuldest';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Noch keine Gruppen';

  @override
  String get homeEmptyBody =>
      'Erstelle eine Gruppe für deine Reise, dein\nZuhause oder Freunde und beginne zu teilen.';

  @override
  String get groupsNewGroup => 'Neue Gruppe';

  @override
  String get groupsEditGroup => 'Gruppe bearbeiten';

  @override
  String get groupsGroupName => 'GRUPPENNAME';

  @override
  String get groupsNameHint => 'z. B. Reise nach Japan';

  @override
  String get groupsIcon => 'SYMBOL';

  @override
  String get groupsCurrency => 'WÄHRUNG';

  @override
  String get groupsMembers => 'MITGLIEDER';

  @override
  String get groupsAddMemberHint => 'Mitglied nach Namen hinzufügen';

  @override
  String get groupsCreateGroup => 'Gruppe erstellen';

  @override
  String get groupsSaveChanges => 'Änderungen speichern';

  @override
  String get groupsRemovalBlockedYou =>
      'Du hast Ausgaben oder Ausgleichszahlungen in dieser Gruppe und kannst nicht entfernt werden.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name hat Ausgaben oder Ausgleichszahlungen in dieser Gruppe und kann nicht entfernt werden.';
  }

  @override
  String get groupsThisMember => 'Dieses Mitglied';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Gruppe löschen';

  @override
  String get groupsAddExpense => 'Ausgabe hinzufügen';

  @override
  String get groupsExpenseBreakdown => 'AUSGABENÜBERSICHT';

  @override
  String groupsMemberShareTitle(String name) {
    return 'Anteil von $name';
  }

  @override
  String groupsMembersHeader(int count) {
    return 'MITGLIEDER ($count)';
  }

  @override
  String get groupsManage => 'Verwalten';

  @override
  String get groupsWhoOwesWhom => 'WER SCHULDET WEM';

  @override
  String get groupsSettleUp => 'Ausgleichen';

  @override
  String get groupsSettlements => 'AUSGLEICHSZAHLUNGEN';

  @override
  String get groupsExpenses => 'AUSGABEN';

  @override
  String get groupsDeleteExpenseTitle => 'Ausgabe löschen?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return '«$title» aus dieser Gruppe entfernen?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Gruppe löschen?';

  @override
  String groupsDeleteGroupBody(String name) {
    return '«$name» und alle zugehörigen Ausgaben löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'Ausgleichszahlung löschen?';

  @override
  String get groupsDeleteSettlementBody => 'Diese erfasste Zahlung entfernen?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from schuldet $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer hat bezahlt · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from hat an $to gezahlt';
  }

  @override
  String get groupsEmptyExpensesTitle => 'Noch keine Ausgaben';

  @override
  String get groupsEmptyExpensesBody =>
      'Tippe auf «Ausgabe hinzufügen», um deine erste Rechnung zu teilen.';

  @override
  String get expensesEditTitle => 'Ausgabe bearbeiten';

  @override
  String get expensesAddTitle => 'Ausgabe hinzufügen';

  @override
  String get expensesDetailTitle => 'Ausgabe';

  @override
  String get expensesNotFound => 'Ausgabe nicht gefunden';

  @override
  String get expensesAmount => 'Betrag';

  @override
  String get expensesAmountSubtitle => 'Gesamtbetrag der Rechnung';

  @override
  String get expensesDescription => 'Beschreibung';

  @override
  String get expensesDescriptionHint => 'z. B. Abendessen, Einkäufe, Taxi';

  @override
  String get expensesDate => 'Datum';

  @override
  String get expensesPaidBy => 'Bezahlt von';

  @override
  String get expensesPaidBySubtitle => 'Wer diese Rechnung übernommen hat';

  @override
  String get expensesPaidByHeader => 'BEZAHLT VON';

  @override
  String get expensesPayerSingle => 'Einzeln';

  @override
  String get expensesPayerMultiple => 'Mehrere';

  @override
  String get expensesSplit => 'Aufteilung';

  @override
  String get expensesSplitSubtitle => 'Wie die Kosten aufgeteilt werden';

  @override
  String get expensesSplitEqual => 'Gleich';

  @override
  String get expensesSplitExact => 'Exakt';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Exakte Beträge';

  @override
  String get expensesSplitByPercentage => 'Nach Prozent';

  @override
  String get expensesSplitEqually => 'Gleichmäßig aufteilen';

  @override
  String get expensesSplitBreakdown => 'AUFTEILUNGSÜBERSICHT';

  @override
  String get expensesNote => 'Notiz';

  @override
  String get expensesNoteHint => 'Optionale Notiz';

  @override
  String get expensesSaveChanges => 'Änderungen speichern';

  @override
  String get expensesSaveExpense => 'Ausgabe speichern';

  @override
  String get expensesSubtitlePaid => 'hat bezahlt';

  @override
  String get expensesSubtitleAlsoPaid => 'hat auch bezahlt';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Jede Zahlung darf $amount nicht überschreiten';
  }

  @override
  String get expensesEnterValidPayments => 'Gültige Zahlungsbeträge eingeben';

  @override
  String expensesOverBy(String amount) {
    return 'Überschuss von $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'Noch $amount übrig';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Zahlungen insgesamt $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Jeder Anteil darf $amount nicht überschreiten';
  }

  @override
  String get expensesEnterValidSplits => 'Gültige Aufteilungsbeträge eingeben';

  @override
  String get expensesPercentOver100 =>
      'Jeder Anteil muss 100 % oder weniger betragen';

  @override
  String get expensesEnterValidPercents =>
      'Gültige Aufteilungsprozentsätze eingeben';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Gesamt $total % — um $over % reduzieren';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Gesamt $total % — noch $remaining % übrig';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return 'Gesamt: $amount';
  }

  @override
  String get settlementsEditTitle => 'Ausgleichszahlung bearbeiten';

  @override
  String get settlementsRecordTitle => 'Ausgleichszahlung erfassen';

  @override
  String get settlementsFromPays => 'VON (ZAHLT)';

  @override
  String get settlementsToReceives => 'AN (ERHÄLT)';

  @override
  String get settlementsAmount => 'BETRAG';

  @override
  String get settlementsNoteOptional => 'NOTIZ (OPTIONAL)';

  @override
  String get settlementsNoteHint => 'Bargeld, Banküberweisung …';

  @override
  String get settlementsSaveChanges => 'Änderungen speichern';

  @override
  String get settlementsRecordPayment => 'Zahlung erfassen';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileYourName => 'Dein Name';

  @override
  String get profileLanguage => 'SPRACHE';

  @override
  String get profileLanguageHint =>
      'Folgt deinem Gerät, sofern du keine Sprache wählst.';

  @override
  String get profileLanguageSystem => 'System';

  @override
  String get profileAppearance => 'ERSCHEINUNGSBILD';

  @override
  String get profileAppearanceHint =>
      'Folgt deinem Gerät, sofern du nicht Hell oder Dunkel wählst.';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Hell';

  @override
  String get profileThemeDark => 'Dunkel';

  @override
  String get profileDefaultCurrencyHeader => 'STANDARDWÄHRUNG';

  @override
  String get profileDefaultCurrencyHint =>
      'Wird für neue Gruppen und die Startübersicht verwendet.';

  @override
  String get profileDefaultCurrencySheet => 'Standardwährung';

  @override
  String get profileManage => 'VERWALTEN';

  @override
  String get profilePeople => 'Personen';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
      zero: 'Noch keine Personen',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Daten & Sicherung';

  @override
  String get profileDataBackupSubtitle => 'Daten exportieren oder importieren';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'Über $appName';
  }

  @override
  String get profileAboutSubtitle => 'Datenschutz, Kontakt, Feedback & Teilen';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'Personen';

  @override
  String get peopleAddPerson => 'Person hinzufügen';

  @override
  String get peopleAddHint => 'z. B. Anna';

  @override
  String get peopleEditName => 'Name bearbeiten';

  @override
  String get peopleDeleteTitle => 'Person löschen?';

  @override
  String peopleDeleteBody(String name) {
    return '$name aus deiner Personenliste entfernen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get peopleIntro =>
      'Alle Personen, die in deinen Gruppen hinzugefügt wurden.';

  @override
  String get peopleSearchHint => 'Nach Namen suchen';

  @override
  String get peopleEmpty =>
      'Noch keine Personen. Tippe auf +, um jemanden hinzuzufügen.';

  @override
  String get peopleNoMatch => 'Keine Personen entsprechen deiner Suche.';

  @override
  String get dataTitle => 'Daten & Sicherung';

  @override
  String get dataWebBlurb =>
      'Sicherungsexport und -import sind in den mobilen und Desktop-Apps verfügbar. Deine Daten werden lokal in diesem Browser gespeichert.';

  @override
  String get dataNativeBlurb =>
      'Exportiere eine Sicherung und speichere sie auf deinem Gerät oder teile sie anderswo. Der Import ersetzt alles auf diesem Gerät.';

  @override
  String get dataExportBackup => 'Sicherung exportieren';

  @override
  String get dataImportBackup => 'Sicherung importieren';

  @override
  String get dataCouldNotExport => 'Sicherung konnte nicht exportiert werden.';

  @override
  String get dataSaveBackupDialog => 'Sicherung speichern';

  @override
  String get dataBackupSaved => 'Sicherung gespeichert.';

  @override
  String get dataCouldNotSave => 'Sicherung konnte nicht gespeichert werden.';

  @override
  String get dataShareSubject => 'SceneSplit-Sicherung';

  @override
  String get dataShareText => 'SceneSplit-Datenbanksicherung';

  @override
  String get dataCouldNotShare => 'Sicherung konnte nicht geteilt werden.';

  @override
  String get dataImportTitle => 'Sicherung importieren?';

  @override
  String get dataImportBody =>
      'Das Importieren einer Sicherung ersetzt alle derzeit in SceneSplit auf diesem Gerät gespeicherten Daten. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get dataImportSuccess => 'Sicherung erfolgreich importiert.';

  @override
  String get dataCouldNotImport => 'Sicherung konnte nicht importiert werden.';

  @override
  String get dataBackupReady => 'Sicherung bereit';

  @override
  String get dataSaveToDevice => 'Auf Gerät speichern';

  @override
  String get dataSaveToDeviceSubtitle => 'Ordner und Dateiname wählen';

  @override
  String get dataShare => 'Teilen';

  @override
  String get dataShareSubtitle => 'Per E-Mail, Drive, AirDrop usw. senden';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutCouldNotOpenEmail =>
      'E-Mail-App konnte nicht geöffnet werden';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Ausgaben mit Freunden teilen.\nOffline zuerst. Kein Konto erforderlich.';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get aboutTermsOfService => 'Nutzungsbedingungen';

  @override
  String get aboutContactUs => 'Kontakt';

  @override
  String get aboutEmailSupportSubject => 'SceneSplit-Support';

  @override
  String get aboutSendFeedback => 'Feedback senden';

  @override
  String get aboutEmailFeedbackSubject => 'SceneSplit-Feedback';

  @override
  String get aboutSuggestFeature => 'Funktion vorschlagen';

  @override
  String get aboutEmailFeatureSubject => 'SceneSplit-Funktionsvorschlag';

  @override
  String aboutRateApp(String appName) {
    return '$appName bewerten';
  }

  @override
  String get aboutShareApp => 'App teilen';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Probier $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Schau dir $appName an — Ausgaben mit Freunden teilen. Offline zuerst, kein Konto nötig.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'App konnte nicht geteilt werden.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Datenschutzerklärung';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String legalLoadError(String error) {
    return 'Dokument konnte nicht geladen werden: $error';
  }

  @override
  String get sharedSettledTitle => 'Alles ist ausgeglichen';

  @override
  String get sharedSettledSubtitle => 'Keine offenen Salden in dieser Gruppe';

  @override
  String get sharedYouGet => 'Du erhältst';

  @override
  String get sharedYouWillGive => 'Du schuldest';

  @override
  String get sharedNoChartData => 'Keine Daten für das Diagramm';

  @override
  String get sharedTotal => 'Gesamt';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent %';
  }

  @override
  String get sharedChooseLanguage => 'Sprache wählen';

  @override
  String get sharedChooseCurrency => 'Währung wählen';

  @override
  String get sharedCurrencySearchHint => 'Nach Name, Code oder Symbol suchen';

  @override
  String get sharedNoCurrenciesFound => 'Keine Währungen gefunden';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Benutzerdefiniertes Emoji';

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
    return 'Jemand namens «$name» existiert bereits.';
  }

  @override
  String get errorCannotDeleteSelf => 'Du kannst dich nicht selbst löschen.';

  @override
  String get errorUserHasFinancialActivity =>
      'Diese Person hat Ausgaben oder Ausgleichszahlungen und kann nicht gelöscht werden.';

  @override
  String get errorBackupCorrupt =>
      'Sicherungsdatei konnte nicht geöffnet werden. Sie ist möglicherweise beschädigt oder keine SQLite-Datenbank.';

  @override
  String get errorBackupVersionMismatch =>
      'Diese Sicherung stammt aus einer anderen App-Version und kann nicht importiert werden.';

  @override
  String get errorBackupNotSceneSplit =>
      'Diese Datei scheint keine SceneSplit-Sicherung zu sein.';

  @override
  String get errorBackupExportWeb =>
      'Sicherungsexport ist im Web nicht verfügbar. Verwende die mobile oder Desktop-App, um Sicherungen zu exportieren.';

  @override
  String get errorBackupImportWeb =>
      'Sicherungsimport ist im Web nicht verfügbar. Verwende die mobile oder Desktop-App, um Sicherungen zu importieren.';

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
