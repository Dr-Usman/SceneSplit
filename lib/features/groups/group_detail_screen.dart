import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/currencies.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/share_balance_image.dart';
import '../../database/app_database.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/data_providers.dart';
import '../../providers/database_provider.dart';
import '../../providers/group_detail_provider.dart';
import '../../repositories/group_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/balance_hero_card.dart';
import '../../shared/widgets/balance_share_card.dart';
import '../../shared/widgets/breakdown_pie_chart.dart';
import '../../shared/widgets/member_expense_breakdown_sheet.dart';
import '../../shared/widgets/open_debt_tile.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_detail_screen.dart';
import '../settlements/record_settlement_sheet.dart';
import 'edit_group_screen.dart';
import 'group_activity_dialogs.dart';
import 'group_expenses_screen.dart';
import 'group_settlements_screen.dart';
import 'widgets/group_expense_tile.dart';
import 'widgets/group_settlement_tile.dart';
import 'widgets/share_expenses_sheet.dart';

const _kExpensePreviewCount = 5;
const _kSettlementPreviewCount = 3;

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

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
        body: Center(child: Text(l10n.commonSomethingWentWrong('$e'))),
      ),
      data: (data) {
        final currency = currencyByCode(data.group.currencyCode);
        final shareEntries = data.memberShareCents.entries.toList();
        final settlementPreview = data.settlements
            .take(_kSettlementPreviewCount)
            .toList();
        final expensePreview = data.expenses
            .take(_kExpensePreviewCount)
            .toList();
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
                  l10n.groupsCurrencySubtitle(
                    currency.symbol,
                    currency.name,
                    currency.code,
                  ),
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
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.groupsEditGroup),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n.groupsDeleteGroup),
                  ),
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
            label: Text(l10n.groupsAddExpense),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              BalanceHeroCard(
                netCents: data.myNetCents,
                currencyCode: data.group.currencyCode,
              ),
              if (data.memberShareCents.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(l10n.groupsExpenseBreakdown),
                const SizedBox(height: 10),
                AppCard(
                  child: BreakdownPieChart(
                    slices: [
                      for (var i = 0; i < shareEntries.length; i++)
                        BreakdownSlice(
                          id: shareEntries[i].key,
                          label:
                              users[shareEntries[i].key]?.name ??
                              l10n.commonUnknown,
                          cents: shareEntries[i].value,
                          color: chartColorForIndex(i),
                          currencyCode: data.group.currencyCode,
                        ),
                    ],
                    onSliceTap: (slice) {
                      final userId = slice.id;
                      if (userId == null) return;
                      final items =
                          data.memberExpenseShares[userId] ?? const [];
                      final totalShares = shareEntries.fold<int>(
                        0,
                        (sum, e) => sum + e.value,
                      );
                      showMemberExpenseBreakdownSheet(
                        context,
                        memberName: slice.label,
                        colorIndex: users[userId]?.colorIndex ?? 0,
                        currencyCode: data.group.currencyCode,
                        totalCents: slice.cents,
                        percent: totalShares == 0
                            ? null
                            : slice.cents / totalShares * 100,
                        items: items,
                        onExpenseTap: (expenseId) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExpenseDetailScreen(
                                groupId: groupId,
                                expenseId: expenseId,
                                currencyCode: data.group.currencyCode,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SectionHeader(
                l10n.groupsMembersHeader(data.members.length),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditGroupScreen(groupId: groupId),
                    ),
                  ),
                  child: Text(l10n.groupsManage),
                ),
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
              if (data.debts.isNotEmpty ||
                  data.memberShareCents.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.groupsWhoOwesWhom,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      tooltip: l10n.groupsShareBalances,
                      onPressed: () => _shareBalances(
                        context,
                        ref,
                        data: data,
                        users: users,
                        locale: locale,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    if (data.debts.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => showRecordSettlementSheet(
                          context,
                          groupId: groupId,
                          currencyCode: data.group.currencyCode,
                          members: data.members,
                        ),
                        icon: const Icon(Icons.handshake_outlined, size: 18),
                        label: Text(l10n.groupsSettleUp),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: data.debts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                          child: Text(
                            l10n.groupsShareAllSettled,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.positive,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        )
                      : Column(
                          children: [
                            for (var i = 0; i < data.debts.length; i++) ...[
                              OpenDebtTile(
                                debt: data.debts[i],
                                users: users,
                                currencyCode: data.group.currencyCode,
                                locale: locale,
                                onTap: () => showRecordSettlementSheet(
                                  context,
                                  groupId: groupId,
                                  currencyCode: data.group.currencyCode,
                                  members: data.members,
                                  prefill: data.debts[i],
                                ),
                              ),
                              if (i < data.debts.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                ),
              ],
              if (data.settlements.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(l10n.groupsSettlements),
                const SizedBox(height: 8),
                _SwipeHint(text: l10n.groupsSwipeToDeleteHint),
                const SizedBox(height: 12),
                for (var i = 0; i < settlementPreview.length; i++) ...[
                  GroupSettlementTile(
                    settlement: settlementPreview[i],
                    users: users,
                    currencyCode: data.group.currencyCode,
                    locale: locale,
                    onTap: () => showRecordSettlementSheet(
                      context,
                      groupId: groupId,
                      currencyCode: data.group.currencyCode,
                      members: data.members,
                      existing: settlementPreview[i],
                    ),
                    onDelete: () => confirmDeleteSettlement(
                      context,
                      ref,
                      settlementPreview[i],
                    ),
                  ),
                  if (i < settlementPreview.length - 1)
                    const SizedBox(height: 6),
                ],
                if (data.settlements.length > _kSettlementPreviewCount)
                  _SeeAllFooter(
                    label: l10n.groupsViewAllCount(data.settlements.length),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GroupSettlementsScreen(groupId: groupId),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 28),
              SectionHeader(
                l10n.groupsExpenses,
                trailing: data.expenses.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.groupsShareExpenses,
                        onPressed: () => shareSceneExpenses(
                          context,
                          ref,
                          data: data,
                          users: users,
                          locale: locale,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
              if (data.expenses.isEmpty) ...[
                const SizedBox(height: 12),
                _EmptyExpenses(l10n: l10n),
              ] else ...[
                const SizedBox(height: 8),
                _SwipeHint(text: l10n.groupsSwipeToDeleteHint),
                const SizedBox(height: 12),
                for (var i = 0; i < expensePreview.length; i++) ...[
                  GroupExpenseTile(
                    item: expensePreview[i],
                    users: users,
                    currencyCode: data.group.currencyCode,
                    locale: locale,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExpenseDetailScreen(
                          groupId: groupId,
                          expenseId: expensePreview[i].expense.id,
                          currencyCode: data.group.currencyCode,
                        ),
                      ),
                    ),
                    onDelete: () => confirmDeleteExpense(
                      context,
                      ref,
                      expensePreview[i].expense,
                    ),
                  ),
                  if (i < expensePreview.length - 1) const SizedBox(height: 10),
                ],
                if (data.expenses.length > _kExpensePreviewCount)
                  _SeeAllFooter(
                    label: l10n.groupsViewAllCount(data.expenses.length),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupExpensesScreen(groupId: groupId),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareBalances(
    BuildContext context,
    WidgetRef ref, {
    required GroupDetailData data,
    required Map<String, User> users,
    required String locale,
  }) async {
    final l10n = context.l10n;
    final unknown = l10n.commonUnknown;

    final debtRows = [
      for (final debt in data.debts)
        BalanceShareDebtRow(
          fromName: users[debt.fromUserId]?.name ?? unknown,
          toName: users[debt.toUserId]?.name ?? unknown,
          amountCents: debt.amountCents,
        ),
    ];

    final shareEntries = data.memberShareCents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final memberRows = [
      for (final entry in shareEntries)
        BalanceShareMemberRow(
          name: users[entry.key]?.name ?? unknown,
          colorIndex: users[entry.key]?.colorIndex ?? 0,
          shareCents: entry.value,
        ),
    ];

    final ok = await shareBalanceImage(
      context,
      groupName: data.group.name,
      card: BalanceShareCard(
        groupEmoji: data.group.emoji,
        groupName: data.group.name,
        currencyCode: data.group.currencyCode,
        locale: locale,
        debts: debtRows,
        memberShares: memberRows,
      ),
    );

    if (!context.mounted) return;
    if (ok) {
      await ref
          .read(analyticsServiceProvider)
          .trackBalanceShared(
            debtCount: debtRows.length,
            memberShareCount: memberRows.length,
          );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupsCouldNotShareBalances)));
    }
  }

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.groupsDeleteGroupTitle),
        content: Text(l10n.groupsDeleteGroupBody(group.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.negative),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await deleteGroup(ref.read(databaseProvider), group.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _SeeAllFooter extends StatelessWidget {
  const _SeeAllFooter({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          // visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        ),
        child: Text(label),
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 40, color: onVariant),
          const SizedBox(height: 12),
          Text(
            l10n.groupsEmptyExpensesTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.groupsEmptyExpensesBody,
            style: TextStyle(color: onVariant),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.swipe_left_rounded, size: 16, color: onVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: onVariant),
          ),
        ),
      ],
    );
  }
}
