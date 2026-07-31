import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../providers/data_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../data_screen.dart';
import '../people_screen.dart';

class ProfileManageSection extends ConsumerWidget {
  const ProfileManageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final peopleCount = ref.watch(usersStreamProvider).value?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.profileManage),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.people_outline_rounded,
                title: l10n.profilePeople,
                subtitle: l10n.profilePeopleCount(peopleCount),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const PeopleScreen())),
              ),
              SettingsTile(
                icon: Icons.storage_outlined,
                title: l10n.profileDataBackup,
                subtitle: l10n.profileDataBackupSubtitle,
                showDivider: false,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const DataScreen())),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
