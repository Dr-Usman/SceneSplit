import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_links.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../providers/database_provider.dart';
import '../../providers/home_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/breakdown_pie_chart.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/summary_split_card.dart';
import '../groups/create_group_screen.dart';
import '../groups/group_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final homeData = ref.watch(homeDataProvider);
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLinks.appName),
        actions: [
          IconButton(
            tooltip: l10n.homeNewGroup,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: homeData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.commonSomethingWentWrong('$e'))),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _BalanceSummaryCard(data: data, currencyCode: currencyCode),
            const SizedBox(height: 28),
            SectionHeader(l10n.homeGroupsHeader),
            const SizedBox(height: 12),
            if (data.groups.isEmpty)
              _EmptyGroups()
            else
              for (final summary in data.groups) ...[
                _GroupCard(summary: summary),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({required this.data, required this.currencyCode});

  final HomeData data;
  final String currencyCode;

  void _showOwedBreakdown(BuildContext context) {
    final l10n = context.l10n;
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    for (final summary in data.groups) {
      if (summary.myNetCents <= 0) continue;
      slices.add(
        BreakdownSlice(
          label: '${summary.group.emoji} ${summary.group.name}',
          cents: summary.myNetCents,
          color: chartColorForIndex(colorIndex++),
          currencyCode: summary.group.currencyCode,
        ),
      );
    }
    showBreakdownSheet(
      context,
      title: l10n.homeYouGetByGroup,
      subtitle: l10n.homeBreakdownSubtitle,
      slices: slices,
    );
  }

  void _showOweBreakdown(BuildContext context) {
    final l10n = context.l10n;
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    for (final summary in data.groups) {
      if (summary.myNetCents >= 0) continue;
      slices.add(
        BreakdownSlice(
          label: '${summary.group.emoji} ${summary.group.name}',
          cents: -summary.myNetCents,
          color: chartColorForIndex(colorIndex++),
          currencyCode: summary.group.currencyCode,
        ),
      );
    }
    showBreakdownSheet(
      context,
      title: l10n.homeYouWillGiveByGroup,
      subtitle: l10n.homeBreakdownSubtitle,
      slices: slices,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return SummarySplitCard(
      owedLabel: l10n.homeYouWillGet,
      owedAmount: formatCents(
        data.totalOwedToMeCents,
        currencyCode,
        locale: locale,
      ),
      oweLabel: l10n.homeYouWillGive,
      oweAmount: formatCents(data.totalIOweCents, currencyCode, locale: locale),
      onOwedTap: _showOwedBreakdown,
      onOweTap: _showOweBreakdown,
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final group = summary.group;
    final net = summary.myNetCents;
    final settled = net == 0;

    final String balanceLabel;
    final String? balanceAmount;
    final Color balanceColor;
    if (settled) {
      balanceLabel = l10n.homeSettledUp;
      balanceAmount = null;
      balanceColor = Theme.of(context).colorScheme.onSurfaceVariant;
    } else if (net > 0) {
      balanceLabel = l10n.homeCardYouWillGet;
      balanceAmount = formatCents(net, group.currencyCode, locale: locale);
      balanceColor = AppColors.positive;
    } else {
      balanceLabel = l10n.homeCardYouWillGive;
      balanceAmount = formatCents(net, group.currencyCode, locale: locale);
      balanceColor = AppColors.negative;
    }

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppGradients.emojiTile(context),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Text(group.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.homeMemberCount(summary.memberCount),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balanceLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (balanceAmount != null) ...[
                const SizedBox(height: 2),
                Text(
                  balanceAmount,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: balanceColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.15
                    : 1,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_add_outlined,
              color: AppColors.primaryDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeEmptyTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
