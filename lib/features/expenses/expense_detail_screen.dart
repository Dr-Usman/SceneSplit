import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final detail = ref.watch(groupDetailProvider(groupId));
    final users = ref.watch(userByIdProvider);

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (data) {
        final item = data.expenses.cast<ExpenseWithSplits?>().firstWhere(
          (e) => e?.expense.id == expenseId,
          orElse: () => null,
        );
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Expense not found')),
          );
        }

        final expense = item.expense;
        final payer = users[expense.paidById];
        final splitLabel = switch (expense.splitType) {
          'exact' => 'Exact amounts',
          'percentage' => 'By percentage',
          _ => 'Split equally',
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expense'),
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
                        title: const Text('Delete expense?'),
                        content: Text(
                          'Remove "${expense.title}" from this group?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.negative,
                            ),
                            child: const Text('Delete'),
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
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                formatCents(expense.amountCents, currencyCode),
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
                icon: Icons.person_outline_rounded,
                label: 'Paid by',
                value: payer?.name ?? '?',
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: DateFormat.yMMMd().format(expense.date),
              ),
              _InfoRow(
                icon: Icons.call_split_rounded,
                label: 'Split',
                value: splitLabel,
              ),
              if (expense.note != null && expense.note!.isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Note',
                  value: expense.note!,
                  multiline: true,
                ),
              const SizedBox(height: 28),
              Text(
                'SPLIT BREAKDOWN',
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
                  amount: formatCents(split.amountCents, currencyCode),
                  isPayer: split.userId == expense.paidById,
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
    required this.isPayer,
  });

  final String name;
  final int colorIndex;
  final String amount;
  final bool isPayer;

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
              if (isPayer)
                const Text(
                  'paid',
                  style: TextStyle(
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
