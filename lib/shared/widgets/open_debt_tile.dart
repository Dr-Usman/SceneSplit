import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/utils/money.dart';
import '../../database/app_database.dart';
import '../../services/balance_service.dart';
import 'user_avatar.dart';

/// Shared “A owes B” row used on group detail, person detail, and Balances.
class OpenDebtTile extends StatelessWidget {
  const OpenDebtTile({
    super.key,
    required this.debt,
    required this.users,
    required this.currencyCode,
    required this.locale,
    this.subtitle,
    this.showAvatars = false,
    this.onTap,
  });

  final OpenDebt debt;
  final Map<String, User> users;
  final String currencyCode;
  final String locale;
  final String? subtitle;
  final bool showAvatars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fromUser = users[debt.fromUserId];
    final toUser = users[debt.toUserId];
    final from = fromUser?.name ?? '?';
    final to = toUser?.name ?? '?';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final descriptionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            if (showAvatars) ...[
              UserAvatar(
                name: from,
                colorIndex: fromUser?.colorIndex ?? 0,
                size: 36,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: onVariant,
                ),
              ),
              UserAvatar(
                name: to,
                colorIndex: toUser?.colorIndex ?? 0,
                size: 36,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.groupsOwesTemplate(from, to),
                    style: descriptionStyle,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: onVariant),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              formatCents(debt.amountCents, currencyCode, locale: locale),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18, color: onVariant),
            ],
          ],
        ),
      ),
    );
  }
}
