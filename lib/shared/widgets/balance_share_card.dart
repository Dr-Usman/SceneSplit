import 'package:flutter/material.dart';

import '../../core/constants/app_links.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import 'user_avatar.dart';

/// One pairwise debt row for the share card.
class BalanceShareDebtRow {
  const BalanceShareDebtRow({
    required this.fromName,
    required this.toName,
    required this.amountCents,
  });

  final String fromName;
  final String toName;
  final int amountCents;
}

/// One member expense-share row for the share card.
class BalanceShareMemberRow {
  const BalanceShareMemberRow({
    required this.name,
    required this.colorIndex,
    required this.shareCents,
  });

  final String name;
  final int colorIndex;
  final int shareCents;
}

/// Fixed light layout rendered off-screen and captured as a PNG for sharing.
class BalanceShareCard extends StatelessWidget {
  const BalanceShareCard({
    super.key,
    required this.groupEmoji,
    required this.groupName,
    required this.currencyCode,
    required this.locale,
    required this.debts,
    required this.memberShares,
  });

  static const double cardWidth = 360;

  final String groupEmoji;
  final String groupName;
  final String currencyCode;
  final String locale;
  final List<BalanceShareDebtRow> debts;
  final List<BalanceShareMemberRow> memberShares;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final totalCents = memberShares.fold<int>(
      0,
      (sum, row) => sum + row.shareCents,
    );

    return Container(
      width: cardWidth,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(groupEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.groupsWhoOwesWhom),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: debts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.groupsShareAllSettled,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.positive,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < debts.length; i++) ...[
                        _DebtRow(
                          label: l10n.groupsOwesTemplate(
                            debts[i].fromName,
                            debts[i].toName,
                          ),
                          amount: formatCents(
                            debts[i].amountCents,
                            currencyCode,
                            locale: locale,
                          ),
                        ),
                        if (i < debts.length - 1)
                          const Divider(height: 1, color: AppColors.border),
                      ],
                    ],
                  ),
          ),
          if (memberShares.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionLabel(l10n.groupsExpenseShares),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < memberShares.length; i++) ...[
                    _MemberShareRow(
                      name: memberShares[i].name,
                      colorIndex: memberShares[i].colorIndex,
                      amount: formatCents(
                        memberShares[i].shareCents,
                        currencyCode,
                        locale: locale,
                      ),
                    ),
                    if (i < memberShares.length - 1)
                      const Divider(height: 1, color: AppColors.border),
                  ],
                  const Divider(height: 1, color: AppColors.border),
                  _DebtRow(
                    label: l10n.sharedTotal,
                    amount: formatCents(
                      totalCents,
                      currencyCode,
                      locale: locale,
                    ),
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            AppLinks.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
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
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  final String label;
  final String amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final weight = emphasize ? FontWeight.w700 : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: weight,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberShareRow extends StatelessWidget {
  const _MemberShareRow({
    required this.name,
    required this.colorIndex,
    required this.amount,
  });

  final String name;
  final int colorIndex;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserAvatar(name: name, colorIndex: colorIndex, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
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
      ),
    );
  }
}
