import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/user_repository.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _editingName = false;
  bool _saving = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
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
          _sectionLabel('YOUR NAME'),
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
                      : const Icon(Icons.check_rounded,
                          color: AppColors.primary),
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
          _sectionLabel('DEFAULT CURRENCY'),
          const SizedBox(height: 8),
          Text(
            'Used for new groups and the home summary.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
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
          Row(
            children: [
              Expanded(child: _sectionLabel('PEOPLE')),
              IconButton(
                onPressed: _addPerson,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Add person',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Everyone added across your groups.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          if (allUsers.isEmpty)
            Text(
              'No people yet. Tap + to add someone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          for (final u in allUsers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  UserAvatar(
                    name: u.name,
                    colorIndex: u.colorIndex,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      u.isCurrentUser ? '${u.name} (you)' : u.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (!u.isCurrentUser)
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editPerson(u);
                        } else if (action == 'delete') {
                          _deletePerson(u);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit name')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}
