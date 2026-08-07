// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'Algo deu errado: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonImport => 'Importar';

  @override
  String commonYouSuffix(String name) {
    return '$name (você)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '«$name» já está na lista.';
  }

  @override
  String get commonUnknown => 'Desconhecido';

  @override
  String get onboardingTagline =>
      'Divida despesas com amigos.\nSem contas, sem complicação.';

  @override
  String get onboardingYourName => 'SEU NOME';

  @override
  String get onboardingNameHint => 'ex.: João Silva';

  @override
  String get onboardingCurrency => 'MOEDA';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingPrivacyNote => 'Tudo fica no seu dispositivo.';

  @override
  String get homeNewGroup => 'Nova cena';

  @override
  String get homeGroupsHeader => 'CENAS';

  @override
  String get homeYouGetByGroup => 'Você recebe por cena';

  @override
  String get homeYouWillGiveByGroup => 'Você deve por cena';

  @override
  String get homeBreakdownSubtitle => 'Valores exibidos na moeda de cada cena';

  @override
  String get homeYouWillGet => 'Você receberá';

  @override
  String get homeYouWillGive => 'Você deverá';

  @override
  String get homeSettledUp => 'quitado';

  @override
  String get homeCardYouWillGet => 'você receberá';

  @override
  String get homeCardYouWillGive => 'você deverá';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Nenhuma cena ainda';

  @override
  String get homeEmptyBody =>
      'Crie uma cena para uma viagem, jantar\nou casa compartilhada e comece a dividir.';

  @override
  String get groupsNewGroup => 'Nova cena';

  @override
  String get groupsEditGroup => 'Editar cena';

  @override
  String get groupsGroupName => 'NOME DA CENA';

  @override
  String get groupsNameHint => 'ex.: Viagem ao Japão';

  @override
  String get groupsIcon => 'ÍCONE';

  @override
  String get groupsCurrency => 'MOEDA';

  @override
  String get groupsMembers => 'MEMBROS';

  @override
  String get groupsAddMemberHint => 'Adicionar membro pelo nome';

  @override
  String get groupsCreateGroup => 'Criar cena';

  @override
  String get groupsSaveChanges => 'Salvar alterações';

  @override
  String get groupsRemovalBlockedYou =>
      'Você tem despesas ou acertos nesta cena e não pode ser removido.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name tem despesas ou acertos nesta cena e não pode ser removido.';
  }

  @override
  String get groupsThisMember => 'Este membro';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Excluir cena';

  @override
  String get groupsAddExpense => 'Adicionar despesa';

  @override
  String get groupsExpenseBreakdown => 'DETALHAMENTO DE DESPESAS';

  @override
  String groupsMemberShareTitle(String name) {
    return 'Parte de $name';
  }

  @override
  String groupsMembersHeader(int count) {
    return 'MEMBROS ($count)';
  }

  @override
  String get groupsManage => 'Gerenciar';

  @override
  String get groupsWhoOwesWhom => 'QUEM DEVE A QUEM';

  @override
  String get groupsSettleUp => 'Acertar contas';

  @override
  String get groupsSettlements => 'ACERTOS';

  @override
  String get groupsExpenses => 'DESPESAS';

  @override
  String get groupsSwipeToDeleteHint => 'Deslize para a esquerda para excluir';

  @override
  String get groupsDeleteExpenseTitle => 'Excluir despesa?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'Remover «$title» desta cena?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Excluir cena?';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'Excluir «$name» e todas as despesas? Isso não pode ser desfeito.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'Excluir acerto?';

  @override
  String get groupsDeleteSettlementBody => 'Remover este pagamento registrado?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from deve a $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer pagou · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from pagou $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'Nenhuma despesa ainda';

  @override
  String get groupsEmptyExpensesBody =>
      'Toque em «Adicionar despesa» para dividir sua primeira conta.';

  @override
  String get expensesEditTitle => 'Editar despesa';

  @override
  String get expensesAddTitle => 'Adicionar despesa';

  @override
  String get expensesDetailTitle => 'Despesa';

  @override
  String get expensesNotFound => 'Despesa não encontrada';

  @override
  String get expensesAmount => 'Valor';

  @override
  String get expensesAmountSubtitle => 'Valor total da conta';

  @override
  String get expensesDescription => 'Descrição';

  @override
  String get expensesDescriptionHint => 'ex.: Jantar, Compras, Táxi';

  @override
  String get expensesDate => 'Data';

  @override
  String get expensesPaidBy => 'Pago por';

  @override
  String get expensesPaidBySubtitle => 'Quem cobriu esta conta';

  @override
  String get expensesPaidByHeader => 'PAGO POR';

  @override
  String get expensesPayerSingle => 'Único';

  @override
  String get expensesPayerMultiple => 'Vários';

  @override
  String get expensesSplit => 'Divisão';

  @override
  String get expensesSplitSubtitle => 'Como dividir o custo';

  @override
  String get expensesSplitEqual => 'Igual';

  @override
  String get expensesSplitExact => 'Exato';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Valores exatos';

  @override
  String get expensesSplitByPercentage => 'Por porcentagem';

  @override
  String get expensesSplitEqually => 'Dividir igualmente';

  @override
  String get expensesSplitBreakdown => 'DETALHAMENTO DA DIVISÃO';

  @override
  String get expensesNote => 'Nota';

  @override
  String get expensesNoteHint => 'Nota opcional';

  @override
  String get expensesSaveChanges => 'Salvar alterações';

  @override
  String get expensesSaveExpense => 'Salvar despesa';

  @override
  String get expensesSubtitlePaid => 'pagou';

  @override
  String get expensesSubtitleAlsoPaid => 'também pagou';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Cada pagamento não deve exceder $amount';
  }

  @override
  String get expensesEnterValidPayments =>
      'Insira valores de pagamento válidos';

  @override
  String expensesOverBy(String amount) {
    return 'Excedente de $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'Faltam $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Total de pagamentos $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Cada parte não deve exceder $amount';
  }

  @override
  String get expensesEnterValidSplits => 'Insira valores de divisão válidos';

  @override
  String get expensesPercentOver100 => 'Cada parte deve ser 100% ou menos';

  @override
  String get expensesEnterValidPercents =>
      'Insira porcentagens de divisão válidas';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Total $total% — reduza $over%';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Total $total% — faltam $remaining%';
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
  String get settlementsEditTitle => 'Editar acerto';

  @override
  String get settlementsRecordTitle => 'Registrar acerto';

  @override
  String get settlementsFromPays => 'DE (PAGA)';

  @override
  String get settlementsToReceives => 'PARA (RECEBE)';

  @override
  String get settlementsAmount => 'VALOR';

  @override
  String get settlementsNoteOptional => 'NOTA (OPCIONAL)';

  @override
  String get settlementsNoteHint => 'Dinheiro, transferência bancária…';

  @override
  String get settlementsSaveChanges => 'Salvar alterações';

  @override
  String get settlementsRecordPayment => 'Registrar pagamento';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileYourName => 'Seu nome';

  @override
  String get profileLanguage => 'IDIOMA';

  @override
  String get profileLanguageHint =>
      'Segue o idioma do dispositivo, a menos que você escolha um.';

  @override
  String get profileLanguageSystem => 'Sistema';

  @override
  String get profileAppearance => 'APARÊNCIA';

  @override
  String get profileAppearanceHint =>
      'Segue o dispositivo, a menos que você escolha Claro ou Escuro.';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Escuro';

  @override
  String get profileDefaultCurrencyHeader => 'MOEDA PADRÃO';

  @override
  String get profileDefaultCurrencyHint =>
      'Usada para novas cenas e o resumo da tela inicial.';

  @override
  String get profileDefaultCurrencySheet => 'Moeda padrão';

  @override
  String get profileManage => 'GERENCIAR';

  @override
  String get profilePeople => 'Pessoas';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
      zero: 'Nenhuma pessoa ainda',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Dados e backup';

  @override
  String get profileDataBackupSubtitle => 'Exportar ou importar seus dados';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'Sobre $appName';
  }

  @override
  String get profileAboutSubtitle =>
      'Privacidade, contacto, feedback e partilha';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'Pessoas';

  @override
  String get peopleAddPerson => 'Adicionar pessoa';

  @override
  String get peopleAddHint => 'ex.: Alice';

  @override
  String get peopleEditName => 'Editar nome';

  @override
  String get peopleDeleteTitle => 'Excluir pessoa?';

  @override
  String peopleDeleteBody(String name) {
    return 'Remover $name da sua lista de pessoas? Isso não pode ser desfeito.';
  }

  @override
  String get peopleIntro => 'Todas as pessoas adicionadas nas suas cenas.';

  @override
  String get peopleSearchHint => 'Buscar por nome';

  @override
  String get peopleEmpty =>
      'Nenhuma pessoa ainda. Toque em + para adicionar alguém.';

  @override
  String get peopleNoMatch => 'Nenhuma pessoa corresponde à sua busca.';

  @override
  String get peopleSwipeHint =>
      'Deslize para a esquerda para editar ou excluir';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas',
      one: '1 cena',
      zero: 'Em nenhuma cena',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle =>
      'Valores exibidos na moeda de cada cena';

  @override
  String get peopleDetailEmptyScenes => 'Ainda não é membro de nenhuma cena.';

  @override
  String get peopleDetailAllSettled => 'Tudo acertado nas cenas';

  @override
  String get peopleDetailOpenBalances => 'Saldos em aberto em algumas cenas';

  @override
  String peopleDetailGets(String name) {
    return '$name recebe';
  }

  @override
  String peopleDetailWillGive(String name) {
    return '$name deve';
  }

  @override
  String get peopleDetailSettledInScene => 'Acertado';

  @override
  String get peopleDetailNoDebts => 'Sem dívidas em aberto nesta cena';

  @override
  String get peopleDetailViewExpenses => 'Ver participação nas despesas';

  @override
  String get peopleDetailExpensesSection => 'DESPESAS';

  @override
  String get dataTitle => 'Dados e backup';

  @override
  String get dataWebBlurb =>
      'Exportação e importação de backup estão disponíveis nos apps móvel e desktop. Seus dados são armazenados localmente neste navegador.';

  @override
  String get dataNativeBlurb =>
      'Exporte um backup e salve no seu dispositivo ou compartilhe em outro lugar. A importação substitui tudo neste dispositivo.';

  @override
  String get dataExportBackup => 'Exportar backup';

  @override
  String get dataImportBackup => 'Importar backup';

  @override
  String get dataCouldNotExport => 'Não foi possível exportar o backup.';

  @override
  String get dataSaveBackupDialog => 'Salvar backup';

  @override
  String get dataBackupSaved => 'Backup salvo.';

  @override
  String get dataCouldNotSave => 'Não foi possível salvar o backup.';

  @override
  String get dataShareSubject => 'Backup do SceneSplit';

  @override
  String get dataShareText => 'Backup do banco de dados SceneSplit';

  @override
  String get dataCouldNotShare => 'Não foi possível compartilhar o backup.';

  @override
  String get dataImportTitle => 'Importar backup?';

  @override
  String get dataImportBody =>
      'Importar um backup substituirá todos os dados atualmente no SceneSplit neste dispositivo. Isso não pode ser desfeito.';

  @override
  String get dataImportSuccess => 'Backup importado com sucesso.';

  @override
  String get dataCouldNotImport => 'Não foi possível importar o backup.';

  @override
  String get dataBackupReady => 'Backup pronto';

  @override
  String get dataSaveToDevice => 'Salvar no dispositivo';

  @override
  String get dataSaveToDeviceSubtitle => 'Escolher pasta e nome do arquivo';

  @override
  String get dataShare => 'Compartilhar';

  @override
  String get dataShareSubtitle => 'Enviar por e-mail, Drive, AirDrop, etc.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutCouldNotOpenEmail => 'Não foi possível abrir o app de e-mail';

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Divida despesas com amigos.\nOffline primeiro. Sem conta necessária.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutTermsOfService => 'Termos de serviço';

  @override
  String get aboutContactUs => 'Fale conosco';

  @override
  String get aboutEmailSupportSubject => 'Suporte SceneSplit';

  @override
  String get aboutSendFeedback => 'Enviar feedback';

  @override
  String get aboutEmailFeedbackSubject => 'Feedback SceneSplit';

  @override
  String get aboutSuggestFeature => 'Sugerir um recurso';

  @override
  String get aboutEmailFeatureSubject => 'Sugestão de recurso SceneSplit';

  @override
  String aboutRateApp(String appName) {
    return 'Avaliar $appName';
  }

  @override
  String get aboutShareApp => 'Compartilhar app';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Experimente o $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Conheça o $appName — divida despesas com amigos. Offline primeiro, sem conta.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'Não foi possível compartilhar o app.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Política de privacidade';

  @override
  String get legalTermsTitle => 'Termos de serviço';

  @override
  String legalLoadError(String error) {
    return 'Não foi possível carregar o documento: $error';
  }

  @override
  String get sharedSettledTitle => 'Tudo quitado';

  @override
  String get sharedSettledSubtitle => 'Nenhum saldo pendente nesta cena';

  @override
  String get sharedYouGet => 'Você recebe';

  @override
  String get sharedYouWillGive => 'Você deve';

  @override
  String get sharedNoChartData => 'Sem dados para o gráfico';

  @override
  String get sharedTotal => 'Total';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => 'Escolher idioma';

  @override
  String get sharedChooseCurrency => 'Escolher moeda';

  @override
  String get sharedCurrencySearchHint => 'Buscar por nome, código ou símbolo';

  @override
  String get sharedNoCurrenciesFound => 'Nenhuma moeda encontrada';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Emoji personalizado';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a e $b';
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
    return 'Já existe alguém chamado «$name».';
  }

  @override
  String get errorCannotDeleteSelf => 'Você não pode se excluir.';

  @override
  String get errorUserHasFinancialActivity =>
      'Esta pessoa tem despesas ou acertos e não pode ser excluída.';

  @override
  String get errorBackupCorrupt =>
      'Não foi possível abrir o arquivo de backup. Ele pode estar corrompido ou não ser um banco de dados SQLite.';

  @override
  String get errorBackupVersionMismatch =>
      'Este backup é de uma versão diferente do app e não pode ser importado.';

  @override
  String get errorBackupNotSceneSplit =>
      'Este arquivo não parece ser um backup do SceneSplit.';

  @override
  String get errorBackupExportWeb =>
      'Exportação de backup não está disponível na web. Use o app móvel ou desktop para exportar backups.';

  @override
  String get errorBackupImportWeb =>
      'Importação de backup não está disponível na web. Use o app móvel ou desktop para importar backups.';

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

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String commonSomethingWentWrong(String error) {
    return 'Algo deu errado: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Erro: $error';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonImport => 'Importar';

  @override
  String commonYouSuffix(String name) {
    return '$name (você)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '«$name» já está na lista.';
  }

  @override
  String get commonUnknown => 'Desconhecido';

  @override
  String get onboardingTagline =>
      'Divida despesas com amigos.\nSem contas, sem complicação.';

  @override
  String get onboardingYourName => 'SEU NOME';

  @override
  String get onboardingNameHint => 'ex.: João Silva';

  @override
  String get onboardingCurrency => 'MOEDA';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingPrivacyNote => 'Tudo fica no seu dispositivo.';

  @override
  String get homeNewGroup => 'Nova cena';

  @override
  String get homeGroupsHeader => 'CENAS';

  @override
  String get homeYouGetByGroup => 'Você recebe por cena';

  @override
  String get homeYouWillGiveByGroup => 'Você deve por cena';

  @override
  String get homeBreakdownSubtitle => 'Valores exibidos na moeda de cada cena';

  @override
  String get homeYouWillGet => 'Você receberá';

  @override
  String get homeYouWillGive => 'Você deverá';

  @override
  String get homeSettledUp => 'quitado';

  @override
  String get homeCardYouWillGet => 'você receberá';

  @override
  String get homeCardYouWillGive => 'você deverá';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Nenhuma cena ainda';

  @override
  String get homeEmptyBody =>
      'Crie uma cena para uma viagem, jantar\nou casa compartilhada e comece a dividir.';

  @override
  String get groupsNewGroup => 'Nova cena';

  @override
  String get groupsEditGroup => 'Editar cena';

  @override
  String get groupsGroupName => 'NOME DA CENA';

  @override
  String get groupsNameHint => 'ex.: Viagem ao Japão';

  @override
  String get groupsIcon => 'ÍCONE';

  @override
  String get groupsCurrency => 'MOEDA';

  @override
  String get groupsMembers => 'MEMBROS';

  @override
  String get groupsAddMemberHint => 'Adicionar membro pelo nome';

  @override
  String get groupsCreateGroup => 'Criar cena';

  @override
  String get groupsSaveChanges => 'Salvar alterações';

  @override
  String get groupsRemovalBlockedYou =>
      'Você tem despesas ou acertos nesta cena e não pode ser removido.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name tem despesas ou acertos nesta cena e não pode ser removido.';
  }

  @override
  String get groupsThisMember => 'Este membro';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Excluir cena';

  @override
  String get groupsAddExpense => 'Adicionar despesa';

  @override
  String get groupsExpenseBreakdown => 'DETALHAMENTO DE DESPESAS';

  @override
  String groupsMemberShareTitle(String name) {
    return 'Parte de $name';
  }

  @override
  String groupsMembersHeader(int count) {
    return 'MEMBROS ($count)';
  }

  @override
  String get groupsManage => 'Gerenciar';

  @override
  String get groupsWhoOwesWhom => 'QUEM DEVE A QUEM';

  @override
  String get groupsSettleUp => 'Acertar contas';

  @override
  String get groupsSettlements => 'ACERTOS';

  @override
  String get groupsExpenses => 'DESPESAS';

  @override
  String get groupsSwipeToDeleteHint => 'Deslize para a esquerda para excluir';

  @override
  String get groupsDeleteExpenseTitle => 'Excluir despesa?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return 'Remover «$title» desta cena?';
  }

  @override
  String get groupsDeleteGroupTitle => 'Excluir cena?';

  @override
  String groupsDeleteGroupBody(String name) {
    return 'Excluir «$name» e todas as despesas? Isso não pode ser desfeito.';
  }

  @override
  String get groupsDeleteSettlementTitle => 'Excluir acerto?';

  @override
  String get groupsDeleteSettlementBody => 'Remover este pagamento registrado?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from deve a $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer pagou · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from pagou $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'Nenhuma despesa ainda';

  @override
  String get groupsEmptyExpensesBody =>
      'Toque em «Adicionar despesa» para dividir sua primeira conta.';

  @override
  String get expensesEditTitle => 'Editar despesa';

  @override
  String get expensesAddTitle => 'Adicionar despesa';

  @override
  String get expensesDetailTitle => 'Despesa';

  @override
  String get expensesNotFound => 'Despesa não encontrada';

  @override
  String get expensesAmount => 'Valor';

  @override
  String get expensesAmountSubtitle => 'Valor total da conta';

  @override
  String get expensesDescription => 'Descrição';

  @override
  String get expensesDescriptionHint => 'ex.: Jantar, Compras, Táxi';

  @override
  String get expensesDate => 'Data';

  @override
  String get expensesPaidBy => 'Pago por';

  @override
  String get expensesPaidBySubtitle => 'Quem cobriu esta conta';

  @override
  String get expensesPaidByHeader => 'PAGO POR';

  @override
  String get expensesPayerSingle => 'Único';

  @override
  String get expensesPayerMultiple => 'Vários';

  @override
  String get expensesSplit => 'Divisão';

  @override
  String get expensesSplitSubtitle => 'Como dividir o custo';

  @override
  String get expensesSplitEqual => 'Igual';

  @override
  String get expensesSplitExact => 'Exato';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Valores exatos';

  @override
  String get expensesSplitByPercentage => 'Por porcentagem';

  @override
  String get expensesSplitEqually => 'Dividir igualmente';

  @override
  String get expensesSplitBreakdown => 'DETALHAMENTO DA DIVISÃO';

  @override
  String get expensesNote => 'Nota';

  @override
  String get expensesNoteHint => 'Nota opcional';

  @override
  String get expensesSaveChanges => 'Salvar alterações';

  @override
  String get expensesSaveExpense => 'Salvar despesa';

  @override
  String get expensesSubtitlePaid => 'pagou';

  @override
  String get expensesSubtitleAlsoPaid => 'também pagou';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Cada pagamento não deve exceder $amount';
  }

  @override
  String get expensesEnterValidPayments =>
      'Insira valores de pagamento válidos';

  @override
  String expensesOverBy(String amount) {
    return 'Excedente de $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'Faltam $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Total de pagamentos $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Cada parte não deve exceder $amount';
  }

  @override
  String get expensesEnterValidSplits => 'Insira valores de divisão válidos';

  @override
  String get expensesPercentOver100 => 'Cada parte deve ser 100% ou menos';

  @override
  String get expensesEnterValidPercents =>
      'Insira porcentagens de divisão válidas';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Total $total% — reduza $over%';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Total $total% — faltam $remaining%';
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
  String get settlementsEditTitle => 'Editar acerto';

  @override
  String get settlementsRecordTitle => 'Registrar acerto';

  @override
  String get settlementsFromPays => 'DE (PAGA)';

  @override
  String get settlementsToReceives => 'PARA (RECEBE)';

  @override
  String get settlementsAmount => 'VALOR';

  @override
  String get settlementsNoteOptional => 'NOTA (OPCIONAL)';

  @override
  String get settlementsNoteHint => 'Dinheiro, transferência bancária…';

  @override
  String get settlementsSaveChanges => 'Salvar alterações';

  @override
  String get settlementsRecordPayment => 'Registrar pagamento';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileYourName => 'Seu nome';

  @override
  String get profileLanguage => 'IDIOMA';

  @override
  String get profileLanguageHint =>
      'Segue o idioma do dispositivo, a menos que você escolha um.';

  @override
  String get profileLanguageSystem => 'Sistema';

  @override
  String get profileAppearance => 'APARÊNCIA';

  @override
  String get profileAppearanceHint =>
      'Segue o dispositivo, a menos que você escolha Claro ou Escuro.';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Escuro';

  @override
  String get profileDefaultCurrencyHeader => 'MOEDA PADRÃO';

  @override
  String get profileDefaultCurrencyHint =>
      'Usada para novas cenas e o resumo da tela inicial.';

  @override
  String get profileDefaultCurrencySheet => 'Moeda padrão';

  @override
  String get profileManage => 'GERENCIAR';

  @override
  String get profilePeople => 'Pessoas';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
      zero: 'Nenhuma pessoa ainda',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Dados e backup';

  @override
  String get profileDataBackupSubtitle => 'Exportar ou importar seus dados';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'Sobre $appName';
  }

  @override
  String get profileAboutSubtitle =>
      'Privacidade, contato, feedback e compartilhar';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'Pessoas';

  @override
  String get peopleAddPerson => 'Adicionar pessoa';

  @override
  String get peopleAddHint => 'ex.: Alice';

  @override
  String get peopleEditName => 'Editar nome';

  @override
  String get peopleDeleteTitle => 'Excluir pessoa?';

  @override
  String peopleDeleteBody(String name) {
    return 'Remover $name da sua lista de pessoas? Isso não pode ser desfeito.';
  }

  @override
  String get peopleIntro => 'Todas as pessoas adicionadas nas suas cenas.';

  @override
  String get peopleSearchHint => 'Buscar por nome';

  @override
  String get peopleEmpty =>
      'Nenhuma pessoa ainda. Toque em + para adicionar alguém.';

  @override
  String get peopleNoMatch => 'Nenhuma pessoa corresponde à sua busca.';

  @override
  String get peopleSwipeHint =>
      'Deslize para a esquerda para editar ou excluir';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas',
      one: '1 cena',
      zero: 'Em nenhuma cena',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle =>
      'Valores exibidos na moeda de cada cena';

  @override
  String get peopleDetailEmptyScenes => 'Ainda não é membro de nenhuma cena.';

  @override
  String get peopleDetailAllSettled => 'Tudo acertado nas cenas';

  @override
  String get peopleDetailOpenBalances => 'Saldos em aberto em algumas cenas';

  @override
  String peopleDetailGets(String name) {
    return '$name recebe';
  }

  @override
  String peopleDetailWillGive(String name) {
    return '$name deve';
  }

  @override
  String get peopleDetailSettledInScene => 'Acertado';

  @override
  String get peopleDetailNoDebts => 'Sem dívidas em aberto nesta cena';

  @override
  String get peopleDetailViewExpenses => 'Ver participação nas despesas';

  @override
  String get peopleDetailExpensesSection => 'DESPESAS';

  @override
  String get dataTitle => 'Dados e backup';

  @override
  String get dataWebBlurb =>
      'Exportação e importação de backup estão disponíveis nos apps móvel e desktop. Seus dados são armazenados localmente neste navegador.';

  @override
  String get dataNativeBlurb =>
      'Exporte um backup e salve no seu dispositivo ou compartilhe em outro lugar. A importação substitui tudo neste dispositivo.';

  @override
  String get dataExportBackup => 'Exportar backup';

  @override
  String get dataImportBackup => 'Importar backup';

  @override
  String get dataCouldNotExport => 'Não foi possível exportar o backup.';

  @override
  String get dataSaveBackupDialog => 'Salvar backup';

  @override
  String get dataBackupSaved => 'Backup salvo.';

  @override
  String get dataCouldNotSave => 'Não foi possível salvar o backup.';

  @override
  String get dataShareSubject => 'Backup do SceneSplit';

  @override
  String get dataShareText => 'Backup do banco de dados SceneSplit';

  @override
  String get dataCouldNotShare => 'Não foi possível compartilhar o backup.';

  @override
  String get dataImportTitle => 'Importar backup?';

  @override
  String get dataImportBody =>
      'Importar um backup substituirá todos os dados atualmente no SceneSplit neste dispositivo. Isso não pode ser desfeito.';

  @override
  String get dataImportSuccess => 'Backup importado com sucesso.';

  @override
  String get dataCouldNotImport => 'Não foi possível importar o backup.';

  @override
  String get dataBackupReady => 'Backup pronto';

  @override
  String get dataSaveToDevice => 'Salvar no dispositivo';

  @override
  String get dataSaveToDeviceSubtitle => 'Escolher pasta e nome do arquivo';

  @override
  String get dataShare => 'Compartilhar';

  @override
  String get dataShareSubtitle => 'Enviar por e-mail, Drive, AirDrop, etc.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutCouldNotOpenEmail => 'Não foi possível abrir o app de e-mail';

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Divida despesas com amigos.\nOffline primeiro. Sem conta necessária.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutTermsOfService => 'Termos de serviço';

  @override
  String get aboutContactUs => 'Fale conosco';

  @override
  String get aboutEmailSupportSubject => 'Suporte SceneSplit';

  @override
  String get aboutSendFeedback => 'Enviar feedback';

  @override
  String get aboutEmailFeedbackSubject => 'Feedback SceneSplit';

  @override
  String get aboutSuggestFeature => 'Sugerir um recurso';

  @override
  String get aboutEmailFeatureSubject => 'Sugestão de recurso SceneSplit';

  @override
  String aboutRateApp(String appName) {
    return 'Avaliar $appName';
  }

  @override
  String get aboutShareApp => 'Compartilhar app';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Experimente o $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Conheça o $appName — divida despesas com amigos. Offline primeiro, sem conta.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'Não foi possível compartilhar o app.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Política de privacidade';

  @override
  String get legalTermsTitle => 'Termos de serviço';

  @override
  String legalLoadError(String error) {
    return 'Não foi possível carregar o documento: $error';
  }

  @override
  String get sharedSettledTitle => 'Tudo quitado';

  @override
  String get sharedSettledSubtitle => 'Nenhum saldo pendente nesta cena';

  @override
  String get sharedYouGet => 'Você recebe';

  @override
  String get sharedYouWillGive => 'Você deve';

  @override
  String get sharedNoChartData => 'Sem dados para o gráfico';

  @override
  String get sharedTotal => 'Total';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent%';
  }

  @override
  String get sharedChooseLanguage => 'Escolher idioma';

  @override
  String get sharedChooseCurrency => 'Escolher moeda';

  @override
  String get sharedCurrencySearchHint => 'Buscar por nome, código ou símbolo';

  @override
  String get sharedNoCurrenciesFound => 'Nenhuma moeda encontrada';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Emoji personalizado';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a e $b';
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
    return 'Já existe alguém chamado «$name».';
  }

  @override
  String get errorCannotDeleteSelf => 'Você não pode se excluir.';

  @override
  String get errorUserHasFinancialActivity =>
      'Esta pessoa tem despesas ou acertos e não pode ser excluída.';

  @override
  String get errorBackupCorrupt =>
      'Não foi possível abrir o arquivo de backup. Ele pode estar corrompido ou não ser um banco de dados SQLite.';

  @override
  String get errorBackupVersionMismatch =>
      'Este backup é de uma versão diferente do app e não pode ser importado.';

  @override
  String get errorBackupNotSceneSplit =>
      'Este arquivo não parece ser um backup do SceneSplit.';

  @override
  String get errorBackupExportWeb =>
      'Exportação de backup não está disponível na web. Use o app móvel ou desktop para exportar backups.';

  @override
  String get errorBackupImportWeb =>
      'Importação de backup não está disponível na web. Use o app móvel ou desktop para importar backups.';

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
