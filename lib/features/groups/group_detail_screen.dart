import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/currencies.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../repositories/group_repository.dart';
import '../../repositories/settlement_repository.dart';
import '../../services/balance_service.dart';
import '../../shared/widgets/breakdown_pie_chart.dart';
import '../../shared/widgets/user_avatar.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_detail_screen.dart';
import '../settlements/record_settlement_sheet.dart';
import 'edit_group_screen.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(groupDetailProvider(groupId));
    final users = ref.watch(userByIdProvider);
    final me = ref.watch(currentUserProvider).value;

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Something went wrong: $e')),
      ),
      data: (data) {
        final currency = currencyByCode(data.group.currencyCode);
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.group.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.group.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${currency.symbol} — ${currency.name} (${currency.code})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditGroupScreen(groupId: groupId),
                      ),
                    );
                  } else if (action == 'delete') {
                    await _confirmDeleteGroup(context, ref, data.group);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit group')),
                  PopupMenuItem(value: 'delete', child: Text('Delete group')),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(
                  groupId: groupId,
                  currencyCode: data.group.currencyCode,
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add expense'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _MyBalanceCard(
                netCents: data.myNetCents,
                currencyCode: data.group.currencyCode,
              ),
              if (data.memberShareCents.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionLabel(context, 'EXPENSE BREAKDOWN'),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BreakdownPieChart(
                      slices: [
                        for (final entry in data.memberShareCents.entries)
                          BreakdownSlice(
                            label: users[entry.key]?.name ?? 'Unknown',
                            cents: entry.value,
                            color: chartColorForIndex(
                              users[entry.key]?.colorIndex ?? 0,
                            ),
                            currencyCode: data.group.currencyCode,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _sectionLabel(
                      context,
                      'MEMBERS (${data.members.length})',
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditGroupScreen(groupId: groupId),
                      ),
                    ),
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.members.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final member = data.members[index];
                    return Column(
                      children: [
                        UserAvatar(
                          name: member.user.name,
                          colorIndex: member.user.colorIndex,
                          size: 44,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 56,
                          child: Text(
                            member.user.name.split(' ').first,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (data.debts.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _sectionLabel(context, 'WHO OWES WHOM')),
                    TextButton.icon(
                      onPressed: () => showRecordSettlementSheet(
                        context,
                        groupId: groupId,
                        currencyCode: data.group.currencyCode,
                        members: data.members,
                      ),
                      icon: const Icon(Icons.handshake_outlined, size: 18),
                      label: const Text('Settle up'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final debt in data.debts)
                  _DebtTile(
                    debt: debt,
                    users: users,
                    currencyCode: data.group.currencyCode,
                    highlightMe: me?.id,
                    onTap: () => showRecordSettlementSheet(
                      context,
                      groupId: groupId,
                      currencyCode: data.group.currencyCode,
                      members: data.members,
                      prefill: debt,
                    ),
                  ),
              ],
              if (data.settlements.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionLabel(context, 'SETTLEMENTS'),
                const SizedBox(height: 10),
                for (final s in data.settlements)
                  _SettlementTile(
                    settlement: s,
                    users: users,
                    currencyCode: data.group.currencyCode,
                    onDelete: () => _confirmDeleteSettlement(context, ref, s),
                  ),
              ],
              const SizedBox(height: 28),
              _sectionLabel(context, 'EXPENSES'),
              const SizedBox(height: 12),
              if (data.expenses.isEmpty)
                const _EmptyExpenses()
              else
                for (final item in data.expenses) ...[
                  _ExpenseTile(
                    item: item,
                    users: users,
                    currencyCode: data.group.currencyCode,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExpenseDetailScreen(
                          groupId: groupId,
                          expenseId: item.expense.id,
                          currencyCode: data.group.currencyCode,
                        ),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, ref, item.expense),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove "${expense.title}" from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await deleteExpense(ref.read(databaseProvider), expense.id);
    }
  }

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          'Delete "${group.name}" and all its expenses? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await deleteGroup(ref.read(databaseProvider), group.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDeleteSettlement(
    BuildContext context,
    WidgetRef ref,
    Settlement settlement,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete settlement?'),
        content: const Text('Remove this recorded payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await deleteSettlement(ref.read(databaseProvider), settlement.id);
    }
  }
}

class _MyBalanceCard extends StatelessWidget {
  const _MyBalanceCard({required this.netCents, required this.currencyCode});

  final int netCents;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final settled = netCents == 0;
    final String label;
    final String amount;
    final Color color;

    if (settled) {
      label = 'You are all settled up';
      amount = '';
      color = AppColors.textSecondary;
    } else if (netCents > 0) {
      label = 'You get';
      amount = formatCents(netCents, currencyCode);
      color = AppColors.positive;
    } else {
      label = 'You will give';
      amount = formatCents(netCents, currencyCode);
      color = AppColors.negative;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!settled) ...[
            const SizedBox(height: 6),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.debt,
    required this.users,
    required this.currencyCode,
    this.highlightMe,
    this.onTap,
  });

  final PairwiseDebt debt;
  final Map<String, User> users;
  final String currencyCode;
  final String? highlightMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final from = users[debt.fromUserId]?.name ?? '?';
    final to = users[debt.toUserId]?.name ?? '?';
    final isMe = debt.fromUserId == highlightMe || debt.toUserId == highlightMe;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: isMe ? FontWeight.w600 : FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: from),
                    const TextSpan(text: ' owes '),
                    TextSpan(
                      text: to,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              formatCents(debt.amountCents, currencyCode),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isMe ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.item,
    required this.users,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
  });

  final ExpenseWithSplits item;
  final Map<String, User> users;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final expense = item.expense;
    final payer = users[expense.paidById]?.name ?? '?';
    final date = DateFormat.MMMd().format(expense.date);

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
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        '$payer paid · $date',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCents(expense.amountCents, currencyCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({
    required this.settlement,
    required this.users,
    required this.currencyCode,
    required this.onDelete,
  });

  final Settlement settlement;
  final Map<String, User> users;
  final String currencyCode;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final from = users[settlement.fromUserId]?.name ?? '?';
    final to = users[settlement.toUserId]?.name ?? '?';
    final date = DateFormat.MMMd().format(settlement.createdAt);

    return Dismissible(
      key: ValueKey(settlement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: AppColors.positive,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$from paid $to',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCents(settlement.amountCents, currencyCode),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No expenses yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Tap "Add expense" to split your first bill.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
