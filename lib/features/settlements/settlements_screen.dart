import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/widgets.dart';
import '../../providers/providers.dart';

class SettlementsScreen extends ConsumerWidget {
  const SettlementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementsAsync = ref.watch(settlementListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settlements')),
      body: settlementsAsync.when(
        loading: () =>
            const LoadingIndicator(message: 'Loading settlements...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (settlements) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(settlementListProvider);
          },
          child: settlements.isEmpty
              ? const EmptyState(
                  icon: Icons.payment,
                  title: 'No settlements yet',
                  subtitle: 'Settle up with friends to clear debts',
                )
              : ListView.builder(
                  itemCount: settlements.length,
                  itemBuilder: (context, index) {
                    final settlement = settlements[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.payment)),
                      title: Text(
                        '${settlement.fromUser} paid ${settlement.toUser}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: settlement.note != null
                          ? Text(settlement.note!)
                          : null,
                      trailing: Text(
                        '\$${settlement.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
