import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/expense_share.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/share_expenses.dart';
import '../../../database/app_database.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/group_detail_provider.dart';
import '../../../shared/widgets/expense_share_card.dart';

Future<ExpenseShareRangePreset?> showExpenseShareRangeSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ExpenseShareRangePreset>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 20),
              Text(
                l10n.groupsShareExpensesRangeTitle,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              _ShareOption(
                icon: Icons.all_inclusive_outlined,
                title: l10n.groupsShareExpensesRangeAll,
                subtitle: l10n.groupsShareExpensesRangeAllSubtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareRangePreset.all),
              ),
              const SizedBox(height: 8),
              _ShareOption(
                icon: Icons.calendar_month_outlined,
                title: l10n.groupsShareExpensesRangeMonth,
                subtitle: l10n.groupsShareExpensesRangeMonthSubtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareRangePreset.month),
              ),
              const SizedBox(height: 8),
              _ShareOption(
                icon: Icons.date_range_outlined,
                title: l10n.groupsShareExpensesRangeLast7,
                subtitle: l10n.groupsShareExpensesRangeLast7Subtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareRangePreset.last7),
              ),
              const SizedBox(height: 8),
              _ShareOption(
                icon: Icons.edit_calendar_outlined,
                title: l10n.groupsShareExpensesRangeCustom,
                subtitle: l10n.groupsShareExpensesRangeCustomSubtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareRangePreset.custom),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<ExpenseShareFormat?> showExpenseShareFormatSheet(BuildContext context) {
  return showModalBottomSheet<ExpenseShareFormat>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 20),
              Text(
                l10n.groupsShareExpensesFormatTitle,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              _ShareOption(
                icon: Icons.image_outlined,
                title: l10n.groupsShareExpensesFormatImage,
                subtitle: l10n.groupsShareExpensesFormatImageSubtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareFormat.image),
              ),
              const SizedBox(height: 8),
              _ShareOption(
                icon: Icons.notes_outlined,
                title: l10n.groupsShareExpensesFormatText,
                subtitle: l10n.groupsShareExpensesFormatTextSubtitle,
                onTap: () =>
                    Navigator.pop(sheetContext, ExpenseShareFormat.text),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Range presets, then Image/Text, then the system share sheet.
Future<void> shareSceneExpenses(
  BuildContext context,
  WidgetRef ref, {
  required GroupDetailData data,
  required Map<String, User> users,
  required String locale,
}) async {
  final l10n = context.l10n;
  final preset = await showExpenseShareRangeSheet(context);
  if (preset == null || !context.mounted) return;

  DateTimeRange? custom;
  if (preset == ExpenseShareRangePreset.custom) {
    custom = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      currentDate: DateTime.now(),
    );
    if (custom == null || !context.mounted) return;
  }

  final range = resolveExpenseShareRange(
    preset,
    now: DateTime.now(),
    custom: custom,
  );
  final filtered = filterExpensesByDateRange(data.expenses, range);
  if (filtered.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.groupsShareExpensesEmptyRange)));
    return;
  }

  final format = await showExpenseShareFormatSheet(context);
  if (format == null || !context.mounted) return;

  final userNames = {
    for (final entry in users.entries) entry.key: entry.value.name,
  };
  final rangeLabel = formatExpenseShareRangeLabel(
    range,
    l10n: l10n,
    locale: locale,
  );
  final groupName = data.group.name;
  final currencyCode = data.group.currencyCode;

  final bool ok;
  switch (format) {
    case ExpenseShareFormat.image:
      final content = buildExpenseShareImageContent(
        filtered,
        userNames: userNames,
        l10n: l10n,
        currencyCode: currencyCode,
        locale: locale,
      );
      ok = await shareExpenseImage(
        context,
        groupName: groupName,
        caption: expenseShareCaption(
          l10n: l10n,
          groupName: groupName,
          rangeLabel: rangeLabel,
          isAllDates: range == null,
        ),
        card: ExpenseShareCard(
          groupEmoji: data.group.emoji,
          groupName: groupName,
          headerMeta: formatExpenseShareHeaderMeta(
            l10n: l10n,
            rangeLabel: rangeLabel,
            expenseCount: filtered.length,
          ),
          rows: content.rows,
          overflowCount: content.overflowCount,
          totalAmount: formatCents(
            content.totalCents,
            currencyCode,
            locale: locale,
          ),
        ),
      );
    case ExpenseShareFormat.text:
      ok = await shareExpenseText(
        context,
        groupName: groupName,
        body: buildExpenseShareText(
          filtered,
          groupName: groupName,
          rangeLabel: rangeLabel,
          userNames: userNames,
          l10n: l10n,
          currencyCode: currencyCode,
          locale: locale,
        ),
      );
  }

  if (!context.mounted) return;
  if (ok) {
    await ref
        .read(analyticsServiceProvider)
        .trackExpensesShared(
          expenseCount: filtered.length,
          format: format.name,
          range: switch (preset) {
            ExpenseShareRangePreset.all => 'all',
            ExpenseShareRangePreset.month => 'month',
            ExpenseShareRangePreset.last7 => '7d',
            ExpenseShareRangePreset.custom => 'custom',
          },
        );
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.groupsCouldNotShareExpenses)));
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
