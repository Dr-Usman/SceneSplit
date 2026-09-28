import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/group_detail_provider.dart';
import 'package:scene_split/shared/widgets/user_avatar.dart';

enum ReportSortOrder { dateDesc, dateAsc }

const String kReportAllMembersId = '__all_members__';

class DateFilterMenuButton extends StatelessWidget {
  const DateFilterMenuButton({
    super.key,
    required this.activePreset,
    required this.customRange,
    required this.locale,
    required this.onSelect,
  });

  final ExpenseShareRangePreset activePreset;
  final DateTimeRange? customRange;
  final String locale;
  final ValueChanged<ExpenseShareRangePreset> onSelect;

  String _label(AppLocalizations l10n) {
    return switch (activePreset) {
      ExpenseShareRangePreset.all => l10n.groupsShareExpensesRangeAll,
      ExpenseShareRangePreset.today => l10n.groupsShareExpensesRangeToday,
      ExpenseShareRangePreset.singleDay =>
        customRange != null
            ? DateFormat.yMMMEd(locale).format(customRange!.start)
            : l10n.groupsShareExpensesRange1Day,
      ExpenseShareRangePreset.thisWeek => l10n.groupsShareExpensesRangeThisWeek,
      ExpenseShareRangePreset.last7 => l10n.groupsShareExpensesRangeLast7,
      ExpenseShareRangePreset.month => l10n.groupsShareExpensesRangeMonth,
      ExpenseShareRangePreset.custom =>
        customRange != null
            ? formatExpenseShareRangeLabel(
                customRange,
                l10n: l10n,
                locale: locale,
              )
            : l10n.groupsShareExpensesRangeCustom,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isFiltered = activePreset != ExpenseShareRangePreset.all;

    return Theme(
      data: theme.copyWith(
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: PopupMenuButton<ExpenseShareRangePreset>(
        tooltip: l10n.groupsReportFilterDate,
        onSelected: onSelect,
        itemBuilder: (context) => [
          _buildItem(
            context,
            ExpenseShareRangePreset.all,
            l10n.groupsShareExpensesRangeAll,
            Icons.all_inclusive_rounded,
          ),
          _buildItem(
            context,
            ExpenseShareRangePreset.today,
            l10n.groupsShareExpensesRangeToday,
            Icons.today_rounded,
          ),
          _buildItem(
            context,
            ExpenseShareRangePreset.singleDay,
            l10n.groupsShareExpensesRange1Day,
            Icons.event_rounded,
          ),
          _buildItem(
            context,
            ExpenseShareRangePreset.thisWeek,
            l10n.groupsShareExpensesRangeThisWeek,
            Icons.view_week_outlined,
          ),
          _buildItem(
            context,
            ExpenseShareRangePreset.last7,
            l10n.groupsShareExpensesRangeLast7,
            Icons.date_range_outlined,
          ),
          _buildItem(
            context,
            ExpenseShareRangePreset.month,
            l10n.groupsShareExpensesRangeMonth,
            Icons.calendar_month_outlined,
          ),
          const PopupMenuDivider(),
          _buildItem(
            context,
            ExpenseShareRangePreset.custom,
            l10n.groupsShareExpensesRangeCustom,
            Icons.edit_calendar_outlined,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isFiltered
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFiltered
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: isFiltered
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isFiltered ? FontWeight.w600 : FontWeight.w500,
                    color: isFiltered
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: isFiltered
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<ExpenseShareRangePreset> _buildItem(
    BuildContext context,
    ExpenseShareRangePreset preset,
    String text,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = activePreset == preset;
    return PopupMenuItem<ExpenseShareRangePreset>(
      value: preset,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class MemberFilterMenuButton extends StatelessWidget {
  const MemberFilterMenuButton({
    super.key,
    required this.members,
    required this.users,
    required this.selectedMemberId,
    required this.onSelect,
  });

  final List<GroupMemberInfo> members;
  final Map<String, User> users;
  final String? selectedMemberId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isFiltered = selectedMemberId != null;

    final selectedName = selectedMemberId != null
        ? (users[selectedMemberId!]?.name ?? 'Member')
        : l10n.groupsReportFilterAllMembers;

    return Theme(
      data: theme.copyWith(
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: l10n.groupsReportFilterAllMembers,
        onSelected: (val) {
          onSelect(val == kReportAllMembersId ? null : val);
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: kReportAllMembersId,
            child: Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 18,
                  color: selectedMemberId == null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.groupsReportFilterAllMembers,
                    style: TextStyle(
                      fontWeight: selectedMemberId == null
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: selectedMemberId == null
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                if (selectedMemberId == null)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          for (final m in members) ...[
            PopupMenuItem<String>(
              value: m.user.id,
              child: Row(
                children: [
                  UserAvatar(
                    name: users[m.user.id]?.name ?? m.user.name,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      users[m.user.id]?.name ?? m.user.name,
                      style: TextStyle(
                        fontWeight: selectedMemberId == m.user.id
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: selectedMemberId == m.user.id
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (selectedMemberId == m.user.id)
                    Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ],
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isFiltered
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFiltered
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: isFiltered
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isFiltered ? FontWeight.w600 : FontWeight.w500,
                    color: isFiltered
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: isFiltered
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortMenuButton extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.sortOrder,
    required this.onSelect,
  });

  final ReportSortOrder sortOrder;
  final ValueChanged<ReportSortOrder> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final isDesc = sortOrder == ReportSortOrder.dateDesc;
    final buttonLabel = isDesc
        ? l10n.groupsReportSortNewest
        : l10n.groupsReportSortOldest;

    return Theme(
      data: theme.copyWith(
        popupMenuTheme: theme.popupMenuTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: PopupMenuButton<ReportSortOrder>(
        tooltip: l10n.groupsReportSort,
        onSelected: onSelect,
        itemBuilder: (context) => [
          PopupMenuItem<ReportSortOrder>(
            value: ReportSortOrder.dateDesc,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: isDesc
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.groupsReportSortDateDesc,
                    style: TextStyle(
                      fontWeight: isDesc ? FontWeight.w700 : FontWeight.normal,
                      color: isDesc ? colorScheme.primary : null,
                    ),
                  ),
                ),
                if (isDesc)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
          PopupMenuItem<ReportSortOrder>(
            value: ReportSortOrder.dateAsc,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: !isDesc
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.groupsReportSortDateAsc,
                    style: TextStyle(
                      fontWeight: !isDesc ? FontWeight.w700 : FontWeight.normal,
                      color: !isDesc ? colorScheme.primary : null,
                    ),
                  ),
                ),
                if (!isDesc)
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDesc
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 13,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 3),
              Text(
                buttonLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 1),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
