import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_links.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../repositories/user_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/currency_picker_sheet.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/settings_tile.dart';
import '../../shared/widgets/user_avatar.dart';
import '../about/about_screen.dart';
import 'data_screen.dart';
import 'people_screen.dart';

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

  String _peopleSubtitle(int count) {
    if (count == 0) return 'No people yet';
    if (count == 1) return '1 person';
    return '$count people';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';
    final peopleCount = ref.watch(usersStreamProvider).value?.length ?? 0;

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
          const SectionHeader('MANAGE'),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.people_outline_rounded,
                  title: 'People',
                  subtitle: _peopleSubtitle(peopleCount),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PeopleScreen()),
                  ),
                ),
                SettingsTile(
                  icon: Icons.storage_outlined,
                  title: 'Data & backup',
                  subtitle: 'Export or import your data',
                  showDivider: false,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const DataScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const SectionHeader('APP'),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About ${AppLinks.appName}',
              subtitle: 'Version, legal, and feedback',
              showDivider: false,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '…';
              final buildNumber = snapshot.data?.buildNumber ?? '…';
              return Text(
                '${AppLinks.appName} v$version ($buildNumber)',
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
