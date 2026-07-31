import 'dart:typed_data';

/// Why a backup file cannot be validated or restored.
enum DatabaseBackupErrorCode {
  corrupt,
  versionMismatch,
  notSceneSplit,
  exportUnavailableOnWeb,
  importUnavailableOnWeb,
  unknown,
}

/// Thrown when a backup file cannot be validated or restored.
class DatabaseBackupException implements Exception {
  DatabaseBackupException(this.code, [this.message]);

  final DatabaseBackupErrorCode code;
  final String? message;

  @override
  String toString() => message ?? code.name;
}

/// A SQLite backup file ready for save or share.
class ExportedDatabaseBackup {
  const ExportedDatabaseBackup({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}
