import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/group_repository.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/group_emoji_picker.dart';
import '../../shared/widgets/user_avatar.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  String _emoji = '🧾';
  String _currencyCode = 'PKR';
  bool _saving = false;
  bool _currencyInitialized = false;

  /// Whether the current user is included in the group.
  bool _includeMe = true;

  /// Existing users toggled on.
  final _selectedUserIds = <String>{};

  /// Names typed for brand-new people.
  final _newNames = <String>[];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  int get _memberCount =>
      (_includeMe ? 1 : 0) + _selectedUserIds.length + _newNames.length;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _memberCount >= 1 && !_saving;

  void _addTypedMember() {
    final name = _memberController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _newNames.add(name);
      _memberController.clear();
    });
  }

  Future<void> _save() async {
    final me = ref.read(currentUserProvider).value;
    if (me == null) return;

    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    await createGroup(
      db,
      name: _nameController.text.trim(),
      emoji: _emoji,
      currencyCode: _currencyCode,
      existingUserIds: [if (_includeMe) me.id, ..._selectedUserIds],
      newMemberNames: _newNames,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider).value;
    final allUsers = ref.watch(usersStreamProvider).value ?? [];
    final otherUsers = allUsers.where((u) => !u.isCurrentUser).toList();
    final defaultCurrency = ref.watch(currencyCodeProvider).value ?? 'PKR';
    if (!_currencyInitialized) {
      _currencyCode = defaultCurrency;
      _currencyInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New group')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _sectionLabel(context, 'GROUP NAME'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Naran Trip'),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'ICON'),
          const SizedBox(height: 12),
          GroupEmojiPicker(
            selectedEmoji: _emoji,
            onChanged: (emoji) => setState(() => _emoji = emoji),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'CURRENCY'),
          const SizedBox(height: 8),
          CurrencyPickerField(
            currencyCode: _currencyCode,
            onChanged: (code) => setState(() => _currencyCode = code),
          ),
          const SizedBox(height: 24),
          _sectionLabel(context, 'MEMBERS'),
          const SizedBox(height: 8),
          if (me != null)
            _MemberTile(
              name: me.name,
              label: '${me.name} (you)',
              colorIndex: me.colorIndex,
              trailing: Checkbox(
                value: _includeMe,
                onChanged: (checked) =>
                    setState(() => _includeMe = checked ?? false),
              ),
            ),
          // Existing people from other groups
          for (final user in otherUsers)
            _MemberTile(
              name: user.name,
              colorIndex: user.colorIndex,
              trailing: Checkbox(
                value: _selectedUserIds.contains(user.id),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _selectedUserIds.add(user.id);
                  } else {
                    _selectedUserIds.remove(user.id);
                  }
                }),
              ),
            ),
          // Newly typed people
          for (var i = 0; i < _newNames.length; i++)
            _MemberTile(
              name: _newNames[i],
              colorIndex: (otherUsers.length + 1 + i) % 8,
              trailing: Checkbox(
                value: true,
                onChanged: (_) => setState(() => _newNames.removeAt(i)),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _memberController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Add member by name',
                    prefixIcon: Icon(Icons.person_add_alt_outlined),
                  ),
                  onSubmitted: (_) => _addTypedMember(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 54,
                height: 54,
                child: IconButton.filledTonal(
                  onPressed: _addTypedMember,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Create group'),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
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

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.name,
    required this.colorIndex,
    required this.trailing,
    this.label,
  });

  final String name;
  final String? label;
  final int colorIndex;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          UserAvatar(name: name, colorIndex: colorIndex, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label ?? name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
