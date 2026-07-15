import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/currency_picker_sheet.dart';
import '../../../shared/widgets/section_header.dart';

class ProfileCurrencySection extends ConsumerWidget {
  const ProfileCurrencySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          onChanged: (code) => updateCurrency(ref.read(databaseProvider), code),
        ),
      ],
    );
  }
}
