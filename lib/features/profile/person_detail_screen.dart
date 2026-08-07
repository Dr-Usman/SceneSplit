import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/data_providers.dart';
import '../../providers/person_detail_provider.dart';
import '../../services/balance_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/member_expense_breakdown_sheet.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import '../expenses/expense_detail_screen.dart';
import '../settlements/record_settlement_sheet.dart';
import 'widgets/person_row.dart';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(personDetailProvider(userId));
    final users = ref.watch(userByIdProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (data) {
        final displayName = data.user.isCurrentUser
            ? l10n.commonYouSuffix(data.user.name)
            : data.user.name;

        return Scaffold(
          appBar: AppBar(
            title: Text(displayName),
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'edit') {
                    await editPerson(context, ref, data.user);
                  } else if (action == 'delete') {
                    final deleted = await deletePerson(context, ref, data.user);
                    if (deleted && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.peopleEditName),
                  ),
                  if (!data.user.isCurrentUser)
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
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      name: data.user.name,
                      colorIndex: data.user.colorIndex,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (data.groups.isEmpty)
                            _StatusChip(
                              label: l10n.peopleDetailEmptyScenes,
                              tone: _StatusTone.neutral,
                            )
                          else if (!data.hasAnyOpenBalance)
                            _StatusChip(
                              label: l10n.peopleDetailAllSettled,
                              tone: _StatusTone.positive,
                            )
                          else if (data.currencyTotals.isEmpty)
                            _StatusChip(
                              label: l10n.peopleDetailOpenBalances,
                              tone: _StatusTone.attention,
                            )
                          else
                            _BalanceSummary(
                              totals: data.currencyTotals,
                              person: data.user,
                              displayName: displayName,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.peopleDetailCurrencySubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (data.groups.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Text(
                    l10n.peopleDetailEmptyScenes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final balance in data.groups) ...[
                  _SceneBalanceCard(
                    balance: balance,
                    person: data.user,
                    users: users,
                    displayName: displayName,
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _SceneBalanceCard extends StatefulWidget {
  const _SceneBalanceCard({
    required this.balance,
    required this.person,
    required this.users,
    required this.displayName,
  });

  final PersonGroupBalance balance;
  final User person;
  final Map<String, User> users;
  final String displayName;

  @override
  State<_SceneBalanceCard> createState() => _SceneBalanceCardState();
}

class _SceneBalanceCardState extends State<_SceneBalanceCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.balance.hasOpenBalance;
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.balance;
    final person = widget.person;
    final users = widget.users;
    final displayName = widget.displayName;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final currency = balance.group.currencyCode;
    final net = balance.netCents;

    final String netLabel;
    final Color? netColor;
    final String netAmount;
    if (net == 0) {
      netLabel = l10n.peopleDetailSettledInScene;
      netColor = AppColors.positive;
      netAmount = '';
    } else if (net > 0) {
      netLabel = person.isCurrentUser
          ? l10n.sharedYouGet
          : l10n.peopleDetailGets(displayName);
      netColor = AppColors.positive;
      netAmount = formatCents(net, currency, locale: locale);
    } else {
      netLabel = person.isCurrentUser
          ? l10n.sharedYouWillGive
          : l10n.peopleDetailWillGive(displayName);
      netColor = AppColors.negative;
      netAmount = formatCents(-net, currency, locale: locale);
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: balance.hasOpenBalance,
          onExpansionChanged: (expanded) {
            setState(() => _expanded = expanded);
          },
          title: Row(
            children: [
              Text(balance.group.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    netLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: netColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (netAmount.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      netAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: netColor,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          children: [
            SectionHeader(l10n.groupsWhoOwesWhom),
            const SizedBox(height: 8),
            if (balance.debts.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.peopleDetailNoDebts,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (var i = 0; i < balance.debts.length; i++) ...[
                _PersonDebtTile(
                  debt: balance.debts[i],
                  users: users,
                  currencyCode: currency,
                  locale: locale,
                  onTap: () => showRecordSettlementSheet(
                    context,
                    groupId: balance.group.id,
                    currencyCode: currency,
                    members: balance.members,
                    prefill: balance.debts[i],
                  ),
                ),
                if (i < balance.debts.length - 1) const Divider(height: 1),
              ],
            if (balance.expenseShares.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionHeader(l10n.peopleDetailExpensesSection),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.peopleDetailViewExpenses,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  formatCents(
                    balance.totalShareCents,
                    currency,
                    locale: locale,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  showMemberExpenseBreakdownSheet(
                    context,
                    memberName: displayName,
                    currencyCode: currency,
                    totalCents: balance.totalShareCents,
                    items: balance.expenseShares,
                    onExpenseTap: (expenseId) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailScreen(
                            groupId: balance.group.id,
                            expenseId: expenseId,
                            currencyCode: currency,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PersonDebtTile extends StatelessWidget {
  const _PersonDebtTile({
    required this.debt,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.onTap,
  });

  final PairwiseDebt debt;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = users[debt.fromUserId]?.name ?? '?';
    final to = users[debt.toUserId]?.name ?? '?';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.groupsOwesTemplate(from, to),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              formatCents(debt.amountCents, currencyCode, locale: locale),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: onVariant),
            ],
          ],
        ),
      ),
    );
  }
}

enum _StatusTone { neutral, positive, attention }

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.totals,
    required this.person,
    required this.displayName,
  });

  final List<PersonCurrencyTotals> totals;
  final User person;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final multiCurrency = totals.length > 1;

    final willGiveLabel = person.isCurrentUser
        ? l10n.sharedYouWillGive
        : l10n.peopleDetailWillGive(displayName);
    final getsLabel = person.isCurrentUser
        ? l10n.sharedYouGet
        : l10n.peopleDetailGets(displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < totals.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          if (multiCurrency) ...[
            Text(
              totals[i].currencyCode,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (totals[i].willGiveCents > 0)
            _BalanceSummaryLine(
              label: willGiveLabel,
              amount: formatCents(
                totals[i].willGiveCents,
                totals[i].currencyCode,
                locale: locale,
              ),
              color: AppColors.negative,
            ),
          if (totals[i].willGiveCents > 0 && totals[i].getsCents > 0)
            const SizedBox(height: 4),
          if (totals[i].getsCents > 0)
            _BalanceSummaryLine(
              label: getsLabel,
              amount: formatCents(
                totals[i].getsCents,
                totals[i].currencyCode,
                locale: locale,
              ),
              color: AppColors.positive,
            ),
        ],
      ],
    );
  }
}

class _BalanceSummaryLine extends StatelessWidget {
  const _BalanceSummaryLine({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          amount,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;
    switch (tone) {
      case _StatusTone.positive:
        fg = AppColors.positive;
        bg = AppColors.positive.withValues(alpha: 0.12);
      case _StatusTone.attention:
        fg = AppColors.secondaryDark;
        bg = AppColors.secondary.withValues(alpha: 0.12);
      case _StatusTone.neutral:
        fg = Theme.of(context).colorScheme.onSurfaceVariant;
        bg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
