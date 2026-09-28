import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../database/app_database.dart';
import '../../../providers/group_detail_provider.dart';
import '../../../shared/widgets/app_card.dart';

class GroupExpenseTile extends StatelessWidget {
  const GroupExpenseTile({
    super.key,
    required this.item,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
    required this.onTap,
    required this.onDelete,
  });

  final ExpenseWithSplits item;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final bool showDecimals;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expense = item.expense;
    final payerNames = [
      for (final p in item.payers) users[p.userId]?.name ?? '?',
    ];
    final payer = formatPayersLabel(payerNames, l10n);
    final date = DateFormat.MMMEd(locale).format(expense.date);
    final peopleCount = item.splits.where((s) => s.amountCents > 0).length;
    final peopleLabel = l10n.groupsShareExpensesPeopleCount(peopleCount);
    final splitLabel = switch (expense.splitType) {
      'exact' => l10n.expensesSplitExact,
      'percent' => l10n.expensesSplitByPercentage,
      _ => l10n.expensesSplitEqual,
    };
    final scheme = Theme.of(context).colorScheme;
    final note = expense.note?.trim();
    final hasNote = note != null && note.isNotEmpty;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.negative,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
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
                      fontSize: 15,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '$date · $payer ${l10n.expensesSubtitlePaid} · $peopleLabel · $splitLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            if (hasNote) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 13,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
