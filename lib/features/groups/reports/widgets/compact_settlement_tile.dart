import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/core/utils/money.dart';
import 'package:scene_split/database/app_database.dart';

/// Compact settlement row designed for reports and lists.
class CompactSettlementTile extends StatelessWidget {
  const CompactSettlementTile({
    super.key,
    required this.settlement,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.showDecimals = true,
    required this.onTap,
  });

  final Settlement settlement;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final bool showDecimals;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final from = users[settlement.fromUserId]?.name ?? '?';
    final to = users[settlement.toUserId]?.name ?? '?';
    final date = DateFormat.MMMEd(locale).format(settlement.date);
    final note = settlement.note?.trim();
    final subtitle = (note != null && note.isNotEmpty) ? '$date · $note' : date;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.positive.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.handshake_outlined,
                size: 16,
                color: AppColors.positive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$from → $to',
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
