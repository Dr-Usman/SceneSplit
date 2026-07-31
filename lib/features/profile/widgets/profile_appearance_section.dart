import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/section_header.dart';

class ProfileAppearanceSection extends ConsumerWidget {
  const ProfileAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.profileAppearance),
        const SizedBox(height: 8),
        Text(
          l10n.profileAppearanceHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.profileThemeSystem),
              icon: const Icon(Icons.brightness_auto_rounded, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.profileThemeLight),
              icon: const Icon(Icons.light_mode_outlined, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.profileThemeDark),
              icon: const Icon(Icons.dark_mode_outlined, size: 18),
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: (selected) {
            updateThemeMode(
              ref.read(databaseProvider),
              themeModeToStorage(selected.first),
            );
          },
        ),
      ],
    );
  }
}
