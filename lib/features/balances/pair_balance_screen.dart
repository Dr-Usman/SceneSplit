import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/balances_overview_provider.dart';
import '../../providers/data_providers.dart';
import '../../services/balance_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/member_expense_breakdown_sheet.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/user_avatar.dart';
import '../expenses/expense_detail_screen.dart';
import '../settlements/record_settlement_sheet.dart';

/// Relationship view for open debts between two people (either direction).
class PairBalanceScreen extends ConsumerWidget {
  const PairBalanceScreen({
    super.key,
    required this.fromUserId,
    required this.toUserId,
  });

  final String fromUserId;
  final String toUserId;

  String _displayName(AppLocalizations l10n, User? user) {
    if (user == null) return '?';
    if (user.isCurrentUser) return l10n.commonYouSuffix(user.name);
    return user.name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final users = ref.watch(userByIdProvider);
    final overview = ref.watch(balancesOverviewProvider);
    final scenesAsync = ref.watch(
      pairBalanceDetailProvider((fromId: fromUserId, toId: toUserId)),
    );

    final fromUser = users[fromUserId];
    final toUser = users[toUserId];
    final fromName = _displayName(l10n, fromUser);
    final toName = _displayName(l10n, toUser);

    final pairDebts = overview.asData == null
        ? const <OpenPairwiseBalance>[]
        : filterOpenDebtsBetweenPair(
            overview.asData!.value.openDebts,
            userIdA: fromUserId,
            userIdB: toUserId,
          );
    final forwardTotals = aggregatePairByCurrency(
      pairDebts,
      fromId: fromUserId,
      toId: toUserId,
    );
    final reverseTotals = aggregatePairByCurrency(
      pairDebts,
      fromId: toUserId,
      toId: fromUserId,
    );
    final hasBothDirections =
        forwardTotals.isNotEmpty && reverseTotals.isNotEmpty;
    final pairNets = hasBothDirections
        ? netPersonPovTotals(summarizePersonPovTotals(pairDebts, fromUserId))
        : const <PersonPovCurrencyNet>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.balancesPairBetween(fromName, toName))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UserAvatar(
                            name: fromUser?.name ?? '?',
                            colorIndex: fromUser?.colorIndex ?? 0,
                            size: 52,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: [
                                Icon(
                                  hasBothDirections
                                      ? Icons.swap_horiz_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                                Text(
                                  l10n.balancesOwes,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          UserAvatar(
                            name: toUser?.name ?? '?',
                            colorIndex: toUser?.colorIndex ?? 0,
                            size: 52,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.balancesPairBetween(fromName, toName),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (forwardTotals.isEmpty && reverseTotals.isEmpty)
                        Text(
                          l10n.balancesPairSettled,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.positive,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else ...[
                        for (final total in forwardTotals) ...[
                          _DirectionAmountRow(
                            label: hasBothDirections
                                ? l10n.groupsOwesTemplate(fromName, toName)
                                : l10n.balancesOpenDebtTotal,
                            amount: formatCents(
                              total.amountCents,
                              total.currencyCode,
                              locale: locale,
                            ),
                          ),
                          if (total != forwardTotals.last ||
                              reverseTotals.isNotEmpty)
                            const SizedBox(height: 8),
                        ],
                        for (final total in reverseTotals) ...[
                          _DirectionAmountRow(
                            label: l10n.groupsOwesTemplate(toName, fromName),
                            amount: formatCents(
                              total.amountCents,
                              total.currencyCode,
                              locale: locale,
                            ),
                          ),
                          if (total != reverseTotals.last)
                            const SizedBox(height: 8),
                        ],
                      ],
                    ],
                  ),
                ),
                if (pairNets.isNotEmpty &&
                    fromUser != null &&
                    toUser != null) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.border,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < pairNets.length; i++) ...[
                          if (i > 0) const SizedBox(height: 6),
                          _PairNetLine(
                            net: pairNets[i],
                            subject: fromUser,
                            other: toUser,
                            locale: locale,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l10n.balancesScenesHeader),
          const SizedBox(height: 12),
          scenesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.commonSomethingWentWrong('$e')),
            data: (scenes) {
              if (scenes.isEmpty) {
                return Text(
                  l10n.balancesPairSettled,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.positive,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              final showDirection = hasBothDirections;
              return Column(
                children: [
                  for (final scene in scenes) ...[
                    _ScenePairCard(
                      scene: scene,
                      debtorName: _displayName(l10n, users[scene.fromUserId]),
                      creditorName: _displayName(l10n, users[scene.toUserId]),
                      debtorColorIndex:
                          users[scene.fromUserId]?.colorIndex ?? 0,
                      showDirection: showDirection,
                      locale: locale,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DirectionAmountRow extends StatelessWidget {
  const _DirectionAmountRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PairNetLine extends StatelessWidget {
  const _PairNetLine({
    required this.net,
    required this.subject,
    required this.other,
    required this.locale,
  });

  final PersonPovCurrencyNet net;
  final User subject;
  final User other;
  final String locale;

  String _name(BuildContext context, User user) {
    final l10n = context.l10n;
    if (user.isCurrentUser) return l10n.commonYouSuffix(user.name);
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final amount = formatCents(
      net.amountCents,
      net.currencyCode,
      locale: locale,
    );
    final debtor = net.personOwesOther ? subject : other;
    final creditor = net.personOwesOther ? other : subject;

    final Color accent;
    if (creditor.isCurrentUser) {
      accent = AppColors.primaryDark;
    } else if (debtor.isCurrentUser) {
      accent = AppColors.negative;
    } else {
      accent = theme.colorScheme.onSurface;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.balancesHeroNetLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: onVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.balancesHeroNetOwes(
              _name(context, debtor),
              _name(context, creditor),
            ),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: theme.textTheme.labelLarge?.copyWith(
            color: accent,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ScenePairCard extends StatelessWidget {
  const _ScenePairCard({
    required this.scene,
    required this.debtorName,
    required this.creditorName,
    required this.debtorColorIndex,
    required this.showDirection,
    required this.locale,
  });

  final PairSceneBreakdown scene;
  final String debtorName;
  final String creditorName;
  final int debtorColorIndex;
  final bool showDirection;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final prefill = PairwiseDebt(
      fromUserId: scene.fromUserId,
      toUserId: scene.toUserId,
      amountCents: scene.debtCents,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(scene.groupEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.groupName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showDirection) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.groupsOwesTemplate(debtorName, creditorName),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => showRecordSettlementSheet(
                  context,
                  groupId: scene.groupId,
                  currencyCode: scene.currencyCode,
                  members: scene.members,
                  prefill: prefill,
                  analyticsSource: kSettlementSourceBalancesPair,
                ),
                icon: const Icon(Icons.handshake_outlined, size: 18),
                label: Text(l10n.balancesSettleInScene),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TotalRow(
            label: l10n.balancesOpenDebtTotal,
            amount: formatCents(
              scene.debtCents,
              scene.currencyCode,
              locale: locale,
            ),
            emphasize: true,
          ),
          if (scene.expenseShares.isNotEmpty) ...[
            const SizedBox(height: 6),
            _TotalRow(
              label: l10n.balancesShareTotal,
              amount: formatCents(
                scene.totalShareCents,
                scene.currencyCode,
                locale: locale,
              ),
            ),
            const SizedBox(height: 4),
            _TotalRow(
              label: l10n.balancesExpenseTotal,
              amount: formatCents(
                scene.totalExpenseCents,
                scene.currencyCode,
                locale: locale,
              ),
            ),
            const SizedBox(height: 4),
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  l10n.balancesViewShares,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  formatCents(
                    scene.totalShareCents,
                    scene.currencyCode,
                    locale: locale,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  showMemberExpenseBreakdownSheet(
                    context,
                    memberName: debtorName,
                    colorIndex: debtorColorIndex,
                    currencyCode: scene.currencyCode,
                    totalCents: scene.totalShareCents,
                    items: scene.expenseShares,
                    onExpenseTap: (expenseId) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailScreen(
                            groupId: scene.groupId,
                            expenseId: expenseId,
                            currencyCode: scene.currencyCode,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  final String label;
  final String amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: style),
      ],
    );
  }
}
