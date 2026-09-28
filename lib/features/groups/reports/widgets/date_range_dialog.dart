import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/utils/expense_share.dart';

/// Shows a centered modal dialog with two separate date selectors ("From" and "To").
Future<DateTimeRange?> showDateRangeDialog({
  required BuildContext context,
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (dialogContext) => DateRangeDialog(
      initialRange: initialRange,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    ),
  );
}

class DateRangeDialog extends StatefulWidget {
  const DateRangeDialog({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
  });

  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<DateRangeDialog> createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initial = widget.initialRange;
    if (initial != null) {
      _startDate = dateOnly(initial.start);
      _endDate = dateOnly(initial.end);
    } else {
      _startDate = dateOnly(now.subtract(const Duration(days: 7)));
      _endDate = dateOnly(now);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) {
      setState(() {
        _startDate = dateOnly(picked);
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    if (picked != null) {
      setState(() {
        _endDate = dateOnly(picked);
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMEd(locale);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      title: Row(
        children: [
          Expanded(
            child: Text(
              l10n.groupsReportDateDialogTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: l10n.commonCancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DateTile(
            label: l10n.groupsReportFromDate,
            dateText: dateFormat.format(_startDate),
            icon: Icons.calendar_today_outlined,
            onTap: _pickStartDate,
          ),
          const SizedBox(height: 12),
          _DateTile(
            label: l10n.groupsReportToDate,
            dateText: dateFormat.format(_endDate),
            icon: Icons.event_available_outlined,
            onTap: _pickEndDate,
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    l10n.commonCancel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(DateTimeRange(start: _startDate, end: _endDate));
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.groupsReportApply,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.dateText,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String dateText;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
