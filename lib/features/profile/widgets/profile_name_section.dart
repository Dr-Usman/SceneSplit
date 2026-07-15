import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileNameSection extends ConsumerStatefulWidget {
  const ProfileNameSection({super.key});

  @override
  ConsumerState<ProfileNameSection> createState() => _ProfileNameSectionState();
}

class _ProfileNameSectionState extends ConsumerState<ProfileNameSection> {
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user != null && !_editingName && _nameController.text.isEmpty) {
      _nameController.text = user.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    : const Icon(Icons.check_rounded, color: AppColors.primary),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editingName = true),
            ),
          ),
      ],
    );
  }
}
