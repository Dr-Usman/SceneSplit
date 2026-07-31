import '../database/app_database.dart';
import 'database_backup_exception.dart';

Future<ExportedDatabaseBackup> exportDatabaseBackup(AppDatabase db) {
  throw DatabaseBackupException(DatabaseBackupErrorCode.exportUnavailableOnWeb);
}

void validateBackupFile(
  String backupPath, {
  required int expectedSchemaVersion,
}) {
  throw DatabaseBackupException(DatabaseBackupErrorCode.importUnavailableOnWeb);
}

Future<void> importDatabaseBackup(
  String backupPath, {
  required int expectedSchemaVersion,
}) {
  throw DatabaseBackupException(DatabaseBackupErrorCode.importUnavailableOnWeb);
}
