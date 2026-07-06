import 'package:flutter/material.dart';

import '../../core/constants/currencies.dart';
import '../../core/theme/app_theme.dart';

Future<String?> showCurrencyPickerSheet(
  BuildContext context, {
  required String selected,
  String title = 'Choose currency',
}) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
              trailing: c.code == selected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(sheetContext, c.code),
            ),
        ],
      ),
    ),
  );
}

class CurrencyPickerField extends StatelessWidget {
  const CurrencyPickerField({
    super.key,
    required this.currencyCode,
    required this.onChanged,
    this.sheetTitle = 'Choose currency',
  });

  final String currencyCode;
  final ValueChanged<String> onChanged;
  final String sheetTitle;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(currencyCode);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showCurrencyPickerSheet(
          context,
          selected: currencyCode,
          title: sheetTitle,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.payments_outlined),
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Text(
          '${currency.code} — ${currency.name}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
