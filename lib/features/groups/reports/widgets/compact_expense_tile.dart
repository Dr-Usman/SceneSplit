import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

/// Compact, space-efficient expense row designed for reports and lists.
class CompactExpenseTile extends StatelessWidget {
  const CompactExpenseTile({
    super.key,
    required this.item,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
    required this.onTap,
  });

  final ExpenseWithSplits item;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final bool showDecimals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expense = item.expense;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final payerNames = [
      for (final p in item.payers) users[p.userId]?.name ?? '?',
    ];
    final payer = formatPayersLabel(payerNames, l10n);
    final date = DateFormat.MMMEd(locale).format(expense.date);
    final peopleCount = includedPeopleCount(item);
    final peopleLabel = l10n.groupsShareExpensesPeopleCount(peopleCount);
    final splitLabel = switch (expense.splitType) {
      'exact' => l10n.expensesSplitExact,
      'percent' => l10n.expensesSplitByPercentage,
      _ => l10n.expensesSplitEqual,
    };
    final subtitle =
        '$date · $payer ${l10n.expensesSubtitlePaid} · $peopleLabel · $splitLabel';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatCents(
                    expense.amountCents,
                    currencyCode,
                    locale: locale,
                    showDecimals: showDecimals,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
