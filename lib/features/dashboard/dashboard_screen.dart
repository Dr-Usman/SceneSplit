import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/widgets.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SceneSplit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading dashboard...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              BalanceCard(
                totalOwed: data.totalOwed,
                totalOwing: data.totalOwing,
              ),
              if (data.suggestions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suggested Settlements',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to settlements
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                ...data.suggestions.map(
                  (suggestion) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.payment)),
                    title: Text(
                      'Pay ${suggestion.toUserId}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '\$${suggestion.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Record settlement
                    },
                  ),
                ),
              ],
              if (data.balances.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Balances',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...data.balances.entries.map(
                  (entry) => ListTile(
                    leading: CircleAvatar(
                      child: Text(entry.key.substring(0, 2).toUpperCase()),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value >= 0 ? '+' : ''}\$${entry.value.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: entry.value >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
              if (data.balances.isEmpty && data.suggestions.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long,
                  title: 'No expenses yet',
                  subtitle: 'Add your first expense to get started',
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add expense
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
