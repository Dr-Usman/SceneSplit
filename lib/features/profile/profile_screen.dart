import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/currencies.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/user_repository.dart';
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

  Future<void> _pickCurrency(String current) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                'Default currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            for (final c in supportedCurrencies)
              ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Text(
                    c.symbol,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text(c.code),
                trailing: c.code == current
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () async {
                  await updateCurrency(ref.read(databaseProvider), c.code);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';
    final allUsers = ref.watch(usersStreamProvider).value ?? [];

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
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _pickCurrency(currencyCode),
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.payments_outlined),
                suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
              ),
              child: Text(
                '${currencyByCode(currencyCode).code} — ${currencyByCode(currencyCode).name}',
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionLabel('PEOPLE'),
          const SizedBox(height: 8),
          Text(
            'Everyone added across your groups.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
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
