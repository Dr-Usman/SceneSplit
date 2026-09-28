import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money.dart';
import '../../../database/app_database.dart';
import '../../../shared/widgets/app_card.dart';

class GroupSettlementTile extends StatelessWidget {
  const GroupSettlementTile({
    super.key,
    required this.settlement,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
    required this.onTap,
    required this.onDelete,
  });

  final Settlement settlement;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final bool showDecimals;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final from = users[settlement.fromUserId]?.name ?? '?';
    final to = users[settlement.toUserId]?.name ?? '?';
    final date = DateFormat.MMMEd(locale).format(settlement.date);
    final note = settlement.note?.trim();
    final hasNote = note != null && note.isNotEmpty;

    return Dismissible(
      key: ValueKey(settlement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.negative.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.negative,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.positive.withValues(
                      alpha: isDark ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: AppColors.positive,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.groupsSettlementPaid(from, to),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatCents(
                    settlement.amountCents,
                    currencyCode,
                    locale: locale,
                    showDecimals: showDecimals,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.positive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              hasNote ? '$date · $note' : date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
