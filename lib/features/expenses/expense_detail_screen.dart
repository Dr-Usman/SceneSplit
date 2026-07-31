import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../shared/widgets/user_avatar.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
    required this.currencyCode,
  });

  final String groupId;
  final String expenseId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final detail = ref.watch(groupDetailProvider(groupId));
    final users = ref.watch(userByIdProvider);

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonErrorWithDetail('$e'))),
      ),
      data: (data) {
        final item = data.expenses.cast<ExpenseWithSplits?>().firstWhere(
          (e) => e?.expense.id == expenseId,
          orElse: () => null,
        );
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.expensesNotFound)),
          );
        }

        final expense = item.expense;
        final payerIds = {for (final p in item.payers) p.userId};
        final sortedPayers = [...item.payers]
          ..sort((a, b) => b.amountCents.compareTo(a.amountCents));
        final splitLabel = switch (expense.splitType) {
          'exact' => l10n.expensesSplitExactAmounts,
          'percentage' => l10n.expensesSplitByPercentage,
          _ => l10n.expensesSplitEqually,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.expensesDetailTitle),
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(
                          groupId: groupId,
                          currencyCode: currencyCode,
                          existing: item,
                        ),
                      ),
                    );
                  } else if (action == 'delete') {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.groupsDeleteExpenseTitle),
                        content: Text(
                          l10n.groupsDeleteExpenseBody(expense.title),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.commonCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.negative,
                            ),
                            child: Text(l10n.commonDelete),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await deleteExpense(
                        ref.read(databaseProvider),
                        expense.id,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.commonEdit)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.commonDelete),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                formatCents(expense.amountCents, currencyCode, locale: locale),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                expense.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: l10n.expensesDate,
                value: DateFormat.yMMMd(locale).format(expense.date),
              ),
              _InfoRow(
                icon: Icons.call_split_rounded,
                label: l10n.expensesSplit,
                value: splitLabel,
              ),
              if (expense.note != null && expense.note!.isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: l10n.expensesNote,
                  value: expense.note!,
                  multiline: true,
                ),
              const SizedBox(height: 28),
              Text(
                l10n.expensesPaidByHeader,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              for (final payer in sortedPayers) ...[
                _SplitRow(
                  name: users[payer.userId]?.name ?? '?',
                  colorIndex: users[payer.userId]?.colorIndex ?? 0,
                  amount: formatCents(
                    payer.amountCents,
                    currencyCode,
                    locale: locale,
                  ),
                  subtitle: l10n.expensesSubtitlePaid,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.expensesSplitBreakdown,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              for (final split in item.splits) ...[
                _SplitRow(
                  name: users[split.userId]?.name ?? '?',
                  colorIndex: users[split.userId]?.colorIndex ?? 0,
                  amount: formatCents(
                    split.amountCents,
                    currencyCode,
                    locale: locale,
                  ),
                  subtitle: payerIds.contains(split.userId)
                      ? l10n.expensesSubtitleAlsoPaid
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 14,
    );
    final valueStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    );

    if (multiline) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(label, style: labelStyle),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(value, style: valueStyle),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: labelStyle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: valueStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.name,
    required this.colorIndex,
    required this.amount,
    this.subtitle,
  });

  final String name;
  final int colorIndex;
  final String amount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: name, colorIndex: colorIndex, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}
