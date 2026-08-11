import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/app_database.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Slim Who → Whom filter summary; tap opens the filter sheet.
class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.users,
    required this.whoId,
    required this.whomId,
    required this.onTap,
  });

  final Map<String, User> users;
  final String? whoId;
  final String? whomId;
  final VoidCallback onTap;

  String _name(BuildContext context, User? user, String empty) {
    final l10n = context.l10n;
    if (user == null) return empty;
    if (user.isCurrentUser) return l10n.commonYouSuffix(user.name);
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final whoUser = whoId == null ? null : users[whoId!];
    final whomUser = whomId == null ? null : users[whomId!];
    final whoName = _name(context, whoUser, l10n.balancesAnyone);
    final whomName = _name(context, whomUser, l10n.balancesSelectPerson);
    final hasSelection = whoId != null || whomId != null;
    final isDark = theme.brightness == Brightness.dark;
    final bg = hasSelection
        ? AppColors.primarySoft.withValues(alpha: isDark ? 0.18 : 0.55)
        : theme.colorScheme.surface;
    final borderColor = isDark
        ? AppColors.borderDark
        : hasSelection
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.border;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    if (whoUser != null)
                      UserAvatar(
                        name: whoUser.name,
                        colorIndex: whoUser.colorIndex,
                        size: 22,
                      )
                    else
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: onVariant,
                      ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        whoName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (whomUser != null)
                      UserAvatar(
                        name: whomUser.name,
                        colorIndex: whomUser.colorIndex,
                        size: 22,
                      )
                    else
                      Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: onVariant,
                      ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        whomName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, size: 20, color: onVariant),
            ],
          ),
        ),
      ),
    );
  }
}
