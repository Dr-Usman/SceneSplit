import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database_paths.dart';
import '../../../dev/demo_seed.dart';
import '../../../providers/database_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/settings_tile.dart';

/// Debug-only developer tools (hidden in release and profile builds).
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

  Future<void> _confirmAndResetAllData() async {
    if (_loading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This will permanently delete the database and all local data (expenses, groups, people, and settings).\n\nYou will be returned to onboarding to start fresh.\n\nThis cannot be undone.',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Reset everything'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);

      if (kIsWeb) {
        await db.transaction(() async {
          for (final table in db.allTables.toList().reversed) {
            await db.delete(table).go();
          }
        });
      } else {
        await db.close();
        try {
          final dbPath = await resolveDatabasePath();
          for (final suffix in ['', '-wal', '-shm']) {
            final f = File('$dbPath$suffix');
            if (f.existsSync()) {
              f.deleteSync();
            }
          }
        } on Object catch (_) {
          // File deletion errors ignored; reopen handles recreation
        }
      }

      await ref.read(databaseProvider.notifier).reopen();

      if (!mounted) return;

      // Pop all pushed routes back to root so OnboardingScreen is displayed
      Navigator.of(context).popUntil((route) => route.isFirst);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database reset. Starting fresh.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not reset database: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const SectionHeader('Developer'),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.science_outlined,
                title: 'Load demo data',
                subtitle: _loading
                    ? 'Loading…'
                    : 'Apartment, Tokyo Trip, Movie Night (PKR)',
                onTap: _loading ? () {} : _loadDemoData,
              ),
              SettingsTile(
                icon: Icons.delete_forever_outlined,
                iconColor: Theme.of(context).colorScheme.error,
                title: 'Clear & reset all data',
                titleColor: Theme.of(context).colorScheme.error,
                subtitle: _loading
                    ? 'Resetting…'
                    : 'Delete database & start fresh from onboarding',
                showDivider: false,
                onTap: _loading ? () {} : _confirmAndResetAllData,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Debug only — not shown in release builds',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
