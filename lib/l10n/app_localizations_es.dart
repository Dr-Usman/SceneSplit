// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String commonSomethingWentWrong(String error) {
    return 'Algo salió mal: $error';
  }

  @override
  String commonErrorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonImport => 'Importar';

  @override
  String commonYouSuffix(String name) {
    return '$name (tú)';
  }

  @override
  String commonNameAlreadyInList(String name) {
    return '«$name» ya está en la lista.';
  }

  @override
  String get commonUnknown => 'Desconocido';

  @override
  String get onboardingTagline =>
      'Divide gastos con amigos.\nSin cuentas, sin complicaciones.';

  @override
  String get onboardingYourName => 'TU NOMBRE';

  @override
  String get onboardingNameHint => 'p. ej. Juan Pérez';

  @override
  String get onboardingCurrency => 'MONEDA';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get onboardingPrivacyNote => 'Todo permanece en tu dispositivo.';

  @override
  String get homeNewGroup => 'Nueva escena';

  @override
  String get homeGroupsHeader => 'ESCENAS';

  @override
  String get homeYouGetByGroup => 'Recibirás por escena';

  @override
  String get homeYouWillGiveByGroup => 'Deberás por escena';

  @override
  String get homeBreakdownSubtitle =>
      'Importes mostrados en la moneda de cada escena';

  @override
  String get homeYouWillGet => 'Recibirás';

  @override
  String get homeYouWillGive => 'Deberás';

  @override
  String get homeSettledUp => 'al día';

  @override
  String get homeCardYouWillGet => 'recibirás';

  @override
  String get navScenes => 'Escenas';

  @override
  String get navBalances => 'Saldos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get balancesTitle => 'Saldos';

  @override
  String get balancesSubtitle => 'Mira quién le debe a quién en tus escenas.';

  @override
  String get balancesWho => 'Quién';

  @override
  String get balancesWhom => 'A quién';

  @override
  String get balancesFilterTitle => 'Quién debe a quién';

  @override
  String get balancesFilterHint =>
      'Elige quién le debe a quién para filtrar deudas abiertas.';

  @override
  String get balancesAnyone => 'Cualquiera';

  @override
  String get balancesOwes => 'debe a';

  @override
  String get balancesClear => 'Borrar';

  @override
  String get balancesShowResults => 'Mostrar resultados';

  @override
  String get balancesClearSelection => 'Borrar selección';

  @override
  String get balancesEmpty => 'No hay deudas abiertas en tus escenas.';

  @override
  String get balancesEmptyFiltered =>
      'Ninguna deuda abierta coincide con esta selección.';

  @override
  String get balancesPickPerson => 'Seleccionar una persona';

  @override
  String get balancesNoPeopleFound => 'No se encontraron personas';

  @override
  String balancesCurrencySection(String currency) {
    return '$currency';
  }

  @override
  String get balancesOpenDebtTotal => 'Deuda abierta';

  @override
  String balancesOpenDebtCurrency(String currency) {
    return 'Deuda abierta ($currency)';
  }

  @override
  String get balancesYouAreOwed => 'Te deben';

  @override
  String get balancesYouOwe => 'Debes';

  @override
  String get balancesHeroOwed => 'Recibe';

  @override
  String get balancesHeroOwe => 'Debe';

  @override
  String balancesHeroOwedBreakdown(String name) {
    return 'Quién le debe a $name';
  }

  @override
  String balancesHeroOweBreakdown(String name) {
    return 'A quién debe $name';
  }

  @override
  String get balancesHeroNetLabel => 'Neto';

  @override
  String balancesHeroNetOwes(String debtor, String creditor) {
    return '$debtor debe a $creditor';
  }

  @override
  String get balancesShareTotal => 'Total de la parte';

  @override
  String get balancesExpenseTotal => 'Total de gastos';

  @override
  String get balancesScenesHeader => 'ESCENAS';

  @override
  String get balancesSettleInScene => 'Liquidar';

  @override
  String get balancesViewShares => 'Partes de gastos';

  @override
  String get balancesPairSettled => 'Liquidado entre estas personas';

  @override
  String balancesPairBetween(String a, String b) {
    return '$a y $b';
  }

  @override
  String get balancesSelectPerson => 'Toca para seleccionar';

  @override
  String get homeCardYouWillGive => 'deberás';

  @override
  String homeMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '1 miembro',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'Aún no hay escenas';

  @override
  String get homeEmptyBody =>
      'Crea una escena para un viaje, cena\no hogar compartido y empieza a dividir.';

  @override
  String get groupsNewGroup => 'Nueva escena';

  @override
  String get groupsEditGroup => 'Editar escena';

  @override
  String get groupsGroupName => 'NOMBRE DE LA ESCENA';

  @override
  String get groupsNameHint => 'p. ej. Viaje a Japón';

  @override
  String get groupsIcon => 'ICONO';

  @override
  String get groupsCurrency => 'MONEDA';

  @override
  String get groupsMembers => 'MIEMBROS';

  @override
  String get groupsAddMemberHint => 'Añadir miembro por nombre';

  @override
  String get groupsCreateGroup => 'Crear escena';

  @override
  String get groupsSaveChanges => 'Guardar cambios';

  @override
  String get groupsRemovalBlockedYou =>
      'Tienes gastos o liquidaciones en esta escena y no puedes ser eliminado.';

  @override
  String groupsRemovalBlockedOther(String name) {
    return '$name tiene gastos o liquidaciones en esta escena y no puede ser eliminado.';
  }

  @override
  String get groupsThisMember => 'Este miembro';

  @override
  String groupsCurrencySubtitle(String symbol, String name, String code) {
    return '$symbol — $name ($code)';
  }

  @override
  String get groupsDeleteGroup => 'Eliminar escena';

  @override
  String get groupsAddExpense => 'Añadir gasto';

  @override
  String get groupsExpenseBreakdown => 'DESGLOSE DE GASTOS';

  @override
  String groupsMemberShareTitle(String name) {
    return 'Parte de $name';
  }

  @override
  String groupsMemberShareExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '1 gasto',
    );
    return '$_temp0';
  }

  @override
  String groupsMemberShareOfAmount(String amount) {
    return 'de $amount';
  }

  @override
  String get groupsMemberShareTotalLabel => 'Parte total';

  @override
  String groupsMembersHeader(int count) {
    return 'MIEMBROS ($count)';
  }

  @override
  String get groupsManage => 'Administrar';

  @override
  String get groupsWhoOwesWhom => 'QUIÉN DEBE A QUIÉN';

  @override
  String get groupsSettleUp => 'Liquidar';

  @override
  String get groupsShareBalances => 'Compartir';

  @override
  String groupsShareBalancesSubject(String groupName) {
    return 'Saldos — $groupName';
  }

  @override
  String groupsShareBalancesText(String groupName) {
    return 'Quién debe a quién en $groupName';
  }

  @override
  String get groupsShareAllSettled => 'Todo liquidado';

  @override
  String get groupsExpenseShares => 'Participaciones en gastos';

  @override
  String get groupsCouldNotShareBalances =>
      'No se pudieron compartir los saldos.';

  @override
  String get groupsShareExpenses => 'Compartir';

  @override
  String get groupsShareExpensesRangeTitle => 'Elegir fechas';

  @override
  String get groupsShareExpensesRangeAll => 'Todas las fechas';

  @override
  String get groupsShareExpensesRangeAllSubtitle =>
      'Todos los gastos de esta escena';

  @override
  String get groupsShareExpensesRangeMonth => 'Este mes';

  @override
  String get groupsShareExpensesRangeMonthSubtitle =>
      'Desde el día 1 hasta hoy';

  @override
  String get groupsShareExpensesRangeLast7 => 'Últimos 7 días';

  @override
  String get groupsShareExpensesRangeLast7Subtitle => 'Incluyendo hoy';

  @override
  String get groupsShareExpensesRangeCustom => 'Rango personalizado';

  @override
  String get groupsShareExpensesRangeCustomSubtitle =>
      'Elige fecha de inicio y fin';

  @override
  String get groupsShareExpensesFormatTitle => 'Cómo compartir';

  @override
  String get groupsShareExpensesFormatImage => 'Imagen';

  @override
  String get groupsShareExpensesFormatImageSubtitle =>
      'Lista compacta como foto';

  @override
  String get groupsShareExpensesFormatText => 'Texto';

  @override
  String get groupsShareExpensesFormatTextSubtitle =>
      'Quién pagó y la parte de cada persona';

  @override
  String get groupsShareExpensesEmptyRange =>
      'No hay gastos en este rango de fechas.';

  @override
  String get groupsCouldNotShareExpenses =>
      'No se pudieron compartir los gastos.';

  @override
  String groupsShareExpensesSubject(String groupName) {
    return 'Gastos — $groupName';
  }

  @override
  String groupsShareExpensesCaption(String groupName) {
    return 'Gastos en $groupName';
  }

  @override
  String groupsShareExpensesCaptionWithRange(String groupName, String range) {
    return 'Gastos en $groupName ($range)';
  }

  @override
  String groupsShareExpensesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String groupsShareExpensesAndMore(int count) {
    return 'y $count más';
  }

  @override
  String groupsShareExpensesPayerPaidDatePeople(
    String payer,
    String date,
    String people,
  ) {
    return '$payer pagó · $date · $people';
  }

  @override
  String groupsShareExpensesPaidDateAmount(
    String payer,
    String date,
    String amount,
  ) {
    return '$payer pagó · $date · $amount';
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
  String get groupsShareExpensesByPerson => 'Por persona';

  @override
  String get groupsSettlements => 'LIQUIDACIONES';

  @override
  String get groupsExpenses => 'GASTOS';

  @override
  String get groupsSettlementsTitle => 'Liquidaciones';

  @override
  String get groupsExpensesTitle => 'Gastos';

  @override
  String groupsSettlementsScreenTitle(String groupName) {
    return '$groupName · Liquidaciones';
  }

  @override
  String groupsExpensesScreenTitle(String groupName) {
    return '$groupName · Gastos';
  }

  @override
  String groupsViewAllCount(int count) {
    return 'Ver todo ($count)';
  }

  @override
  String get groupsEmptySettlementsBody =>
      'Aún no hay liquidaciones registradas.';

  @override
  String get groupsSwipeToDeleteHint => 'Desliza a la izquierda para eliminar';

  @override
  String get groupsDeleteExpenseTitle => '¿Eliminar gasto?';

  @override
  String groupsDeleteExpenseBody(String title) {
    return '¿Eliminar «$title» de esta escena?';
  }

  @override
  String get groupsDeleteGroupTitle => '¿Eliminar escena?';

  @override
  String groupsDeleteGroupBody(String name) {
    return '¿Eliminar «$name» y todos sus gastos? Esto no se puede deshacer.';
  }

  @override
  String get groupsDeleteSettlementTitle => '¿Eliminar liquidación?';

  @override
  String get groupsDeleteSettlementBody => '¿Eliminar este pago registrado?';

  @override
  String groupsOwesTemplate(String from, String to) {
    return '$from debe a $to';
  }

  @override
  String groupsPayerPaidDate(String payer, String date) {
    return '$payer pagó · $date';
  }

  @override
  String groupsSettlementPaid(String from, String to) {
    return '$from pagó a $to';
  }

  @override
  String get groupsEmptyExpensesTitle => 'Aún no hay gastos';

  @override
  String get groupsEmptyExpensesBody =>
      'Toca «Añadir gasto» para dividir tu primera cuenta.';

  @override
  String get expensesEditTitle => 'Editar gasto';

  @override
  String get expensesAddTitle => 'Añadir gasto';

  @override
  String get expensesDetailTitle => 'Gasto';

  @override
  String get expensesNotFound => 'Gasto no encontrado';

  @override
  String get expensesAmount => 'Importe';

  @override
  String get expensesAmountSubtitle => 'Importe total de la cuenta';

  @override
  String get expensesDescription => 'Descripción';

  @override
  String get expensesDescriptionHint => 'p. ej. Cena, Compras, Taxi';

  @override
  String get expensesDate => 'Fecha';

  @override
  String get expensesPaidBy => 'Pagado por';

  @override
  String get expensesPaidBySubtitle => 'Quién cubrió esta cuenta';

  @override
  String get expensesPaidByHeader => 'PAGADO POR';

  @override
  String get expensesPayerSingle => 'Uno';

  @override
  String get expensesPayerMultiple => 'Varios';

  @override
  String get expensesSplit => 'División';

  @override
  String get expensesSplitSubtitle => 'Cómo dividir el coste';

  @override
  String get expensesSplitEqual => 'Igual';

  @override
  String get expensesSplitExact => 'Exacto';

  @override
  String get expensesSplitPercent => '%';

  @override
  String get expensesSplitExactAmounts => 'Importes exactos';

  @override
  String get expensesSplitByPercentage => 'Por porcentaje';

  @override
  String get expensesSplitEqually => 'Dividir por igual';

  @override
  String get expensesSplitBreakdown => 'DESGLOSE DE LA DIVISIÓN';

  @override
  String get expensesNote => 'Nota';

  @override
  String get expensesNoteHint => 'Nota opcional';

  @override
  String get expensesSaveChanges => 'Guardar cambios';

  @override
  String get expensesSaveExpense => 'Guardar gasto';

  @override
  String get expensesSubtitlePaid => 'pagó';

  @override
  String get expensesSubtitleAlsoPaid => 'también pagó';

  @override
  String expensesPaymentExceeds(String amount) {
    return 'Cada pago no debe superar $amount';
  }

  @override
  String get expensesEnterValidPayments => 'Introduce importes de pago válidos';

  @override
  String expensesOverBy(String amount) {
    return 'Excede por $amount';
  }

  @override
  String expensesAmountRemaining(String amount) {
    return 'Quedan $amount';
  }

  @override
  String expensesPaymentsTotal(String amount) {
    return 'Total de pagos $amount';
  }

  @override
  String expensesShareExceeds(String amount) {
    return 'Cada parte no debe superar $amount';
  }

  @override
  String get expensesEnterValidSplits =>
      'Introduce importes de división válidos';

  @override
  String get expensesPercentOver100 => 'Cada parte debe ser del 100 % o menos';

  @override
  String get expensesEnterValidPercents =>
      'Introduce porcentajes de división válidos';

  @override
  String expensesPercentReduce(String total, String over) {
    return 'Total $total % — reduce $over %';
  }

  @override
  String expensesPercentRemaining(String total, String remaining) {
    return 'Total $total % — quedan $remaining %';
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
  String get settlementsEditTitle => 'Editar liquidación';

  @override
  String get settlementsRecordTitle => 'Registrar liquidación';

  @override
  String get settlementsFromPays => 'DE (PAGA)';

  @override
  String get settlementsToReceives => 'A (RECIBE)';

  @override
  String get settlementsAmount => 'IMPORTE';

  @override
  String get settlementsNoteOptional => 'NOTA (OPCIONAL)';

  @override
  String get settlementsNoteHint => 'Efectivo, transferencia bancaria…';

  @override
  String get settlementsSaveChanges => 'Guardar cambios';

  @override
  String get settlementsRecordPayment => 'Registrar pago';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileYourName => 'Tu nombre';

  @override
  String get profileLanguage => 'IDIOMA';

  @override
  String get profileLanguageHint =>
      'Sigue el idioma de tu dispositivo a menos que elijas uno.';

  @override
  String get profileLanguageSystem => 'Sistema';

  @override
  String get profileAppearance => 'APARIENCIA';

  @override
  String get profileAppearanceHint =>
      'Sigue tu dispositivo a menos que elijas Claro u Oscuro.';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Oscuro';

  @override
  String get profileDefaultCurrencyHeader => 'MONEDA PREDETERMINADA';

  @override
  String get profileDefaultCurrencyHint =>
      'Se usa para escenas nuevas y el resumen de inicio.';

  @override
  String get profileDefaultCurrencySheet => 'Moneda predeterminada';

  @override
  String get profileManage => 'ADMINISTRAR';

  @override
  String get profilePeople => 'Personas';

  @override
  String profilePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
      zero: 'Aún no hay personas',
    );
    return '$_temp0';
  }

  @override
  String get profileDataBackup => 'Datos y copia de seguridad';

  @override
  String get profileDataBackupSubtitle => 'Exportar o importar tus datos';

  @override
  String get profileApp => 'APP';

  @override
  String profileAboutApp(String appName) {
    return 'Acerca de $appName';
  }

  @override
  String get profileAboutSubtitle =>
      'Privacidad, contacto, comentarios y compartir';

  @override
  String profileVersionFooter(String appName, String version, String build) {
    return '$appName v$version ($build)';
  }

  @override
  String get peopleTitle => 'Personas';

  @override
  String get peopleAddPerson => 'Añadir persona';

  @override
  String get peopleAddHint => 'p. ej. Alicia';

  @override
  String get peopleEditName => 'Editar nombre';

  @override
  String get peopleDeleteTitle => '¿Eliminar persona?';

  @override
  String peopleDeleteBody(String name) {
    return '¿Eliminar a $name de tu lista de personas? Esto no se puede deshacer.';
  }

  @override
  String get peopleIntro => 'Todas las personas añadidas en tus escenas.';

  @override
  String get peopleSearchHint => 'Buscar por nombre';

  @override
  String get peopleEmpty =>
      'Aún no hay personas. Toca + para añadir a alguien.';

  @override
  String get peopleNoMatch => 'Ninguna persona coincide con tu búsqueda.';

  @override
  String get peopleSwipeHint => 'Desliza a la izquierda para editar o eliminar';

  @override
  String peopleSceneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas',
      one: '1 escena',
      zero: 'En ninguna escena',
    );
    return '$_temp0';
  }

  @override
  String get peopleDetailCurrencySubtitle =>
      'Importes mostrados en la moneda de cada escena';

  @override
  String get peopleDetailEmptyScenes => 'Aún no es miembro de ninguna escena.';

  @override
  String get peopleDetailAllSettled => 'Todo saldado en las escenas';

  @override
  String get peopleDetailOpenBalances => 'Saldos abiertos en algunas escenas';

  @override
  String peopleDetailGets(String name) {
    return 'Crédito total de $name';
  }

  @override
  String peopleDetailWillGive(String name) {
    return 'Deuda total de $name';
  }

  @override
  String get peopleDetailYourTotalCredit => 'Tu crédito total';

  @override
  String get peopleDetailYourTotalDebt => 'Tu deuda total';

  @override
  String get peopleDetailSettledInScene => 'Saldado';

  @override
  String get peopleDetailNoDebts => 'No hay deudas abiertas en esta escena';

  @override
  String get peopleDetailViewExpenses => 'Ver parte de gastos';

  @override
  String get peopleDetailExpensesSection => 'GASTOS';

  @override
  String get dataTitle => 'Datos y copia de seguridad';

  @override
  String get dataWebBlurb =>
      'La exportación e importación de copias de seguridad están disponibles en las apps móvil y de escritorio. Tus datos se almacenan localmente en este navegador.';

  @override
  String get dataNativeBlurb =>
      'Exporta una copia de seguridad y guárdala en tu dispositivo o compártela en otro lugar. Importar reemplaza todo en este dispositivo.';

  @override
  String get dataExportBackup => 'Exportar copia de seguridad';

  @override
  String get dataImportBackup => 'Importar copia de seguridad';

  @override
  String get dataCouldNotExport => 'No se pudo exportar la copia de seguridad.';

  @override
  String get dataSaveBackupDialog => 'Guardar copia de seguridad';

  @override
  String get dataBackupSaved => 'Copia de seguridad guardada.';

  @override
  String get dataCouldNotSave => 'No se pudo guardar la copia de seguridad.';

  @override
  String get dataShareSubject => 'Copia de seguridad de SceneSplit';

  @override
  String get dataShareText =>
      'Copia de seguridad de la base de datos de SceneSplit';

  @override
  String get dataCouldNotShare => 'No se pudo compartir la copia de seguridad.';

  @override
  String get dataImportTitle => '¿Importar copia de seguridad?';

  @override
  String get dataImportBody =>
      'Importar una copia de seguridad reemplazará todos los datos actuales de SceneSplit en este dispositivo. Esto no se puede deshacer.';

  @override
  String get dataImportSuccess => 'Copia de seguridad importada correctamente.';

  @override
  String get dataCouldNotImport => 'No se pudo importar la copia de seguridad.';

  @override
  String get dataBackupReady => 'Copia de seguridad lista';

  @override
  String get dataSaveToDevice => 'Guardar en el dispositivo';

  @override
  String get dataSaveToDeviceSubtitle => 'Elige carpeta y nombre de archivo';

  @override
  String get dataShare => 'Compartir';

  @override
  String get dataShareSubtitle => 'Enviar por correo, Drive, AirDrop, etc.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutCouldNotOpenEmail => 'No se pudo abrir la app de correo';

  @override
  String aboutVersion(String version, String build) {
    return 'Versión $version ($build)';
  }

  @override
  String get aboutTagline =>
      'Divide gastos con amigos.\nSin conexión. No requiere cuenta.';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutTermsOfService => 'Términos de servicio';

  @override
  String get aboutContactUs => 'Contáctanos';

  @override
  String get aboutEmailSupportSubject => 'Soporte de SceneSplit';

  @override
  String get aboutSendFeedback => 'Enviar comentarios';

  @override
  String get aboutEmailFeedbackSubject => 'Comentarios sobre SceneSplit';

  @override
  String get aboutSuggestFeature => 'Sugerir una función';

  @override
  String get aboutEmailFeatureSubject =>
      'Sugerencia de función para SceneSplit';

  @override
  String aboutRateApp(String appName) {
    return 'Calificar $appName';
  }

  @override
  String get aboutShareApp => 'Compartir app';

  @override
  String aboutShareAppSubject(String appName) {
    return 'Prueba $appName';
  }

  @override
  String aboutShareAppMessage(String appName, String links) {
    return 'Descubre $appName: divide gastos con amigos. Sin cuenta y con prioridad offline.\n\n$links';
  }

  @override
  String get aboutCouldNotShare => 'No se pudo compartir la app.';

  @override
  String aboutCopyright(int year, String appName) {
    return '© $year $appName';
  }

  @override
  String get legalPrivacyTitle => 'Política de privacidad';

  @override
  String get legalTermsTitle => 'Términos de servicio';

  @override
  String legalLoadError(String error) {
    return 'No se pudo cargar el documento: $error';
  }

  @override
  String get sharedSettledTitle => 'Estáis todos al día';

  @override
  String get sharedSettledSubtitle => 'No hay saldos pendientes en esta escena';

  @override
  String get sharedYouGet => 'Recibes';

  @override
  String get sharedYouWillGive => 'Debes';

  @override
  String get sharedNoChartData => 'No hay datos para el gráfico';

  @override
  String get sharedTotal => 'Total';

  @override
  String sharedPercentLabel(String percent) {
    return '$percent %';
  }

  @override
  String get sharedChooseLanguage => 'Elegir idioma';

  @override
  String get sharedChooseCurrency => 'Elegir moneda';

  @override
  String get sharedCurrencySearchHint => 'Buscar por nombre, código o símbolo';

  @override
  String get sharedNoCurrenciesFound => 'No se encontraron monedas';

  @override
  String sharedCurrencyFieldLabel(String code, String name) {
    return '$code — $name';
  }

  @override
  String get sharedCustomEmoji => 'Emoji personalizado';

  @override
  String moneyTwoPayers(String a, String b) {
    return '$a y $b';
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
    return 'Ya existe alguien llamado «$name».';
  }

  @override
  String get errorCannotDeleteSelf => 'No puedes eliminarte a ti mismo.';

  @override
  String get errorUserHasFinancialActivity =>
      'Esta persona tiene gastos o liquidaciones y no puede ser eliminada.';

  @override
  String get errorBackupCorrupt =>
      'No se pudo abrir el archivo de copia de seguridad. Puede estar corrupto o no ser una base de datos SQLite.';

  @override
  String get errorBackupVersionMismatch =>
      'Esta copia de seguridad es de una versión diferente de la app y no se puede importar.';

  @override
  String get errorBackupNotSceneSplit =>
      'Este archivo no parece ser una copia de seguridad de SceneSplit.';

  @override
  String get errorBackupExportWeb =>
      'La exportación de copias de seguridad no está disponible en la web. Usa la app móvil o de escritorio para exportar copias de seguridad.';

  @override
  String get errorBackupImportWeb =>
      'La importación de copias de seguridad no está disponible en la web. Usa la app móvil o de escritorio para importar copias de seguridad.';

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
