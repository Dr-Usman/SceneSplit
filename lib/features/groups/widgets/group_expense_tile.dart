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
    required this.onTap,
    required this.onDelete,
  });

  final ExpenseWithSplits item;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
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
    final date = DateFormat.MMMd(locale).format(expense.date);

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
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.groupsPayerPaidDate(payer, date),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatCents(expense.amountCents, currencyCode, locale: locale),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
