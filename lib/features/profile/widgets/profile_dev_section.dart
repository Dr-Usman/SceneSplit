import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../dev/demo_seed.dart';
import '../../../providers/database_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/settings_tile.dart';

/// Debug-only tools (hidden in release / profile builds without SEED_DEMO).
class ProfileDevSection extends ConsumerStatefulWidget {
  const ProfileDevSection({super.key});

  @override
  ConsumerState<ProfileDevSection> createState() => _ProfileDevSectionState();
}

class _ProfileDevSectionState extends ConsumerState<ProfileDevSection> {
  bool _loading = false;

  Future<void> _loadDemoData() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      final result = await seedDemoData(db);
      if (!mounted) return;
      final message = switch (result) {
        DemoSeedResult.seeded => 'Demo data loaded',
        DemoSeedResult.alreadySeeded =>
          'Groups already exist — wipe app data first',
        DemoSeedResult.blocked => 'Demo seed is disabled in this build',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDemoSeedAllowed) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const SectionHeader('Developer'),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: SettingsTile(
            icon: Icons.science_outlined,
            title: 'Load demo data',
            subtitle: _loading
                ? 'Loading…'
                : 'Apartment, Tokyo Trip, Movie Night (PKR)',
            showDivider: false,
            onTap: _loading ? () {} : _loadDemoData,
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          Text(
            'Debug only — not shown in release builds',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
