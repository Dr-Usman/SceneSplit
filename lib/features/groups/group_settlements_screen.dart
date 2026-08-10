import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../providers/data_providers.dart';
import '../../providers/group_detail_provider.dart';
import '../settlements/record_settlement_sheet.dart';
import 'group_activity_dialogs.dart';
import 'widgets/group_settlement_tile.dart';

class GroupSettlementsScreen extends ConsumerWidget {
  const GroupSettlementsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final detail = ref.watch(groupDetailProvider(groupId));
    final users = ref.watch(userByIdProvider);
    final title = detail.maybeWhen(
      data: (data) => l10n.groupsSettlementsScreenTitle(data.group.name),
      orElse: () => l10n.groupsSettlementsTitle,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).appBarTheme.titleTextStyle?.copyWith(fontSize: 18),
        ),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.settlements.isEmpty) {
            return Center(
              child: Text(
                l10n.groupsEmptySettlementsBody,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: data.settlements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final settlement = data.settlements[index];
              return GroupSettlementTile(
                settlement: settlement,
                users: users,
                currencyCode: data.group.currencyCode,
                locale: locale,
                onTap: () => showRecordSettlementSheet(
                  context,
                  groupId: groupId,
                  currencyCode: data.group.currencyCode,
                  members: data.members,
                  existing: settlement,
                ),
                onDelete: () =>
                    confirmDeleteSettlement(context, ref, settlement),
              );
            },
          );
        },
      ),
    );
  }
}
