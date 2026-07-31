import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/localize_error.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/group_repository.dart';
import '../../repositories/user_repository.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/group_emoji_picker.dart';
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
  String _currencyCode = 'PKR';
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
    _currencyCode = data.group.currencyCode;
    _selectedMemberIds.addAll(data.members.map((m) => m.user.id));
    _nameController.addListener(() => setState(() {}));
  }

  int get _memberCount => _selectedMemberIds.length + _newNames.length;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _memberCount >= 1 && !_saving;

  void _addTypedMember() {
    final name = _memberController.text.trim();
    if (name.isEmpty) return;
    final normalized = name.toLowerCase();
    final allUsers = ref.read(usersStreamProvider).value ?? [];

    final existing = allUsers.where(
      (u) => u.name.trim().toLowerCase() == normalized,
    );
    if (existing.isNotEmpty) {
      setState(() {
        _selectedMemberIds.add(existing.first.id);
        _memberController.clear();
      });
      return;
    }

    if (_newNames.any((n) => n.trim().toLowerCase() == normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonNameAlreadyInList(name))),
      );
      return;
    }

    setState(() {
      _newNames.add(name);
      _memberController.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    try {
      await updateGroup(
        db,
        groupId: widget.groupId,
        name: _nameController.text.trim(),
        emoji: _emoji,
        currencyCode: _currencyCode,
      );

      await syncGroupMembers(
        db,
        groupId: widget.groupId,
        memberUserIds: _selectedMemberIds.toList(),
        newMemberNames: _newNames,
      );

      if (mounted) Navigator.of(context).pop();
    } on MemberRemovalBlockedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
        setState(() => _saving = false);
      }
    } on UserNameTakenException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _toggleMember({
    required String userId,
    required bool include,
    required String? userName,
    required bool isCurrentUser,
  }) async {
    if (!include) {
      final db = ref.read(databaseProvider);
      if (!await canRemoveMemberFromGroup(db, userId, widget.groupId)) {
        if (!mounted) return;
        final l10n = context.l10n;
        final message = isCurrentUser
            ? l10n.groupsRemovalBlockedYou
            : l10n.groupsRemovalBlockedOther(userName ?? l10n.groupsThisMember);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }
    }

    setState(() {
      if (include) {
        _selectedMemberIds.add(userId);
      } else {
        _selectedMemberIds.remove(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(groupDetailProvider(widget.groupId));
    final allUsers = ref.watch(usersStreamProvider).value ?? [];
    final me = ref.watch(currentUserProvider).value;

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonErrorWithDetail('$e'))),
      ),
      data: (data) {
        _init(data);
        final currentMemberIds = data.members.map((m) => m.user.id).toSet();
        final otherUsers = allUsers
            .where((u) => !currentMemberIds.contains(u.id))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(l10n.groupsEditGroup)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionLabel(l10n.groupsGroupName),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              _sectionLabel(l10n.groupsIcon),
              const SizedBox(height: 12),
              GroupEmojiPicker(
                selectedEmoji: _emoji,
                onChanged: (emoji) => setState(() => _emoji = emoji),
              ),
              const SizedBox(height: 24),
              _sectionLabel(l10n.groupsCurrency),
              const SizedBox(height: 8),
              CurrencyPickerField(
                currencyCode: _currencyCode,
                onChanged: (code) => setState(() => _currencyCode = code),
              ),
              const SizedBox(height: 24),
              _sectionLabel(l10n.groupsMembers),
              const SizedBox(height: 8),
              for (final m in data.members)
                _MemberTile(
                  name: m.user.name,
                  label: m.user.id == me?.id
                      ? l10n.commonYouSuffix(m.user.name)
                      : null,
                  colorIndex: m.user.colorIndex,
                  trailing: Checkbox(
                    value: _selectedMemberIds.contains(m.user.id),
                    onChanged: (checked) => _toggleMember(
                      userId: m.user.id,
                      include: checked == true,
                      userName: m.user.name,
                      isCurrentUser: m.user.id == me?.id,
                    ),
                  ),
                ),
              for (final user in otherUsers)
                _MemberTile(
                  name: user.name,
                  colorIndex: user.colorIndex,
                  trailing: Checkbox(
                    value: _selectedMemberIds.contains(user.id),
                    onChanged: (checked) => _toggleMember(
                      userId: user.id,
                      include: checked == true,
                      userName: user.name,
                      isCurrentUser: false,
                    ),
                  ),
                ),
              for (var i = 0; i < _newNames.length; i++)
                _MemberTile(
                  name: _newNames[i],
                  colorIndex: (data.members.length + i) % 8,
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
                      decoration: InputDecoration(
                        hintText: l10n.groupsAddMemberHint,
                        prefixIcon: const Icon(Icons.person_add_alt_outlined),
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
                    : Text(l10n.groupsSaveChanges),
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
