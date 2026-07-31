import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/language_picker_sheet.dart';
import '../../../shared/widgets/section_header.dart';

class ProfileLanguageSection extends ConsumerWidget {
  const ProfileLanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stored = ref.watch(localeCodeProvider).value ?? 'system';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.profileLanguage),
        const SizedBox(height: 8),
        Text(
          l10n.profileLanguageHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        LanguagePickerField(
          localeCode: stored,
          sheetTitle: l10n.sharedChooseLanguage,
          onChanged: (code) =>
              updateLocaleCode(ref.read(databaseProvider), code),
        ),
      ],
    );
  }
}
