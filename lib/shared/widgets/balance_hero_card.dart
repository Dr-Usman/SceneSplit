import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import 'app_card.dart';

class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.netCents,
    required this.currencyCode,
  });

  final int netCents;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final settled = netCents == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String label;
    final String? amount;
    final Color amountColor;
    final Color? tintColor;

    if (settled) {
      label = 'You are all settled up';
      amount = null;
      amountColor = Theme.of(context).colorScheme.onSurfaceVariant;
      tintColor = null;
    } else if (netCents > 0) {
      label = 'You get';
      amount = formatCents(netCents, currencyCode);
      amountColor = AppColors.positive;
      tintColor = AppColors.positive.withValues(alpha: isDark ? 0.12 : 0.08);
    } else {
      label = 'You will give';
      amount = formatCents(netCents, currencyCode);
      amountColor = AppColors.negative;
      tintColor = AppColors.negative.withValues(alpha: isDark ? 0.12 : 0.08);
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: tintColor != null
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : EdgeInsets.zero,
        decoration: tintColor != null
            ? BoxDecoration(
                color: tintColor,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (amount != null) ...[
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
