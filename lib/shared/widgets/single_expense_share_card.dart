import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_links.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../providers/group_detail_provider.dart';
import '../../services/balance_service.dart';
import 'user_avatar.dart';

/// Fixed light layout rendered off-screen and captured as a PNG for sharing a single expense.
class SingleExpenseShareCard extends StatelessWidget {
  const SingleExpenseShareCard({
    super.key,
    required this.groupEmoji,
    required this.groupName,
    required this.currencyCode,
    required this.locale,
    required this.item,
    required this.users,
    this.showDecimals = true,
  });

  static const double cardWidth = 360;

  final String groupEmoji;
  final String groupName;
  final String currencyCode;
  final String locale;
  final ExpenseWithSplits item;
  final Map<String, User> users;
  final bool showDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expense = item.expense;

    final singleExpenseNet = BalanceService.netBalances(
      payers: item.payers,
      splits: item.splits,
      settlements: const [],
    );
    final debts = BalanceService.simplifyDebts(singleExpenseNet);

    final sortedPayers = [...item.payers]
      ..sort((a, b) => b.amountCents.compareTo(a.amountCents));

    final splitLabel = switch (expense.splitType) {
      'exact' => l10n.expensesSplitExactAmounts,
      'percentage' => l10n.expensesSplitByPercentage,
      _ => l10n.expensesSplitEqually,
    };
    final dateStr = DateFormat.yMMMd(locale).format(expense.date);

    return Container(
      width: cardWidth,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scene header
          Row(
            children: [
              Text(groupEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total amount and title
          Text(
            formatCents(
              expense.amountCents,
              currencyCode,
              locale: locale,
              showDecimals: showDecimals,
            ),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expense.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$dateStr · $splitLabel',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (expense.note != null && expense.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.expensesNote}: ${expense.note!.trim()}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Main breakdown card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Paid By
                _SectionLabel(l10n.expensesPaidByHeader),
                const SizedBox(height: 8),
                for (var i = 0; i < sortedPayers.length; i++) ...[
                  _PersonRow(
                    name: users[sortedPayers[i].userId]?.name ?? '?',
                    colorIndex: users[sortedPayers[i].userId]?.colorIndex ?? 0,
                    amount: formatCents(
                      sortedPayers[i].amountCents,
                      currencyCode,
                      locale: locale,
                      showDecimals: showDecimals,
                    ),
                    subtitle: l10n.expensesSubtitlePaid,
                    subtitleColor: AppColors.primary,
                  ),
                  if (i < sortedPayers.length - 1)
                    const Divider(height: 12, color: AppColors.border),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                const SizedBox(height: 14),

                // 2. Split Breakdown
                _SectionLabel(l10n.expensesSplitBreakdown),
                const SizedBox(height: 8),
                for (var i = 0; i < item.splits.length; i++) ...[
                  () {
                    final split = item.splits[i];
                    final net = singleExpenseNet[split.userId] ?? 0;
                    final (subtitle, subtitleColor) = switch (net) {
                      > 0 => (
                        l10n.expensesNetGetsBack(
                          formatCents(
                            net,
                            currencyCode,
                            locale: locale,
                            showDecimals: showDecimals,
                          ),
                        ),
                        AppColors.positive,
                      ),
                      < 0 => (
                        l10n.expensesNetOwes(
                          formatCents(
                            -net,
                            currencyCode,
                            locale: locale,
                            showDecimals: showDecimals,
                          ),
                        ),
                        AppColors.negative,
                      ),
                      _ => (l10n.expensesNetSettled, AppColors.textSecondary),
                    };

                    return _PersonRow(
                      name: users[split.userId]?.name ?? '?',
                      colorIndex: users[split.userId]?.colorIndex ?? 0,
                      amount: formatCents(
                        split.amountCents,
                        currencyCode,
                        locale: locale,
                        showDecimals: showDecimals,
                      ),
                      subtitle: subtitle,
                      subtitleColor: subtitleColor,
                    );
                  }(),
                  if (i < item.splits.length - 1)
                    const Divider(height: 12, color: AppColors.border),
                ],

                // 3. Who owes whom (if any)
                if (debts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 14),
                  _SectionLabel(l10n.expensesWhoOwesWhomHeader),
                  const SizedBox(height: 8),
                  for (var i = 0; i < debts.length; i++) ...[
                    _DebtRow(
                      fromUser: users[debts[i].fromUserId],
                      toUser: users[debts[i].toUserId],
                      amount: formatCents(
                        debts[i].amountCents,
                        currencyCode,
                        locale: locale,
                        showDecimals: showDecimals,
                      ),
                      l10n: l10n,
                    ),
                    if (i < debts.length - 1)
                      const Divider(height: 12, color: AppColors.border),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Footer branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.logoMark,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              Text(
                AppLinks.appName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: AppColors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.name,
    required this.colorIndex,
    required this.amount,
    required this.subtitle,
    required this.subtitleColor,
  });

  final String name;
  final int colorIndex;
  final String amount;
  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: name, colorIndex: colorIndex, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.l10n,
  });

  final User? fromUser;
  final User? toUser;
  final String amount;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final from = fromUser?.name ?? '?';
    final to = toUser?.name ?? '?';

    return Row(
      children: [
        UserAvatar(name: from, colorIndex: fromUser?.colorIndex ?? 0, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.groupsOwesTemplate(from, to),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
