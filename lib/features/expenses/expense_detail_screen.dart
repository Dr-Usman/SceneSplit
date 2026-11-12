import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/expense_share.dart';
import '../../core/utils/money.dart';
import '../../core/utils/share_expenses.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/expense_repository.dart';
import '../../services/balance_service.dart';
import '../../shared/widgets/open_debt_tile.dart';
import '../../shared/widgets/single_expense_share_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../groups/widgets/share_expenses_sheet.dart';
import '../settlements/record_settlement_sheet.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  const ExpenseDetailScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
    required this.currencyCode,
    this.analyticsSource = 'group_detail',
  });

  final String groupId;
  final String expenseId;
  final String currencyCode;

  /// Entry point that opened this screen (`group_detail`, `group_expenses`,
  /// `member_breakdown`, `pair_balance`, `group_report`, `person_detail`).
  final String analyticsSource;

  @override
  ConsumerState<ExpenseDetailScreen> createState() =>
      _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> {
  bool _openedTracked = false;

  /// Fires the expense-opened event once, as soon as the expense is resolved.
  void _trackOpenedOnce(String groupName, ExpenseWithSplits item) {
    if (_openedTracked) return;
    _openedTracked = true;
    final analytics = ref.read(analyticsServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analytics.trackExpenseDetailOpened(
        groupId: widget.groupId,
        groupName: groupName,
        expenseId: item.expense.id,
        amountCents: item.expense.amountCents,
        currencyCode: widget.currencyCode,
        participantCount: item.splits.where((s) => s.amountCents > 0).length,
        source: widget.analyticsSource,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
    final expenseId = widget.expenseId;
    final currencyCode = widget.currencyCode;
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
        final sortedPayers = [...item.payers]
          ..sort((a, b) => b.amountCents.compareTo(a.amountCents));
        final splitLabel = switch (expense.splitType) {
          'exact' => l10n.expensesSplitExactAmounts,
          'percentage' => l10n.expensesSplitByPercentage,
          _ => l10n.expensesSplitEqually,
        };
        final singleExpenseNet = BalanceService.netBalances(
          payers: item.payers,
          splits: item.splits,
          settlements: const [],
        );
        final singleExpenseDebts = BalanceService.simplifyDebts(
          singleExpenseNet,
        );

        _trackOpenedOnce(data.group.name, item);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.expensesDetailTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: l10n.expensesShareTooltip,
                onPressed: () async {
                  final format = await showExpenseShareFormatSheet(context);
                  if (format == null || !context.mounted) return;

                  final userNames = {
                    for (final entry in users.entries)
                      entry.key: entry.value.name,
                  };

                  final group = data.group;
                  bool ok = false;
                  if (format == ExpenseShareFormat.image) {
                    ok = await shareSingleExpenseImage(
                      context,
                      card: SingleExpenseShareCard(
                        groupEmoji: group.emoji,
                        groupName: group.name,
                        currencyCode: currencyCode,
                        locale: locale,
                        item: item,
                        users: users,
                        showDecimals: group.showDecimals,
                      ),
                      groupName: group.name,
                      expenseTitle: expense.title,
                    );
                  } else {
                    final text = formatSingleExpenseText(
                      item: item,
                      groupName: group.name,
                      groupEmoji: group.emoji,
                      currencyCode: currencyCode,
                      userNames: userNames,
                      l10n: l10n,
                      locale: locale,
                      showDecimals: group.showDecimals,
                    );
                    ok = await shareSingleExpenseText(
                      context,
                      body: text,
                      groupName: group.name,
                      expenseTitle: expense.title,
                    );
                  }

                  if (ok) {
                    await ref
                        .read(analyticsServiceProvider)
                        .trackExpenseShared(
                          groupId: groupId,
                          groupName: data.group.name,
                          expenseId: expense.id,
                          amountCents: expense.amountCents,
                          currencyCode: currencyCode,
                          format: format.name,
                          splitType: expense.splitType,
                          payerCount: item.payers.length,
                          participantCount: item.splits
                              .where((s) => s.amountCents > 0)
                              .length,
                          debtCount: singleExpenseDebts.length,
                        );
                  }
                },
              ),
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddExpenseScreen(
                          groupId: groupId,
                          currencyCode: currencyCode,
                          existing: item,
                          analyticsSource: 'expense_detail',
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
                      final groupName = ref
                          .read(groupDetailProvider(groupId))
                          .value
                          ?.group
                          .name;
                      await ref
                          .read(analyticsServiceProvider)
                          .trackExpenseDeleted(
                            groupId: groupId,
                            groupName: groupName,
                            amountCents: expense.amountCents,
                            currencyCode: currencyCode,
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
                () {
                  final net = singleExpenseNet[split.userId] ?? 0;
                  final (subtitle, subtitleColor) = switch (net) {
                    > 0 => (
                      l10n.expensesNetGetsBack(
                        formatCents(net, currencyCode, locale: locale),
                      ),
                      AppColors.positive,
                    ),
                    < 0 => (
                      l10n.expensesNetOwes(
                        formatCents(-net, currencyCode, locale: locale),
                      ),
                      AppColors.negative,
                    ),
                    _ => (l10n.expensesNetSettled, AppColors.textSecondary),
                  };
                  return _SplitRow(
                    name: users[split.userId]?.name ?? '?',
                    colorIndex: users[split.userId]?.colorIndex ?? 0,
                    amount: formatCents(
                      split.amountCents,
                      currencyCode,
                      locale: locale,
                    ),
                    subtitle: subtitle,
                    subtitleColor: subtitleColor,
                  );
                }(),
                const SizedBox(height: 8),
              ],
              if (singleExpenseDebts.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.expensesWhoOwesWhomHeader,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.expensesWhoOwesWhomHelp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < singleExpenseDebts.length; i++) ...[
                        OpenDebtTile(
                          debt: singleExpenseDebts[i],
                          users: users,
                          currencyCode: currencyCode,
                          locale: locale,
                          showDebtorAvatar: true,
                          onTap: () => showRecordSettlementSheet(
                            context,
                            groupId: groupId,
                            groupName: data.group.name,
                            currencyCode: data.group.currencyCode,
                            members: data.members,
                            prefill: singleExpenseDebts[i],
                            analyticsSource: kSettlementSourceExpenseDetail,
                          ),
                        ),
                        if (i < singleExpenseDebts.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
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
    this.subtitleColor,
  });

  final String name;
  final int colorIndex;
  final String amount;
  final String? subtitle;
  final Color? subtitleColor;

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
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? AppColors.primary,
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
