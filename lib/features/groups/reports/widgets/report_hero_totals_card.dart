import 'package:flutter/material.dart';

import 'package:scene_split/core/l10n/l10n_extensions.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/shared/widgets/app_card.dart';

class ReportHeroTotalsCard extends StatelessWidget {
  const ReportHeroTotalsCard({
    super.key,
    required this.selectedMemberId,
    required this.selectedMemberName,
    required this.isCurrentUser,
    required this.totalSpendCents,
    required this.expenseCount,
    required this.totalSettledCents,
    required this.settlementCount,
    required this.openDebtCents,
    required this.memberNetCents,
    required this.memberPaidCents,
    required this.memberReceivedCents,
    required this.currencyCode,
    required this.locale,
    required this.showDecimals,
  });

  final String? selectedMemberId;
  final String? selectedMemberName;
  final bool isCurrentUser;
  final int totalSpendCents;
  final int expenseCount;
  final int totalSettledCents;
  final int settlementCount;
  final int openDebtCents;
  final int memberNetCents;
  final int memberPaidCents;
  final int memberReceivedCents;
  final String currencyCode;
  final String locale;
  final bool showDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSingleMember = selectedMemberId != null;

    if (!isSingleMember) {
      final isSettled = openDebtCents == 0;
      final openDebtColor = isSettled ? AppColors.positive : null;
      final openDebtSubtext = isSettled
          ? l10n.groupsReportSettled
          : l10n.groupsReportPending;

      return AppCard(
        padding: const EdgeInsets.all(18),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: colorScheme.onSurfaceVariant,
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
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.groupsMemberShareExpenseCount(expenseCount),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: HeroSubCard(
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
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HeroSubCard(
                    icon: isSettled
                        ? Icons.check_circle_outline_rounded
                        : Icons.hourglass_top_rounded,
                    iconColor: openDebtColor ?? colorScheme.onSurfaceVariant,
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
                    colorScheme: colorScheme,
                    isDark: isDark,
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

    return AppCard(
      padding: const EdgeInsets.all(18),
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
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedNet,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: netColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      netStatusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: netColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.groupsMemberShareExpenseCount(expenseCount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HeroSubCard(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: colorScheme.onSurfaceVariant,
                  label: l10n.groupsReportPaid,
                  value: formatCents(
                    memberPaidCents,
                    currencyCode,
                    locale: locale,
                    showDecimals: showDecimals,
                  ),
                  subtext: l10n.groupsReportPaidOutSubtitle,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HeroSubCard(
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
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeroSubCard extends StatelessWidget {
  const HeroSubCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    required this.subtext,
    this.subtextColor,
    required this.colorScheme,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final String subtext;
  final Color? subtextColor;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: subtextColor ?? colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
