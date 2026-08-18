import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../providers/data_providers.dart';
import '../../providers/group_detail_provider.dart';
import '../../shared/widgets/app_card.dart';
import '../expenses/expense_detail_screen.dart';
import 'group_activity_dialogs.dart';
import 'widgets/group_expense_tile.dart';
import 'widgets/share_expenses_sheet.dart';

class GroupExpensesScreen extends ConsumerWidget {
  const GroupExpensesScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final detail = ref.watch(groupDetailProvider(groupId));
    final users = ref.watch(userByIdProvider);
    final data = detail.asData?.value;
    final title = detail.maybeWhen(
      data: (data) => l10n.groupsExpensesScreenTitle(data.group.name),
      orElse: () => l10n.groupsExpensesTitle,
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
        actions: [
          if (data != null && data.expenses.isNotEmpty)
            IconButton(
              tooltip: l10n.groupsShareExpenses,
              onPressed: () => shareSceneExpenses(
                context,
                ref,
                data: data,
                users: users,
                locale: locale,
              ),
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data.expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.groupsEmptyExpensesTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.groupsEmptyExpensesBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: data.expenses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = data.expenses[index];
              return GroupExpenseTile(
                item: item,
                users: users,
                currencyCode: data.group.currencyCode,
                locale: locale,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExpenseDetailScreen(
                      groupId: groupId,
                      expenseId: item.expense.id,
                      currencyCode: data.group.currencyCode,
                    ),
                  ),
                ),
                onDelete: () =>
                    confirmDeleteExpense(context, ref, item.expense),
              );
            },
          );
        },
      ),
    );
  }
}
