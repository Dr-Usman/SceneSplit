import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../services/database_backup_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/settings_tile.dart';
import 'backup_export_sheet.dart';

class DataScreen extends ConsumerStatefulWidget {
  const DataScreen({super.key});

  @override
  ConsumerState<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends ConsumerState<DataScreen> {
  bool _backupBusy = false;

  Future<void> _exportBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      final db = ref.read(databaseProvider);
      final backup = await exportDatabaseBackup(db);
      if (!mounted) return;

      setState(() => _backupBusy = false);

      final action = await showBackupExportSheet(
        context,
        fileName: backup.fileName,
      );
      if (!mounted || action == null) return;

      if (action == BackupExportAction.save) {
        await _saveBackupFile(backup);
      } else {
        await _shareBackupFile(backup);
      }
    } on DatabaseBackupException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export backup.')),
        );
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _saveBackupFile(ExportedDatabaseBackup backup) async {
    try {
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save backup',
        fileName: backup.fileName,
        bytes: backup.bytes,
      );
      if (saved != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup saved.')));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not save backup.')));
      }
    }
  }

  Future<void> _shareBackupFile(ExportedDatabaseBackup backup) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              backup.bytes,
              name: backup.fileName,
              mimeType: 'application/x-sqlite3',
            ),
          ],
          subject: 'SceneSplit backup',
          text: 'SceneSplit database backup',
          sharePositionOrigin: origin,
        ),
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share backup.')),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    if (_backupBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import backup?'),
        content: const Text(
          'Importing a backup will replace all data currently in '
          'SceneSplit on this device. This cannot be undone.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite', 'db'],
    );
    if (picked == null || picked.files.single.path == null || !mounted) {
      return;
    }

    setState(() => _backupBusy = true);
    try {
      final backupPath = picked.files.single.path!;
      validateBackupFile(
        backupPath,
        expectedSchemaVersion: AppDatabase.databaseSchemaVersion,
      );

      final db = ref.read(databaseProvider);
      await db.close();
      try {
        await importDatabaseBackup(
          backupPath,
          expectedSchemaVersion: AppDatabase.databaseSchemaVersion,
        );
        await ref.read(databaseProvider.notifier).reopen();
      } on Object {
        await ref.read(databaseProvider.notifier).reopen();
        rethrow;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup imported successfully.')),
        );
      }
    } on DatabaseBackupException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not import backup.')),
        );
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data & backup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            kIsWeb
                ? 'Backup export and import are available in the mobile and '
                    'desktop apps. Your data is stored locally in this browser.'
                : 'Export a backup, then save it on your device or share it '
                    'elsewhere. Import replaces everything on this device.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.upload_file_outlined,
                    title: 'Export backup',
                    onTap: () {
                      if (!_backupBusy) _exportBackup();
                    },
                  ),
                  SettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Import backup',
                    showDivider: false,
                    onTap: () {
                      if (!_backupBusy) _importBackup();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
