import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../database/app_database.dart';
import '../database/database_paths.dart';

const _requiredTables = [
  'users',
  'app_settings',
  'groups',
  'group_members',
  'expenses',
  'expense_splits',
  'settlements',
];

/// Thrown when a backup file cannot be validated or restored.
class DatabaseBackupException implements Exception {
  DatabaseBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exports the open database to a consistent SQLite file in the temp directory.
Future<File> exportDatabaseBackup(AppDatabase db) async {
  final tempDir = await getTemporaryDirectory();
  final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
  final file = File(
    p.join(tempDir.path, 'scene_split_backup_$timestamp.sqlite'),
  );

  await file.parent.create(recursive: true);
  if (file.existsSync()) {
    file.deleteSync();
  }

  await db.customStatement('VACUUM INTO ?', [file.path]);
  return file;
}

/// Validates a backup file without modifying the live database.
void validateBackupFile(String backupPath, {required int expectedSchemaVersion}) {
  Database? backupDb;
  try {
    backupDb = sqlite3.open(backupPath, mode: OpenMode.readOnly);
  } on Object {
    throw DatabaseBackupException(
      'Could not open backup file. It may be corrupt or not a SQLite database.',
    );
  }

  try {
    final versionRow = backupDb.select('PRAGMA user_version');
    final userVersion = versionRow.isNotEmpty
        ? versionRow.first.columnAt(0) as int
        : 0;

    if (userVersion != expectedSchemaVersion) {
      throw DatabaseBackupException(
        'This backup is from a different app version and cannot be imported.',
      );
    }

    final tableRows = backupDb.select(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final tableNames = tableRows
        .map((row) => row.columnAt(0) as String)
        .toSet();

    for (final table in _requiredTables) {
      if (!tableNames.contains(table)) {
        throw DatabaseBackupException(
          'This file does not look like a SceneSplit backup.',
        );
      }
    }
  } finally {
    backupDb.close();
  }
}

/// Replaces the live database file with [backupPath] after validation.
///
/// [db] must be closed by the caller before invoking this method.
Future<void> importDatabaseBackup(
  String backupPath, {
  required int expectedSchemaVersion,
}) async {
  validateBackupFile(backupPath, expectedSchemaVersion: expectedSchemaVersion);

  final databasePath = await resolveDatabasePath();
  final tempDir = await getTemporaryDirectory();
  final tempDbPath = p.join(
    tempDir.path,
    'scene_split_import_${DateTime.now().millisecondsSinceEpoch}.sqlite',
  );

  final backupDb = sqlite3.open(backupPath);
  try {
    if (File(tempDbPath).existsSync()) {
      File(tempDbPath).deleteSync();
    }
    backupDb.execute('VACUUM INTO ?', [tempDbPath]);
  } finally {
    backupDb.close();
  }

  final tempDbFile = File(tempDbPath);
  try {
    await tempDbFile.copy(databasePath);
  } finally {
    if (tempDbFile.existsSync()) {
      await tempDbFile.delete();
    }
  }

  await _deleteWalFiles(databasePath);
}

Future<void> _deleteWalFiles(String databasePath) async {
  for (final suffix in ['-wal', '-shm']) {
    final file = File('$databasePath$suffix');
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
