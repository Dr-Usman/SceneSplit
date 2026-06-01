import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double totalOwed;
  final double totalOwing;

  const BalanceCard({
    super.key,
    required this.totalOwed,
    required this.totalOwing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netBalance = totalOwed - totalOwing;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Balance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(netBalance),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: netBalance >= 0 ? Colors.green : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _BalanceInfo(
                  label: 'You owe',
                  amount: totalOwing,
                  color: theme.colorScheme.error,
                  icon: Icons.arrow_upward,
                ),
                const SizedBox(width: 24),
                _BalanceInfo(
                  label: 'You are owed',
                  amount: totalOwed,
                  color: Colors.green,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix\$${amount.abs().toStringAsFixed(2)}';
  }
}

class _BalanceInfo extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BalanceInfo({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
