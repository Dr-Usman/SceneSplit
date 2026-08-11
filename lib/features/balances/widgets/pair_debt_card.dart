import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../database/app_database.dart';
import '../../../providers/balances_overview_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dashed_divider.dart';
import '../../../shared/widgets/user_avatar.dart';

/// One directed pair card with multi-currency open debt and scene labels.
class PairDebtCard extends StatelessWidget {
  const PairDebtCard({
    super.key,
    required this.summary,
    required this.users,
    required this.locale,
    required this.currentUserId,
    required this.onTap,
  });

  final PairOpenBalanceSummary summary;
  final Map<String, User> users;
  final String locale;
  final String? currentUserId;
  final VoidCallback onTap;

  String _displayName(BuildContext context, User? user) {
    final l10n = context.l10n;
    if (user == null) return '?';
    if (user.isCurrentUser) return l10n.commonYouSuffix(user.name);
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final fromUser = users[summary.fromUserId];
    final toUser = users[summary.toUserId];
    final fromName = _displayName(context, fromUser);
    final toName = _displayName(context, toUser);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final showMultiCurrency = summary.currencyTotals.length > 1;

    final bool? youAreOwed;
    if (currentUserId != null && summary.toUserId == currentUserId) {
      youAreOwed = true;
    } else if (currentUserId != null && summary.fromUserId == currentUserId) {
      youAreOwed = false;
    } else {
      youAreOwed = null;
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PersonColumn(
                        name: fromName,
                        avatarName: fromUser?.name ?? '?',
                        colorIndex: fromUser?.colorIndex ?? 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          Text(
                            l10n.balancesOwes,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: onVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _PersonColumn(
                        name: toName,
                        avatarName: toUser?.name ?? '?',
                        colorIndex: toUser?.colorIndex ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 1,
                  height: 48,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.border,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < summary.currencyTotals.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    _OpenDebtLabel(
                      currencyCode: summary.currencyTotals[i].currencyCode,
                      showCurrency: showMultiCurrency,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      formatCents(
                        summary.currencyTotals[i].amountCents,
                        summary.currencyTotals[i].currencyCode,
                        locale: locale,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  if (youAreOwed != null) ...[
                    const SizedBox(height: 6),
                    _PovBadge(youAreOwed: youAreOwed),
                  ],
                ],
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: onVariant),
            ],
          ),
          if (summary.sceneLabels.isNotEmpty) ...[
            const SizedBox(height: 12),
            const DashedDivider(),
            const SizedBox(height: 10),
            Text(
              summary.sceneLabels.join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: onVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonColumn extends StatelessWidget {
  const _PersonColumn({
    required this.name,
    required this.avatarName,
    required this.colorIndex,
  });

  final String name;
  final String avatarName;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAvatar(name: avatarName, colorIndex: colorIndex, size: 32),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _PovBadge extends StatelessWidget {
  const _PovBadge({required this.youAreOwed});

  final bool youAreOwed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Color fg;
    final Color bg;
    if (youAreOwed) {
      // Match hero "You will get" — teal for money owed to you.
      fg = AppColors.primaryDark;
      bg = AppColors.primarySoft.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 1,
      );
    } else {
      // Match hero "You will give" — red for money you owe.
      fg = AppColors.negative;
      bg = AppColors.negative.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        youAreOwed ? l10n.balancesYouAreOwed : l10n.balancesYouOwe,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _OpenDebtLabel extends StatelessWidget {
  const _OpenDebtLabel({
    required this.currencyCode,
    required this.showCurrency,
    this.textAlign = TextAlign.start,
  });

  final String currencyCode;
  final bool showCurrency;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final baseStyle = theme.textTheme.labelSmall?.copyWith(
      color: onVariant,
      fontWeight: FontWeight.w600,
    );

    if (!showCurrency) {
      return Text(
        l10n.balancesOpenDebtTotal,
        textAlign: textAlign,
        style: baseStyle,
      );
    }

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.balancesOpenDebtTotal),
          TextSpan(
            text: ' ($currencyCode)',
            style: baseStyle?.copyWith(
              fontSize: (baseStyle.fontSize ?? 11) * 0.9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
