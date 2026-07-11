import '../database/app_database.dart';
import 'database_backup_exception.dart';

Future<ExportedDatabaseBackup> exportDatabaseBackup(AppDatabase db) {
  throw DatabaseBackupException(
    'Backup export is not available on web. '
    'Use the mobile or desktop app to export backups.',
  );
}

void validateBackupFile(
  String backupPath, {
  required int expectedSchemaVersion,
}) {
  throw DatabaseBackupException(
    'Backup import is not available on web. '
    'Use the mobile or desktop app to import backups.',
  );
}

Future<void> importDatabaseBackup(
  String backupPath, {
  required int expectedSchemaVersion,
}) {
  throw DatabaseBackupException(
    'Backup import is not available on web. '
    'Use the mobile or desktop app to import backups.',
  );
}
