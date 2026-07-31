import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/utils/money.dart';

class BreakdownSlice {
  final String label;
  final int cents;
  final Color color;
  final String currencyCode;

  const BreakdownSlice({
    required this.label,
    required this.cents,
    required this.color,
    required this.currencyCode,
  });
}

/// Distinct slice colors for charts — index-based, independent of avatar colors.
const _chartSliceColors = [
  Color(0xFF00B5B2),
  Color(0xFF7856E6),
  Color(0xFFDB2777),
  Color(0xFFD97706),
  Color(0xFF2563EB),
  Color(0xFF059669),
  Color(0xFFDC2626),
  Color(0xFF9333EA),
  Color(0xFF0891B2),
  Color(0xFFCA8A04),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
];

Color chartColorForIndex(int index) =>
    _chartSliceColors[index % _chartSliceColors.length];

Future<void> showBreakdownSheet(
  BuildContext context, {
  required String title,
  required List<BreakdownSlice> slices,
  String? subtitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final colorScheme = theme.colorScheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              BreakdownPieChart(slices: slices),
            ],
          ),
        ),
      );
    },
  );
}

class BreakdownPieChart extends StatelessWidget {
  const BreakdownPieChart({super.key, required this.slices});

  final List<BreakdownSlice> slices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final total = slices.fold<int>(0, (sum, s) => sum + s.cents);
    if (total <= 0 || slices.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Text(
          l10n.sharedNoChartData,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final sorted = [...slices]..sort((a, b) => b.cents.compareTo(a.cents));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: [
                for (var i = 0; i < sorted.length; i++)
                  PieChartSectionData(
                    value: sorted[i].cents.toDouble(),
                    color: sorted[i].color,
                    radius: 52,
                    title: '',
                    showTitle: false,
                  ),
              ],
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < sorted.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _LegendRow(
            slice: sorted[i],
            percent: sorted[i].cents / total * 100,
            locale: locale,
            l10n: l10n,
          ),
        ],
        const SizedBox(height: 12),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        const SizedBox(height: 12),
        _TotalRow(
          cents: total,
          currencyCode: sorted.first.currencyCode,
          locale: locale,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.cents,
    required this.currencyCode,
    required this.locale,
    required this.l10n,
  });

  final int cents;
  final String currencyCode;
  final String locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.sharedTotal,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          formatCents(cents, currencyCode, locale: locale),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.percent,
    required this.locale,
    required this.l10n,
  });

  final BreakdownSlice slice;
  final double percent;
  final String locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            slice.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatCents(slice.cents, slice.currencyCode, locale: locale),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            l10n.sharedPercentLabel(percent.toStringAsFixed(0)),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
