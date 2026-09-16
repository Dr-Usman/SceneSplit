import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import 'app_card.dart';

class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.netCents,
    required this.currencyCode,
    this.showDecimals = true,
  });

  final int netCents;
  final String currencyCode;
  final bool showDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final settled = netCents == 0;
    final scheme = Theme.of(context).colorScheme;

    final String label;
    final String amount;
    final Color amountColor;

    if (settled) {
      label = l10n.groupsShareAllSettled;
      amount = formatCents(
        0,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      amountColor = scheme.onSurfaceVariant;
    } else if (netCents > 0) {
      label = l10n.sharedYouGet;
      amount = formatCents(
        netCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      amountColor = AppColors.positive;
    } else {
      label = l10n.sharedYouWillGive;
      amount = formatCents(
        netCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      amountColor = AppColors.negative;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (settled) ...[
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.positive,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  amount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
