import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/currency_picker_sheet.dart';
import '../../../shared/widgets/section_header.dart';

class ProfileCurrencySection extends ConsumerWidget {
  const ProfileCurrencySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.profileDefaultCurrencyHeader),
        const SizedBox(height: 8),
        Text(
          l10n.profileDefaultCurrencyHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        CurrencyPickerField(
          currencyCode: currencyCode,
          sheetTitle: l10n.profileDefaultCurrencySheet,
          onChanged: (code) => updateCurrency(ref.read(databaseProvider), code),
        ),
      ],
    );
  }
}
