import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/group_emojis.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/group_repository.dart';
import '../../shared/widgets/user_avatar.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  const EditGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  String _emoji = '🧾';
  bool _saving = false;
  bool _initialized = false;

  final _selectedMemberIds = <String>{};
  final _newNames = <String>[];

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  void _init(GroupDetailData data) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = data.group.name;
    _emoji = data.group.emoji;
    _selectedMemberIds.addAll(data.members.map((m) => m.user.id));
    _nameController.addListener(() => setState(() {}));
  }

  int get _memberCount => _selectedMemberIds.length + _newNames.length;

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
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    await updateGroup(
      db,
      groupId: widget.groupId,
      name: _nameController.text.trim(),
      emoji: _emoji,
    );

    await syncGroupMembers(
      db,
      groupId: widget.groupId,
      memberUserIds: _selectedMemberIds.toList(),
      newMemberNames: _newNames,
      colorOffset: _selectedMemberIds.length,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(groupDetailProvider(widget.groupId));
    final allUsers = ref.watch(usersStreamProvider).value ?? [];
    final me = ref.watch(currentUserProvider).value;

    return detail.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (data) {
        _init(data);
        final currentMemberIds = data.members.map((m) => m.user.id).toSet();
        final otherUsers = allUsers
            .where((u) => !currentMemberIds.contains(u.id))
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Edit group')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel('GROUP NAME'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              _sectionLabel('ICON'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final emoji in groupEmojis)
                    _EmojiChip(
                      emoji: emoji,
                      selected: emoji == _emoji,
                      onTap: () => setState(() => _emoji = emoji),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionLabel('MEMBERS'),
              const SizedBox(height: 8),
              for (final m in data.members)
                _MemberTile(
                  name: m.user.name,
                  label: m.user.id == me?.id ? '${m.user.name} (you)' : null,
                  colorIndex: m.user.colorIndex,
                  trailing: Checkbox(
                    value: _selectedMemberIds.contains(m.user.id),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selectedMemberIds.add(m.user.id);
                      } else {
                        _selectedMemberIds.remove(m.user.id);
                      }
                    }),
                  ),
                ),
              for (final user in otherUsers)
                _MemberTile(
                  name: user.name,
                  colorIndex: user.colorIndex,
                  trailing: Checkbox(
                    value: _selectedMemberIds.contains(user.id),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selectedMemberIds.add(user.id);
                      } else {
                        _selectedMemberIds.remove(user.id);
                      }
                    }),
                  ),
                ),
              for (var i = 0; i < _newNames.length; i++)
                _MemberTile(
                  name: _newNames[i],
                  colorIndex: (data.members.length + i) % 8,
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () => setState(() => _newNames.removeAt(i)),
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
                      icon: const Icon(Icons.add_rounded,
                          color: AppColors.primaryDark),
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
                    : const Text('Save changes'),
              ),
            ],
          ),
        );
      },
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

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
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
