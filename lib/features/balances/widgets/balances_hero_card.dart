import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../database/app_database.dart';
import '../../../providers/balances_overview_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/breakdown_pie_chart.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Whom/Who POV hero: avatar + name and owed / owe split with multi-currency totals.
///
/// When [pairOther] is set (Who + Whom both filtered), shows a net line under
/// the card for currencies where both directions are open.
class BalancesHeroCard extends StatelessWidget {
  const BalancesHeroCard({
    super.key,
    required this.person,
    required this.openDebts,
    required this.users,
    required this.locale,
    required this.fallbackCurrency,
    this.pairOther,
  });

  final User person;
  final List<OpenPairwiseBalance> openDebts;
  final Map<String, User> users;
  final String locale;
  final String fallbackCurrency;

  /// Other person in a Who↔Whom filter; enables pair net lines.
  final User? pairOther;

  String _displayName(BuildContext context, User user) {
    final l10n = context.l10n;
    if (user.isCurrentUser) return l10n.commonYouSuffix(user.name);
    return user.name;
  }

  void _showOwedBreakdown(BuildContext context) {
    final l10n = context.l10n;
    final agg = aggregatePersonPovByCounterparty(openDebts, person.id);
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    final ids = agg.owedByCounterparty.keys.toList()
      ..sort((a, b) {
        final aName = users[a]?.name.toLowerCase() ?? a;
        final bName = users[b]?.name.toLowerCase() ?? b;
        return aName.compareTo(bName);
      });
    for (final id in ids) {
      final byCurrency = agg.owedByCounterparty[id]!;
      final codes = byCurrency.keys.toList()..sort();
      for (final code in codes) {
        final cents = byCurrency[code] ?? 0;
        if (cents <= 0) continue;
        final other = users[id];
        final label = other == null
            ? '?'
            : other.isCurrentUser
            ? l10n.commonYouSuffix(other.name)
            : other.name;
        slices.add(
          BreakdownSlice(
            label: label,
            cents: cents,
            color: chartColorForIndex(colorIndex++),
            currencyCode: code,
            id: id,
          ),
        );
      }
    }
    if (slices.isEmpty) return;
    showBreakdownSheet(
      context,
      title: l10n.balancesHeroOwedBreakdown(_displayName(context, person)),
      subtitle: l10n.homeBreakdownSubtitle,
      slices: slices,
    );
  }

  void _showOweBreakdown(BuildContext context) {
    final l10n = context.l10n;
    final agg = aggregatePersonPovByCounterparty(openDebts, person.id);
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    final ids = agg.oweToCounterparty.keys.toList()
      ..sort((a, b) {
        final aName = users[a]?.name.toLowerCase() ?? a;
        final bName = users[b]?.name.toLowerCase() ?? b;
        return aName.compareTo(bName);
      });
    for (final id in ids) {
      final byCurrency = agg.oweToCounterparty[id]!;
      final codes = byCurrency.keys.toList()..sort();
      for (final code in codes) {
        final cents = byCurrency[code] ?? 0;
        if (cents <= 0) continue;
        final other = users[id];
        final label = other == null
            ? '?'
            : other.isCurrentUser
            ? l10n.commonYouSuffix(other.name)
            : other.name;
        slices.add(
          BreakdownSlice(
            label: label,
            cents: cents,
            color: chartColorForIndex(colorIndex++),
            currencyCode: code,
            id: id,
          ),
        );
      }
    }
    if (slices.isEmpty) return;
    showBreakdownSheet(
      context,
      title: l10n.balancesHeroOweBreakdown(_displayName(context, person)),
      subtitle: l10n.homeBreakdownSubtitle,
      slices: slices,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final totals = summarizePersonPovTotals(openDebts, person.id);
    final displayName = _displayName(context, person);
    final owedLabel = person.isCurrentUser
        ? l10n.homeYouWillGet
        : l10n.balancesHeroOwed;
    final oweLabel = person.isCurrentUser
        ? l10n.homeYouWillGive
        : l10n.balancesHeroOwe;

    final hasOwed = totals.any((t) => t.owedToThemCents > 0);
    final hasOwe = totals.any((t) => t.theyOweCents > 0);
    final pairNets = pairOther == null
        ? const <PersonPovCurrencyNet>[]
        : netPersonPovTotals(totals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            UserAvatar(
              name: person.name,
              colorIndex: person.colorIndex,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _HeroHalf(
                        label: owedLabel,
                        locale: locale,
                        fallbackCurrency: fallbackCurrency,
                        amounts: [
                          for (final t in totals)
                            if (t.owedToThemCents > 0)
                              (t.currencyCode, t.owedToThemCents),
                        ],
                        showZero: !hasOwed,
                        amountColor: AppColors.primaryDark,
                        onTap: hasOwed
                            ? () => _showOwedBreakdown(context)
                            : null,
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.border,
                    ),
                    Expanded(
                      child: _HeroHalf(
                        label: oweLabel,
                        locale: locale,
                        fallbackCurrency: fallbackCurrency,
                        amounts: [
                          for (final t in totals)
                            if (t.theyOweCents > 0)
                              (t.currencyCode, t.theyOweCents),
                        ],
                        showZero: !hasOwe,
                        amountColor: AppColors.negative,
                        onTap: hasOwe ? () => _showOweBreakdown(context) : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (pairOther != null && pairNets.isNotEmpty) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.border,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < pairNets.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        _PairNetLine(
                          net: pairNets[i],
                          subject: person,
                          other: pairOther!,
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

    // Color from current-user POV when they're in the pair.
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

class _HeroHalf extends StatelessWidget {
  const _HeroHalf({
    required this.label,
    required this.locale,
    required this.fallbackCurrency,
    required this.amounts,
    required this.showZero,
    required this.amountColor,
    required this.onTap,
  });

  final String label;
  final String locale;
  final String fallbackCurrency;
  final List<(String currencyCode, int cents)> amounts;
  final bool showZero;
  final Color amountColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final zeroColor = onVariant.withValues(alpha: 0.7);

    final child = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: onVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 15,
                  color: onVariant.withValues(alpha: 0.7),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (showZero)
            Text(
              formatCents(0, fallbackCurrency, locale: locale),
              style: theme.textTheme.titleSmall?.copyWith(
                color: zeroColor,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            )
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                [
                  for (final a in amounts)
                    formatCents(a.$2, a.$1, locale: locale),
                ].join(' · '),
                maxLines: 1,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: onTap == null ? child : InkWell(onTap: onTap, child: child),
    );
  }
}
