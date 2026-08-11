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
        : filterOpenDebts(
            overview.asData!.value.openDebts,
            fromId: fromUserId,
            toId: toUserId,
          );
    final currencyTotals = aggregatePairByCurrency(
      pairDebts,
      fromId: fromUserId,
      toId: toUserId,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupsOwesTemplate(fromName, toName))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
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
                            Icons.arrow_forward_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text(
                            l10n.balancesOwes,
                            style: Theme.of(context).textTheme.labelSmall,
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
                  l10n.groupsOwesTemplate(fromName, toName),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (currencyTotals.isEmpty)
                  Text(
                    l10n.balancesPairSettled,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.positive,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  for (final total in currencyTotals) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.balancesOpenDebtTotal,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          formatCents(
                            total.amountCents,
                            total.currencyCode,
                            locale: locale,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    if (total != currencyTotals.last) const SizedBox(height: 8),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.positive,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return Column(
                children: [
                  for (final scene in scenes) ...[
                    _ScenePairCard(
                      scene: scene,
                      fromUserId: fromUserId,
                      toUserId: toUserId,
                      debtorName: fromName,
                      debtorColorIndex: fromUser?.colorIndex ?? 0,
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

class _ScenePairCard extends StatelessWidget {
  const _ScenePairCard({
    required this.scene,
    required this.fromUserId,
    required this.toUserId,
    required this.debtorName,
    required this.debtorColorIndex,
    required this.locale,
  });

  final PairSceneBreakdown scene;
  final String fromUserId;
  final String toUserId;
  final String debtorName;
  final int debtorColorIndex;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final prefill = PairwiseDebt(
      fromUserId: fromUserId,
      toUserId: toUserId,
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
                child: Text(
                  scene.groupName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => showRecordSettlementSheet(
                  context,
                  groupId: scene.groupId,
                  currencyCode: scene.currencyCode,
                  members: scene.members,
                  prefill: prefill,
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
