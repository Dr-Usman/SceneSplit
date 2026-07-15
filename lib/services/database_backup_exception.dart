import 'dart:typed_data';

/// Thrown when a backup file cannot be validated or restored.
class DatabaseBackupException implements Exception {
  DatabaseBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A SQLite backup file ready for save or share.
class ExportedDatabaseBackup {
  const ExportedDatabaseBackup({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}
