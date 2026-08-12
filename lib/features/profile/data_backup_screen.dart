import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/localize_error.dart';
import '../../database/app_database.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/database_provider.dart';
import '../../services/database_backup_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/settings_tile.dart';
import 'backup_export_sheet.dart';

/// Export and import SceneSplit database backups.
class DataBackupScreen extends ConsumerStatefulWidget {
  const DataBackupScreen({super.key});

  @override
  ConsumerState<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends ConsumerState<DataBackupScreen> {
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
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.dataCouldNotExport)),
        );
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _saveBackupFile(ExportedDatabaseBackup backup) async {
    try {
      final saved = await FilePicker.saveFile(
        dialogTitle: context.l10n.dataSaveBackupDialog,
        fileName: backup.fileName,
        bytes: backup.bytes,
      );
      if (saved != null && mounted) {
        ref.read(analyticsServiceProvider).trackBackupExported(method: 'save');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.dataBackupSaved)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.dataCouldNotSave)));
      }
    }
  }

  Future<void> _shareBackupFile(ExportedDatabaseBackup backup) async {
    final l10n = context.l10n;
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
          subject: l10n.dataShareSubject,
          text: l10n.dataShareText,
          sharePositionOrigin: origin,
        ),
      );
      if (mounted) {
        ref.read(analyticsServiceProvider).trackBackupExported(method: 'share');
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.dataCouldNotShare)));
      }
    }
  }

  Future<void> _importBackup() async {
    if (_backupBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.dataImportTitle),
        content: Text(ctx.l10n.dataImportBody),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(ctx.l10n.commonCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(ctx.l10n.commonImport),
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
        ref.read(analyticsServiceProvider).trackBackupImported();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.dataImportSuccess)));
      }
    } on DatabaseBackupException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.dataCouldNotImport)),
        );
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            kIsWeb ? l10n.dataWebBlurb : l10n.dataNativeBlurb,
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
                    title: l10n.dataExportBackup,
                    onTap: () {
                      if (!_backupBusy) _exportBackup();
                    },
                  ),
                  SettingsTile(
                    icon: Icons.download_outlined,
                    title: l10n.dataImportBackup,
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
