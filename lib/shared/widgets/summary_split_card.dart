import 'package:flutter/material.dart';

import '../../core/theme/app_decorations.dart';

typedef SummaryHalfTap = void Function(BuildContext context);

class SummarySplitCard extends StatelessWidget {
  const SummarySplitCard({
    super.key,
    required this.owedLabel,
    required this.owedAmount,
    required this.oweLabel,
    required this.oweAmount,
    required this.onOwedTap,
    required this.onOweTap,
  });

  final String owedLabel;
  final String owedAmount;
  final String oweLabel;
  final String oweAmount;
  final SummaryHalfTap onOwedTap;
  final SummaryHalfTap onOweTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card(context),
      ),
      clipBehavior: Clip.antiAlias,
      // Equal heights: long amounts scale down via FittedBox and would
      // otherwise shrink one half, breaking the capsule look.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SummaryHalf(
                label: owedLabel,
                amount: owedAmount,
                gradient: AppGradients.summaryOwed,
                onTap: () => onOwedTap(context),
              ),
            ),
            Expanded(
              child: _SummaryHalf(
                label: oweLabel,
                amount: oweAmount,
                gradient: AppGradients.summaryOwe,
                onTap: () => onOweTap(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHalf extends StatelessWidget {
  const _SummaryHalf({
    required this.label,
    required this.amount,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String amount;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
