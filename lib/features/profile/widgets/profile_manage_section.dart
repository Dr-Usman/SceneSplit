import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/data_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../data_screen.dart';
import '../people_screen.dart';

class ProfileManageSection extends ConsumerWidget {
  const ProfileManageSection({super.key});

  String _peopleSubtitle(int count) {
    if (count == 0) return 'No people yet';
    if (count == 1) return '1 person';
    return '$count people';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleCount = ref.watch(usersStreamProvider).value?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DataScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
