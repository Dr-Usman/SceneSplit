import 'package:flutter/material.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/shared/widgets/app_card.dart';
import 'package:scene_split/shared/widgets/user_avatar.dart';

/// Card displaying member-by-member breakdown: paid, share, and net for the period.
class ReportMemberSummaryCard extends StatelessWidget {
  const ReportMemberSummaryCard({
    super.key,
    required this.summaries,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
  });

  final List<GroupPeriodMemberSummary> summaries;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final bool showDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < summaries.length; i++) ...[
            _MemberSummaryRow(
              summary: summaries[i],
              user: users[summaries[i].userId],
              currencyCode: currencyCode,
              locale: locale,
              showDecimals: showDecimals,
              l10n: l10n,
              colorScheme: colorScheme,
            ),
            if (i < summaries.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _MemberSummaryRow extends StatelessWidget {
  const _MemberSummaryRow({
    required this.summary,
    required this.user,
    required this.currencyCode,
    required this.locale,
    required this.showDecimals,
    required this.l10n,
    required this.colorScheme,
  });

  final GroupPeriodMemberSummary summary;
  final User? user;
  final String currencyCode;
  final String locale;
  final bool showDecimals;
  final dynamic l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final net = summary.netCents;
    final isPositive = net > 0;
    final isNegative = net < 0;

    final netColor = isPositive
        ? AppColors.positive
        : isNegative
        ? AppColors.negative
        : colorScheme.onSurfaceVariant;

    final netPrefix = isPositive ? '+' : '';
    final netText =
        '$netPrefix${formatCents(net, currencyCode, locale: locale, showDecimals: showDecimals)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          UserAvatar(
            name: summary.name,
            colorIndex: user?.colorIndex ?? 0,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${l10n.groupsReportPaid}: ${formatCents(summary.paidCents, currencyCode, locale: locale, showDecimals: showDecimals)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${l10n.groupsReportShare}: ${formatCents(summary.shareCents, currencyCode, locale: locale, showDecimals: showDecimals)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: netColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              netText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: netColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
