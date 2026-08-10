import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/expense_repository.dart';
import '../../../repositories/settlement_repository.dart';

Future<void> confirmDeleteExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.groupsDeleteExpenseTitle),
      content: Text(l10n.groupsDeleteExpenseBody(expense.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.negative),
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await deleteExpense(ref.read(databaseProvider), expense.id);
  }
}

Future<void> confirmDeleteSettlement(
  BuildContext context,
  WidgetRef ref,
  Settlement settlement,
) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.groupsDeleteSettlementTitle),
      content: Text(l10n.groupsDeleteSettlementBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.negative),
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await deleteSettlement(ref.read(databaseProvider), settlement.id);
  }
}
