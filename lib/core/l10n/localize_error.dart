import 'package:flutter/widgets.dart';

import '../../repositories/group_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/database_backup_exception.dart';
import 'l10n_extensions.dart';

/// Maps typed domain exceptions to localized user-facing copy.
String localizeError(BuildContext context, Object error) {
  final l10n = context.l10n;

  if (error is UserNameTakenException) {
    return l10n.errorUserNameTaken(error.name);
  }
  if (error is UserDeleteBlockedException) {
    return switch (error.reason) {
      UserDeleteBlockedReason.cannotDeleteSelf => l10n.errorCannotDeleteSelf,
      UserDeleteBlockedReason.hasFinancialActivity =>
        l10n.errorUserHasFinancialActivity,
    };
  }
  if (error is MemberRemovalBlockedException) {
    final name = error.name ?? l10n.groupsThisMember;
    return l10n.groupsRemovalBlockedOther(name);
  }
  if (error is DatabaseBackupException) {
    return switch (error.code) {
      DatabaseBackupErrorCode.corrupt => l10n.errorBackupCorrupt,
      DatabaseBackupErrorCode.versionMismatch =>
        l10n.errorBackupVersionMismatch,
      DatabaseBackupErrorCode.notSceneSplit => l10n.errorBackupNotSceneSplit,
      DatabaseBackupErrorCode.exportUnavailableOnWeb =>
        l10n.errorBackupExportWeb,
      DatabaseBackupErrorCode.importUnavailableOnWeb =>
        l10n.errorBackupImportWeb,
      DatabaseBackupErrorCode.unknown =>
        error.message ?? l10n.commonErrorWithDetail(error.toString()),
    };
  }

  return l10n.commonErrorWithDetail('$error');
}
