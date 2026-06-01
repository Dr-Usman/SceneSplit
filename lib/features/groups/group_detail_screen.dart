import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../models/group_model.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: groupAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Error'),
          data: (group) => Text(group?.name ?? 'Group'),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Group')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Group')),
            ],
            onSelected: (value) {
              // TODO: Handle menu actions
            },
          ),
        ],
      ),
      body: groupAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading group...'),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Group not found'));
          }
          return _buildGroupContent(context, ref, group);
        },
      ),
    );
  }

  Widget _buildGroupContent(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
  ) {
    final dashboardAsync = ref.watch(groupDashboardProvider(groupId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 24, child: Text(group.type.icon)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (group.description != null)
                            Text(
                              group.description!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Members (${group.members.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.members.map((member) {
                    return Chip(
                      avatar: AvatarWidget(name: member.name, radius: 12),
                      label: Text(member.name),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        dashboardAsync.when(
          loading: () => const LoadingIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (data) {
            if (data.balances.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No balances yet. Add an expense to get started.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balances',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.balances.entries.map((entry) {
                      final user = group.members.firstWhere(
                        (m) => m.id == entry.key,
                        orElse: () => group.members.first,
                      );
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AvatarWidget(name: user.name, radius: 16),
                        title: Text(user.name),
                        trailing: Text(
                          '${entry.value >= 0 ? '+' : ''}\$${entry.value.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: entry.value >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
