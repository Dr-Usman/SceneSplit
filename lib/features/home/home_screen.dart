import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../providers/database_provider.dart';
import '../../providers/home_provider.dart';
import '../../shared/widgets/breakdown_pie_chart.dart';
import '../groups/create_group_screen.dart';
import '../groups/group_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);
    final currencyCode = ref.watch(currencyCodeProvider).value ?? 'PKR';
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SceneSplit'),
        actions: [
          if (user!= null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateGroupScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New group'),
      ),
      body: homeData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _BalanceSummaryCard(data: data, currencyCode: currencyCode),
            const SizedBox(height: 28),
            Text(
              'GROUPS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (data.groups.isEmpty)
              const _EmptyGroups()
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
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    for (final summary in data.groups) {
      if (summary.myNetCents <= 0) continue;
      slices.add(BreakdownSlice(
        label: '${summary.group.emoji} ${summary.group.name}',
        cents: summary.myNetCents,
        color: chartColorForIndex(colorIndex++),
        currencyCode: summary.group.currencyCode,
      ));
    }
    showBreakdownSheet(
      context,
      title: 'You get by group',
      subtitle: 'Amounts shown in each group\'s currency',
      slices: slices,
    );
  }

  void _showOweBreakdown(BuildContext context) {
    final slices = <BreakdownSlice>[];
    var colorIndex = 0;
    for (final summary in data.groups) {
      if (summary.myNetCents >= 0) continue;
      slices.add(BreakdownSlice(
        label: '${summary.group.emoji} ${summary.group.name}',
        cents: -summary.myNetCents,
        color: chartColorForIndex(colorIndex++),
        currencyCode: summary.group.currencyCode,
      ));
    }
    showBreakdownSheet(
      context,
      title: 'You will give by group',
      subtitle: 'Amounts shown in each group\'s currency',
      slices: slices,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Expanded(
            child: _SummaryHalf(
              label: 'You are owed',
              amount: formatCents(data.totalOwedToMeCents, currencyCode),
              backgroundColor: AppColors.primary,
              labelColor: Colors.white.withValues(alpha: 0.88),
              amountColor: Colors.white,
              onTap: () => _showOwedBreakdown(context),
            ),
          ),
          Expanded(
            child: _SummaryHalf(
              label: 'You owe',
              amount: formatCents(data.totalIOweCents, currencyCode),
              backgroundColor: AppColors.secondary,
              labelColor: Colors.white.withValues(alpha: 0.88),
              amountColor: Colors.white,
              onTap: () => _showOweBreakdown(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryHalf extends StatelessWidget {
  const _SummaryHalf({
    required this.label,
    required this.amount,
    required this.backgroundColor,
    required this.labelColor,
    required this.amountColor,
    this.onTap,
  });

  final String label;
  final String amount;
  final Color backgroundColor;
  final Color labelColor;
  final Color amountColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    final group = summary.group;
    final net = summary.myNetCents;
    final settled = net == 0;

    final String balanceLabel;
    final String? balanceAmount;
    final Color balanceColor;
    if (settled) {
      balanceLabel = 'settled up';
      balanceAmount = null;
      balanceColor = AppColors.textSecondary;
    } else if (net > 0) {
      balanceLabel = 'you will get';
      balanceAmount = formatCents(net, group.currencyCode);
      balanceColor = AppColors.positive;
    } else {
      balanceLabel = 'you will give';
      balanceAmount = formatCents(net, group.currencyCode);
      balanceColor = AppColors.negative;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupDetailScreen(groupId: group.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
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
                      '${summary.memberCount} members',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_add_outlined,
              color: AppColors.primaryDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No groups yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create a group for your trip, home,\nor friends to start splitting.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
