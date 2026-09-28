import 'package:flutter/material.dart';

import 'package:scene_split/core/constants/app_links.dart';
import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/core/utils/expense_share.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/services/balance_service.dart';
import 'package:scene_split/shared/widgets/user_avatar.dart';

/// Fixed light layout captured as a PNG for sharing group reports.
/// Renders an executive summary: Header meta, Totals hero, Who owes whom,
/// and Member breakdown in a clean, compact single-image card.
class GroupReportShareCard extends StatelessWidget {
  const GroupReportShareCard({
    super.key,
    required this.groupEmoji,
    required this.groupName,
    required this.rangeLabel,
    required this.expenseCount,
    required this.settlementCount,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
    this.selectedMemberId,
    this.selectedMemberName,
    this.isCurrentUser = false,
    required this.totalSpendCents,
    required this.totalSettledCents,
    required this.openDebtCents,
    required this.memberNetCents,
    required this.memberPaidCents,
    required this.memberReceivedCents,
    required this.debts,
    required this.users,
    required this.memberSummaries,
  });

  static const double cardWidth = 380;

  final String groupEmoji;
  final String groupName;
  final String rangeLabel;
  final int expenseCount;
  final int settlementCount;
  final String currencyCode;
  final String locale;
  final bool showDecimals;

  final String? selectedMemberId;
  final String? selectedMemberName;
  final bool isCurrentUser;

  final int totalSpendCents;
  final int totalSettledCents;
  final int openDebtCents;

  final int memberNetCents;
  final int memberPaidCents;
  final int memberReceivedCents;

  final List<OpenDebt> debts;
  final Map<String, User> users;
  final List<GroupPeriodMemberSummary> memberSummaries;

  bool get isSingleMember => selectedMemberId != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: cardWidth,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Emoji + Group Name
          Row(
            children: [
              Text(groupEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isSingleMember && selectedMemberName != null
                      ? '$groupName ($selectedMemberName)'
                      : groupName,
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
          const SizedBox(height: 6),

          // Header Meta: Date range & counts
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '$rangeLabel · ${l10n.groupsMemberShareExpenseCount(expenseCount)} · ${l10n.groupsReportSettlementsCount(settlementCount)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Totals Hero Card
          _buildHeroTotalsCard(context),
          const SizedBox(height: 16),

          // Who Owes Whom Section
          _buildSectionHeader(l10n.groupsReportWhoOwesWhom),
          const SizedBox(height: 8),
          _buildWhoOwesWhomCard(context),
          const SizedBox(height: 16),

          // Member Breakdown Section
          if (memberSummaries.isNotEmpty) ...[
            _buildSectionHeader(l10n.groupsReportMemberSummary),
            const SizedBox(height: 8),
            _buildMemberBreakdownCard(context),
            const SizedBox(height: 18),
          ],

          // Footer Watermark
          Text(
            AppLinks.appName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTotalsCard(BuildContext context) {
    final l10n = context.l10n;
    final isSingleMember = selectedMemberId != null;

    if (!isSingleMember) {
      final isSettled = openDebtCents == 0;
      final openDebtColor = isSettled ? AppColors.positive : null;
      final openDebtSubtext = isSettled
          ? l10n.groupsReportSettled
          : l10n.groupsReportPending;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.groupsReportTotalSpending.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCents(
                          totalSpendCents,
                          currencyCode,
                          locale: locale,
                          showDecimals: showDecimals,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.groupsMemberShareExpenseCount(expenseCount),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMiniSubCard(
                    icon: Icons.handshake_outlined,
                    iconColor: AppColors.positive,
                    label: l10n.groupsReportSettled,
                    value: formatCents(
                      totalSettledCents,
                      currencyCode,
                      locale: locale,
                      showDecimals: showDecimals,
                    ),
                    subtext: l10n.groupsReportSettlementsCount(settlementCount),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniSubCard(
                    icon: isSettled
                        ? Icons.check_circle_outline_rounded
                        : Icons.hourglass_top_rounded,
                    iconColor: openDebtColor ?? AppColors.textSecondary,
                    label: l10n.groupsReportOpenDebt,
                    value: formatCents(
                      openDebtCents,
                      currencyCode,
                      locale: locale,
                      showDecimals: showDecimals,
                    ),
                    valueColor: openDebtColor,
                    subtext: openDebtSubtext,
                    subtextColor: openDebtColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final name = selectedMemberName ?? '';
    final String heroTitle;
    final String netStatusText;
    final Color netColor;
    final String netPrefix;

    if (memberNetCents > 0) {
      netColor = AppColors.positive;
      netPrefix = '+';
      heroTitle = isCurrentUser
          ? l10n.groupsReportNetBalance
          : l10n.groupsReportMemberNet(name);
      netStatusText = isCurrentUser
          ? l10n.groupsReportYouOwed
          : l10n.groupsReportOwedTo(name);
    } else if (memberNetCents < 0) {
      netColor = AppColors.negative;
      netPrefix = '-';
      heroTitle = isCurrentUser
          ? l10n.groupsReportNetBalance
          : l10n.groupsReportMemberNet(name);
      netStatusText = isCurrentUser
          ? l10n.groupsReportYouOwe
          : l10n.groupsReportOwes(name);
    } else {
      netColor = AppColors.positive;
      netPrefix = '';
      heroTitle = isCurrentUser
          ? l10n.groupsReportNetBalance
          : l10n.groupsReportMemberNet(name);
      netStatusText = l10n.groupsReportSettled;
    }

    final formattedNet = memberNetCents == 0
        ? formatCents(0, currencyCode, locale: locale, showDecimals: false)
        : '$netPrefix${formatCents(memberNetCents.abs(), currencyCode, locale: locale, showDecimals: showDecimals)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heroTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedNet,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: netColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      netStatusText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: netColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.groupsMemberShareExpenseCount(expenseCount),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniSubCard(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.textSecondary,
                  label: l10n.groupsReportPaid,
                  value: formatCents(
                    memberPaidCents,
                    currencyCode,
                    locale: locale,
                    showDecimals: showDecimals,
                  ),
                  subtext: l10n.groupsReportPaidOutSubtitle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniSubCard(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.positive,
                  label: l10n.groupsReportReceived,
                  value: formatCents(
                    memberReceivedCents,
                    currencyCode,
                    locale: locale,
                    showDecimals: showDecimals,
                  ),
                  subtext: l10n.groupsReportReceivedSubtitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSubCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    required String subtext,
    Color? subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: subtextColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhoOwesWhomCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: debts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    l10n.groupsReportSettled,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.positive,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatCents(
                      0,
                      currencyCode,
                      locale: locale,
                      showDecimals: false,
                    ),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < debts.length; i++) ...[
                  _buildDebtRow(debts[i], l10n),
                  if (i < debts.length - 1)
                    const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
    );
  }

  Widget _buildDebtRow(OpenDebt debt, dynamic l10n) {
    final fromUser = users[debt.fromUserId];
    final toUser = users[debt.toUserId];
    final from = fromUser?.name ?? '?';
    final to = toUser?.name ?? '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          UserAvatar(
            name: from,
            colorIndex: fromUser?.colorIndex ?? 0,
            size: 26,
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 13,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          UserAvatar(name: to, colorIndex: toUser?.colorIndex ?? 0, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.groupsOwesTemplate(from, to),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCents(
              debt.amountCents,
              currencyCode,
              locale: locale,
              showDecimals: showDecimals,
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBreakdownCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < memberSummaries.length; i++) ...[
            _buildMemberSummaryRow(memberSummaries[i], l10n),
            if (i < memberSummaries.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberSummaryRow(
    GroupPeriodMemberSummary summary,
    dynamic l10n,
  ) {
    final user = users[summary.userId];
    final net = summary.netCents;
    final isPositive = net > 0;
    final isNegative = net < 0;

    final netColor = isPositive
        ? AppColors.positive
        : isNegative
        ? AppColors.negative
        : AppColors.textSecondary;

    final netPrefix = isPositive ? '+' : '';
    final netText = net == 0
        ? formatCents(0, currencyCode, locale: locale, showDecimals: false)
        : '$netPrefix${formatCents(net.abs(), currencyCode, locale: locale, showDecimals: showDecimals)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          UserAvatar(
            name: summary.name,
            colorIndex: user?.colorIndex ?? 0,
            size: 32,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.groupsReportPaid}: ${formatCents(summary.paidCents, currencyCode, locale: locale, showDecimals: showDecimals)} · ${l10n.groupsReportShare}: ${formatCents(summary.shareCents, currencyCode, locale: locale, showDecimals: showDecimals)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: netColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              netText,
              style: TextStyle(
                fontSize: 12,
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
