import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/utils/money.dart';

class BreakdownSlice {
  final String label;
  final int cents;
  final Color color;
  final String currencyCode;

  /// Optional stable id (e.g. userId) for drill-down taps.
  final String? id;

  const BreakdownSlice({
    required this.label,
    required this.cents,
    required this.color,
    required this.currencyCode,
    this.id,
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

class BreakdownPieChart extends StatefulWidget {
  const BreakdownPieChart({super.key, required this.slices, this.onSliceTap});

  final List<BreakdownSlice> slices;

  /// Fired when a legend row is tapped (e.g. open member expense sheet).
  /// Not called when tapping pie slices — those only highlight.
  final ValueChanged<BreakdownSlice>? onSliceTap;

  @override
  State<BreakdownPieChart> createState() => _BreakdownPieChartState();
}

class _BreakdownPieChartState extends State<BreakdownPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final total = widget.slices.fold<int>(0, (sum, s) => sum + s.cents);
    if (total <= 0 || widget.slices.isEmpty) {
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

    final sorted = [...widget.slices]
      ..sort((a, b) => b.cents.compareTo(a.cents));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final touched = _touchedIndex >= 0 && _touchedIndex < sorted.length
        ? sorted[_touchedIndex]
        : null;
    final touchedPercent = touched == null ? null : touched.cents / total * 100;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        final index =
                            response!.touchedSection!.touchedSectionIndex;
                        _touchedIndex = index < 0 ? -1 : index;
                      });
                    },
                  ),
                  sections: [
                    for (var i = 0; i < sorted.length; i++)
                      PieChartSectionData(
                        value: sorted[i].cents.toDouble(),
                        color: sorted[i].color,
                        radius: i == _touchedIndex ? 60 : 52,
                        title: '',
                        showTitle: false,
                      ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
              ),
              if (touched != null && touchedPercent != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        touched.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.sharedPercentLabel(
                          touchedPercent.toStringAsFixed(0),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
            isSelected: i == _touchedIndex,
            onTap: widget.onSliceTap == null
                ? null
                : () => widget.onSliceTap!(sorted[i]),
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
    this.isSelected = false,
    this.onTap,
  });

  final BreakdownSlice slice;
  final double percent;
  final String locale;
  final AppLocalizations l10n;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelWeight = isSelected ? FontWeight.w800 : FontWeight.w600;

    final row = Row(
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
              fontWeight: labelWeight,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatCents(slice.cents, slice.currencyCode, locale: locale),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: row,
    );

    final decorated = isSelected
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: slice.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: padded,
          )
        : padded;

    if (onTap == null) return decorated;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: decorated,
    );
  }
}
