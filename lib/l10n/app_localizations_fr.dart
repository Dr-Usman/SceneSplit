// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'Une erreur s\'est produite : $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Erreur : $error';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonImport => 'Importer';

  @override
  String commonYouSuffix(String name) {
    return '$name (vous)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '« $name » est déjà dans la liste.';
  }

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get onboardingTagline =>
      'Partagez vos dépenses entre amis.\nSans compte, sans prise de tête.';

  @override
  String get onboardingYourName => 'VOTRE NOM';

  @override
  String get onboardingNameHint => 'p. ex. Jean Dupont';

  @override
  String get onboardingCurrency => 'DEVISE';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get onboardingPrivacyNote => 'Tout reste sur votre appareil.';

  @override
  String get homeNewGroup => 'Nouvelle scène';

  @override
  String get homeGroupsHeader => 'SCÈNES';

  @override
  String get homeYouGetByGroup => 'Vous recevrez par scène';

  @override
  String get homeYouWillGiveByGroup => 'Vous devrez par scène';

  @override
  String get homeBreakdownSubtitle =>
      'Montants affichés dans la devise de chaque scène';

  @override
  String get homeYouWillGet => 'Vous recevrez';

  @override
  String get homeYouWillGive => 'Vous devrez';

  @override
  String get homeSettledUp => 'soldé';

  @override
  String get homeCardYouWillGet => 'vous recevrez';

  @override
  String get navScenes => 'Scènes';

  @override
  String get navBalances => 'Soldes';

  @override
  String get navProfile => 'Profil';

  @override
  String get balancesTitle => 'Soldes';

  @override
  String get balancesSubtitle => 'Voyez qui doit quoi à qui dans vos scènes.';

  @override
  String get balancesWho => 'Qui';

  @override
  String get balancesWhom => 'À qui';

  @override
  String get balancesFilterTitle => 'Qui doit à qui';

  @override
  String get balancesFilterHint =>
      'Choisissez qui doit à qui pour filtrer les dettes ouvertes.';

  @override
  String get balancesAnyone => 'N’importe qui';

  @override
  String get balancesOwes => 'doit à';

  @override
  String get balancesClear => 'Effacer';

  @override
  String get balancesShowResults => 'Afficher les résultats';

  @override
  String get balancesClearSelection => 'Effacer la sélection';

  @override
  String get balancesEmpty => 'Aucune dette ouverte dans vos scènes.';

  @override
  String get balancesEmptyFiltered =>
      'Aucune dette ouverte ne correspond à cette sélection.';

  @override
  String get balancesPickPerson => 'Sélectionner une personne';

  @override
  String get balancesNoPeopleFound => 'Aucune personne trouvée';

  @override
  String balancesCurrencySection(String currency) {
    return '$currency';
  }

  @override
  String get balancesOpenDebtTotal => 'Dette ouverte';

  @override
  String balancesOpenDebtCurrency(String currency) {
    return 'Dette ouverte ($currency)';
  }

  @override
  String get balancesYouAreOwed => 'On vous doit';

  @override
  String get balancesYouOwe => 'Vous devez';

  @override
  String get balancesHeroOwed => 'Reçoit';

  @override
  String get balancesHeroOwe => 'Doit';

  @override
  String balancesHeroOwedBreakdown(String name) {
    return 'Qui doit à $name';
  }

  @override
  String balancesHeroOweBreakdown(String name) {
    return 'À qui $name doit';
  }

  @override
  String get balancesHeroNetLabel => 'Net';

  @override
  String balancesHeroNetOwes(String debtor, String creditor) {
    return '$debtor doit à $creditor';
  }

  @override
  String get balancesShareTotal => 'Total de la part';

  @override
  String get balancesExpenseTotal => 'Total des dépenses';

  @override
  String get balancesScenesHeader => 'SCÈNES';

  @override
  String get balancesSettleInScene => 'Régler';

  @override
  String get balancesViewShares => 'Parts des dépenses';

  @override
  String get balancesPairSettled => 'Réglé entre ces personnes';

  @override
  String balancesPairBetween(String a, String b) {
    return '$a et $b';
  }

  @override
  String get balancesSelectPerson => 'Toucher pour sélectionner';

  @override
  String get homeCardYouWillGive => 'vous devrez';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Aucune scène pour l\'instant';

  @override
  String get homeEmptyBody =>
      'Créez une scène pour un voyage, un dîner\nou un foyer partagé pour commencer à partager.';

  @override
  String get groupsNewGroup => 'Nouvelle scène';

  @override
  String get groupsEditGroup => 'Modifier la scène';

  @override
  String get groupsGroupName => 'NOM DE LA SCÈNE';

  @override
  String get groupsNameHint => 'p. ex. Voyage au Japon';

  @override
  String get groupsIcon => 'ICÔNE';

  @override
  String get groupsCurrency => 'DEVISE';

  @override
  String get groupsMembers => 'MEMBRES';

  @override
  String get groupsAddMemberHint => 'Ajouter un membre par nom';

  @override
  String get groupsCreateGroup => 'Créer la scène';

  @override
  String get groupsSaveChanges => 'Enregistrer les modifications';

  @override
  String get groupsRemovalBlockedYou =>
      'Vous avez des dépenses ou des règlements dans cette scène et ne pouvez pas être retiré.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name a des dépenses ou des règlements dans cette scène et ne peut pas être retiré.';
  }

  @override
  String get groupsThisMember => 'Ce membre';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Supprimer la scène';

  @override
  String get groupsAddExpense => 'Ajouter une dépense';

  @override
  String get groupsExpenseBreakdown => 'RÉPARTITION DES DÉPENSES';

  @override
  String groupsMemberShareTitle(String name) {
    return 'Part de $name';
  }

  @override
  String groupsMemberShareExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dépenses',
      one: '1 dépense',
    );
    return '$_temp0';
  }

  @override
  String groupsMemberShareOfAmount(String amount) {
    return 'sur $amount';
  }

  @override
  String get groupsMemberShareTotalLabel => 'Part totale';

  @override
  String groupsMembersHeader(int count) {
    return 'MEMBRES ($count)';
  }

  @override
  String get groupsManage => 'Gérer';

  @override
  String get groupsWhoOwesWhom => 'QUI DOIT À QUI';

  @override
  String get groupsSettleUp => 'Régler';

  @override
  String get groupsShareBalances => 'Partager';

  @override
  String groupsShareBalancesSubject(String groupName) {
    return 'Soldes — $groupName';
  }

  @override
  String groupsShareBalancesText(String groupName) {
    return 'Qui doit quoi dans $groupName';
  }

  @override
  String get groupsShareAllSettled => 'Tout est réglé';

  @override
  String get groupsExpenseShares => 'Parts des dépenses';

  @override
  String get groupsCouldNotShareBalances =>
      'Impossible de partager les soldes.';

  @override
  String get groupsSettlements => 'RÈGLEMENTS';

  @override
  String get groupsExpenses => 'DÉPENSES';

  @override
  String get groupsSettlementsTitle => 'Règlements';

  @override
  String get groupsExpensesTitle => 'Dépenses';

  @override
  String groupsSettlementsScreenTitle(String groupName) {
    return '$groupName · Règlements';
  }

  @override
  String groupsExpensesScreenTitle(String groupName) {
    return '$groupName · Dépenses';
  }

  @override
  String groupsViewAllCount(int count) {
    return 'Tout voir ($count)';
  }

  @override
  String get groupsEmptySettlementsBody =>
      'Aucun règlement enregistré pour le moment.';

  @override
  String get groupsSwipeToDeleteHint => 'Balayez vers la gauche pour supprimer';

  @override
  String get groupsDeleteExpenseTitle => 'Supprimer la dépense ?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'Retirer « $title » de cette scène ?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Supprimer la scène ?';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'Supprimer « $name » et toutes ses dépenses ? Cette action est irréversible.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'Supprimer le règlement ?';

  @override
  String get groupsDeleteSettlementBody => 'Retirer ce paiement enregistré ?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from doit à $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer a payé · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from a payé $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'Aucune dépense pour l\'instant';

  @override
  String get groupsEmptyExpensesBody =>
      'Appuyez sur « Ajouter une dépense » pour partager votre première facture.';

  @override
  String get expensesEditTitle => 'Modifier la dépense';

  @override
  String get expensesAddTitle => 'Ajouter une dépense';

  @override
  String get expensesDetailTitle => 'Dépense';

  @override
  String get expensesNotFound => 'Dépense introuvable';

  @override
  String get expensesAmount => 'Montant';

  @override
  String get expensesAmountSubtitle => 'Montant total de la facture';

  @override
  String get expensesDescription => 'Description';

  @override
  String get expensesDescriptionHint => 'p. ex. Dîner, Courses, Taxi';

  @override
  String get expensesDate => 'Date';

  @override
  String get expensesPaidBy => 'Payé par';

  @override
  String get expensesPaidBySubtitle => 'Qui a réglé cette facture';

  @override
  String get expensesPaidByHeader => 'PAYÉ PAR';

  @override
  String get expensesPayerSingle => 'Unique';

  @override
  String get expensesPayerMultiple => 'Multiple';

  @override
  String get expensesSplit => 'Répartition';

  @override
  String get expensesSplitSubtitle => 'Comment diviser le coût';

  @override
  String get expensesSplitEqual => 'Égal';

  @override
  String get expensesSplitExact => 'Exact';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Montants exacts';

  @override
  String get expensesSplitByPercentage => 'Par pourcentage';

  @override
  String get expensesSplitEqually => 'Répartir également';

  @override
  String get expensesSplitBreakdown => 'DÉTAIL DE LA RÉPARTITION';

  @override
  String get expensesNote => 'Note';

  @override
  String get expensesNoteHint => 'Note facultative';

  @override
  String get expensesSaveChanges => 'Enregistrer les modifications';

  @override
  String get expensesSaveExpense => 'Enregistrer la dépense';

  @override
  String get expensesSubtitlePaid => 'a payé';

  @override
  String get expensesSubtitleAlsoPaid => 'a aussi payé';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Chaque paiement ne doit pas dépasser $amount';
  }

  @override
  String get expensesEnterValidPayments =>
      'Saisissez des montants de paiement valides';

  @override
  String expensesOverBy(String amount) {
    return 'Dépassement de $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'Il reste $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Total des paiements $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Chaque part ne doit pas dépasser $amount';
  }

  @override
  String get expensesEnterValidSplits =>
      'Saisissez des montants de répartition valides';

  @override
  String get expensesPercentOver100 =>
      'Chaque part doit être de 100 % ou moins';

  @override
  String get expensesEnterValidPercents =>
      'Saisissez des pourcentages de répartition valides';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Total $total % — réduisez de $over %';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Total $total % — il reste $remaining %';
  }

  @override
  String expensesPayerLine(String name, String amount) {
    return '$name : $amount';
  }

  @override
  String expensesPreviewTotal(String amount) {
    return 'Total : $amount';
  }

  @override
  String get settlementsEditTitle => 'Modifier le règlement';

  @override
  String get settlementsRecordTitle => 'Enregistrer un règlement';

  @override
  String get settlementsFromPays => 'DE (PAIE)';

  @override
  String get settlementsToReceives => 'À (REÇOIT)';

  @override
  String get settlementsAmount => 'MONTANT';

  @override
  String get settlementsNoteOptional => 'NOTE (FACULTATIF)';

  @override
  String get settlementsNoteHint => 'Espèces, virement bancaire…';

  @override
  String get settlementsSaveChanges => 'Enregistrer les modifications';

  @override
  String get settlementsRecordPayment => 'Enregistrer le paiement';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileYourName => 'Votre nom';

  @override
  String get profileLanguage => 'LANGUE';

  @override
  String get profileLanguageHint =>
      'Suit la langue de votre appareil sauf si vous en choisissez une.';

  @override
  String get profileLanguageSystem => 'Système';

  @override
  String get profileAppearance => 'APPARENCE';

  @override
  String get profileAppearanceHint =>
      'Suit votre appareil sauf si vous choisissez Clair ou Sombre.';

  @override
  String get profileThemeSystem => 'Système';

  @override
  String get profileThemeLight => 'Clair';

  @override
  String get profileThemeDark => 'Sombre';

  @override
  String get profileDefaultCurrencyHeader => 'DEVISE PAR DÉFAUT';

  @override
  String get profileDefaultCurrencyHint =>
      'Utilisée pour les nouvelles scènes et le résumé d\'accueil.';

  @override
  String get profileDefaultCurrencySheet => 'Devise par défaut';

  @override
  String get profileManage => 'GÉRER';

  @override
  String get profilePeople => 'Personnes';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: 'Aucune personne pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Données et sauvegarde';

  @override
  String get profileDataBackupSubtitle => 'Exporter ou importer vos données';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'À propos de $appName';
  }

  @override
  String get profileAboutSubtitle =>
      'Confidentialité, contact, avis et partage';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'Personnes';

  @override
  String get peopleAddPerson => 'Ajouter une personne';

  @override
  String get peopleAddHint => 'p. ex. Alice';

  @override
  String get peopleEditName => 'Modifier le nom';

  @override
  String get peopleDeleteTitle => 'Supprimer la personne ?';

  @override
  String peopleDeleteBody(String name) {
    return 'Retirer $name de votre liste de personnes ? Cette action est irréversible.';
  }

  @override
  String get peopleIntro => 'Toutes les personnes ajoutées dans vos scènes.';

  @override
  String get peopleSearchHint => 'Rechercher par nom';

  @override
  String get peopleEmpty =>
      'Aucune personne pour l\'instant. Appuyez sur + pour en ajouter une.';

  @override
  String get peopleNoMatch =>
      'Aucune personne ne correspond à votre recherche.';

  @override
  String get peopleSwipeHint =>
      'Balayez vers la gauche pour modifier ou supprimer';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scènes',
      one: '1 scène',
      zero: 'Dans aucune scène',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle =>
      'Montants affichés dans la devise de chaque scène';

  @override
  String get peopleDetailEmptyScenes => 'Pas encore membre d\'une scène.';

  @override
  String get peopleDetailAllSettled => 'Tout est réglé dans les scènes';

  @override
  String get peopleDetailOpenBalances => 'Soldes ouverts dans certaines scènes';

  @override
  String peopleDetailGets(String name) {
    return 'Créance totale de $name';
  }

  @override
  String peopleDetailWillGive(String name) {
    return 'Dette totale de $name';
  }

  @override
  String get peopleDetailYourTotalCredit => 'Votre créance totale';

  @override
  String get peopleDetailYourTotalDebt => 'Votre dette totale';

  @override
  String get peopleDetailSettledInScene => 'Réglé';

  @override
  String get peopleDetailNoDebts => 'Aucune dette ouverte dans cette scène';

  @override
  String get peopleDetailViewExpenses => 'Voir la part des dépenses';

  @override
  String get peopleDetailExpensesSection => 'DÉPENSES';

  @override
  String get dataTitle => 'Données et sauvegarde';

  @override
  String get dataWebBlurb =>
      'L\'exportation et l\'importation de sauvegardes sont disponibles dans les applications mobile et de bureau. Vos données sont stockées localement dans ce navigateur.';

  @override
  String get dataNativeBlurb =>
      'Exportez une sauvegarde, puis enregistrez-la sur votre appareil ou partagez-la ailleurs. L\'importation remplace tout sur cet appareil.';

  @override
  String get dataExportBackup => 'Exporter la sauvegarde';

  @override
  String get dataImportBackup => 'Importer la sauvegarde';

  @override
  String get dataCouldNotExport => 'Impossible d\'exporter la sauvegarde.';

  @override
  String get dataSaveBackupDialog => 'Enregistrer la sauvegarde';

  @override
  String get dataBackupSaved => 'Sauvegarde enregistrée.';

  @override
  String get dataCouldNotSave => 'Impossible d\'enregistrer la sauvegarde.';

  @override
  String get dataShareSubject => 'Sauvegarde SceneSplit';

  @override
  String get dataShareText => 'Sauvegarde de la base de données SceneSplit';

  @override
  String get dataCouldNotShare => 'Impossible de partager la sauvegarde.';

  @override
  String get dataImportTitle => 'Importer la sauvegarde ?';

  @override
  String get dataImportBody =>
      'L\'importation d\'une sauvegarde remplacera toutes les données actuellement dans SceneSplit sur cet appareil. Cette action est irréversible.';

  @override
  String get dataImportSuccess => 'Sauvegarde importée avec succès.';

  @override
  String get dataCouldNotImport => 'Impossible d\'importer la sauvegarde.';

  @override
  String get dataBackupReady => 'Sauvegarde prête';

  @override
  String get dataSaveToDevice => 'Enregistrer sur l\'appareil';

  @override
  String get dataSaveToDeviceSubtitle =>
      'Choisir le dossier et le nom du fichier';

  @override
  String get dataShare => 'Partager';

  @override
  String get dataShareSubtitle => 'Envoyer par e-mail, Drive, AirDrop, etc.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutCouldNotOpenEmail =>
      'Impossible d\'ouvrir l\'application de messagerie';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Partagez vos dépenses entre amis.\nHors ligne. Aucun compte requis.';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutTermsOfService => 'Conditions d\'utilisation';

  @override
  String get aboutContactUs => 'Nous contacter';

  @override
  String get aboutEmailSupportSubject => 'Assistance SceneSplit';

  @override
  String get aboutSendFeedback => 'Envoyer un avis';

  @override
  String get aboutEmailFeedbackSubject => 'Avis sur SceneSplit';

  @override
  String get aboutSuggestFeature => 'Suggérer une fonctionnalité';

  @override
  String get aboutEmailFeatureSubject =>
      'Suggestion de fonctionnalité SceneSplit';

  @override
  String aboutRateApp(String appName) {
    return 'Noter $appName';
  }

  @override
  String get aboutShareApp => 'Partager l’app';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Essayez $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Découvrez $appName — partagez vos dépenses entre amis. Hors ligne d’abord, sans compte.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'Impossible de partager l’application.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Politique de confidentialité';

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String legalLoadError(String error) {
    return 'Impossible de charger le document : $error';
  }

  @override
  String get sharedSettledTitle => 'Tout est réglé';

  @override
  String get sharedSettledSubtitle => 'Aucun solde en attente dans cette scène';

  @override
  String get sharedYouGet => 'Vous recevez';

  @override
  String get sharedYouWillGive => 'Vous devrez';

  @override
  String get sharedNoChartData => 'Aucune donnée à afficher';

  @override
  String get sharedTotal => 'Total';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent %';
  }

  @override
  String get sharedChooseLanguage => 'Choisir la langue';

  @override
  String get sharedChooseCurrency => 'Choisir la devise';

  @override
  String get sharedCurrencySearchHint => 'Rechercher par nom, code ou symbole';

  @override
  String get sharedNoCurrenciesFound => 'Aucune devise trouvée';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Emoji personnalisé';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a et $b';
  }

  @override
  String moneyManyPayers(String name, int count) {
    return '$name +$count';
  }

  @override
  String supportEmailBodyFooter(String appName, String version, String build) {
    return '\n\n---\nApp : $appName $version ($build)';
  }

  @override
  String errorUserNameTaken(String name) {
    return 'Quelqu\'un nommé « $name » existe déjà.';
  }

  @override
  String get errorCannotDeleteSelf => 'Vous ne pouvez pas vous supprimer.';

  @override
  String get errorUserHasFinancialActivity =>
      'Cette personne a des dépenses ou des règlements et ne peut pas être supprimée.';

  @override
  String get errorBackupCorrupt =>
      'Impossible d\'ouvrir le fichier de sauvegarde. Il est peut-être corrompu ou n\'est pas une base de données SQLite.';

  @override
  String get errorBackupVersionMismatch =>
      'Cette sauvegarde provient d\'une version différente de l\'application et ne peut pas être importée.';

  @override
  String get errorBackupNotSceneSplit =>
      'Ce fichier ne ressemble pas à une sauvegarde SceneSplit.';

  @override
  String get errorBackupExportWeb =>
      'L\'exportation de sauvegarde n\'est pas disponible sur le web. Utilisez l\'application mobile ou de bureau pour exporter des sauvegardes.';

  @override
  String get errorBackupImportWeb =>
      'L\'importation de sauvegarde n\'est pas disponible sur le web. Utilisez l\'application mobile ou de bureau pour importer des sauvegardes.';

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
