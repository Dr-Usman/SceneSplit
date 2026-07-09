import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_links.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_link_launcher.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/user_repository.dart';
import '../../services/database_backup_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/settings_tile.dart';
import '../../shared/widgets/user_avatar.dart';
import '../about/about_screen.dart';
import '../legal/legal_document_screen.dart';
import '../legal/legal_document_type.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editingName = false;
  bool _saving = false;
  bool _backupBusy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await updateCurrentUserName(ref.read(databaseProvider), name);
    if (mounted) {
      setState(() {
        _saving = false;
        _editingName = false;
      });
    }
  }

  Future<void> _addPerson() async {
    final name = await _showNameDialog(title: 'Add person', hint: 'e.g. Alice');
    if (name == null || name.isEmpty || !mounted) return;
    await createUser(ref.read(databaseProvider), name);
  }

  Future<void> _editPerson(User person) async {
    final name = await _showNameDialog(
      title: 'Edit name',
      hint: person.name,
      initialValue: person.name,
    );
    if (name == null || name.isEmpty || name == person.name || !mounted) {
      return;
    }
    await updateUserName(ref.read(databaseProvider), person.id, name);
  }

  Future<void> _deletePerson(User person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete person?'),
        content: Text(
          'Remove ${person.name} from your people list? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await deleteUser(ref.read(databaseProvider), person.id);
    } on UserDeleteBlockedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<String?> _showNameDialog({
    required String title,
    required String hint,
    String? initialValue,
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(String subject) async {
    final info = await PackageInfo.fromPlatform();
    final body =
        '\n\n---\nApp: ${AppLinks.appName} ${info.version} (${info.buildNumber})';
    final launched = await launchEmail(subject: subject, body: body);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open email app')));
    }
  }

  Future<void> _exportBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      final db = ref.read(databaseProvider);
      final file = await exportDatabaseBackup(db);
      if (!mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'SceneSplit backup',
          text: 'SceneSplit database backup',
          sharePositionOrigin: origin,
        ),
      );
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
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
    final user = ref.watch(currentUserProvider).value;
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';
    final allUsers = [...(ref.watch(usersStreamProvider).value ?? [])]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (user != null && !_editingName && _nameController.text.isEmpty) {
      _nameController.text = user.name;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: UserAvatar(
              name: user?.name ?? '?',
              colorIndex: user?.colorIndex ?? 0,
              size: 72,
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('YOUR NAME'),
          const SizedBox(height: 8),
          if (_editingName)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : _saveName,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _editingName = false;
                    _nameController.text = user?.name ?? '';
                  }),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                user?.name ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _editingName = true),
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader('DEFAULT CURRENCY'),
          const SizedBox(height: 8),
          Text(
            'Used for new groups and the home summary.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          CurrencyPickerField(
            currencyCode: currencyCode,
            sheetTitle: 'Default currency',
            onChanged: (code) =>
                updateCurrency(ref.read(databaseProvider), code),
          ),
          const SizedBox(height: 32),
          SectionHeader(
            'PEOPLE',
            trailing: IconButton(
              onPressed: _addPerson,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: 'Add person',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everyone added across your groups.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: allUsers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No people yet. Tap + to add someone.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < allUsers.length; i++) ...[
                        _PersonRow(
                          user: allUsers[i],
                          onEdit: () => _editPerson(allUsers[i]),
                          onDelete: () => _deletePerson(allUsers[i]),
                        ),
                        if (i < allUsers.length - 1) const Divider(height: 1),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 32),
          const SectionHeader('DATA'),
          const SizedBox(height: 8),
          Text(
            'Save a backup file to restore your data later, or replace '
            'everything on this device from a backup.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
          const SizedBox(height: 32),
          const SectionHeader('SUPPORT & LEGAL'),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About ${AppLinks.appName}',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.privacy,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.terms,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Contact us',
                  onTap: () => _sendEmail('SceneSplit Support'),
                ),
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send feedback',
                  onTap: () => _sendEmail('SceneSplit Feedback'),
                ),
                SettingsTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Suggest a feature',
                  onTap: () => _sendEmail('SceneSplit Feature Suggestion'),
                ),
                SettingsTile(
                  icon: Icons.star_outline_rounded,
                  title: 'Rate ${AppLinks.appName}',
                  showDivider: false,
                  onTap: () => requestAppReview(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '…';
              return Text(
                '${AppLinks.appName} v$version',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserAvatar(name: user.name, colorIndex: user.colorIndex, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.isCurrentUser ? '${user.name} (you)' : user.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          if (!user.isCurrentUser)
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit();
                } else if (action == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit name')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
    );
  }
}
