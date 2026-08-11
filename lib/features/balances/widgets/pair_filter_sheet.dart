import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/app_database.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Who → Whom filter sheet with Clear / Show results.
class PairFilterSheet extends StatelessWidget {
  const PairFilterSheet({
    super.key,
    required this.users,
    required this.whoId,
    required this.whomId,
    required this.onPickWho,
    required this.onPickWhom,
    required this.onClearWho,
    required this.onClearWhom,
    required this.onClear,
    required this.onShowResults,
  });

  final Map<String, User> users;
  final String? whoId;
  final String? whomId;
  final VoidCallback onPickWho;
  final VoidCallback onPickWhom;
  final VoidCallback onClearWho;
  final VoidCallback onClearWhom;
  final VoidCallback onClear;
  final VoidCallback onShowResults;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.balancesFilterTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.balancesFilterHint,
              style: theme.textTheme.bodySmall?.copyWith(color: onVariant),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PersonSlot(
                    label: l10n.balancesWho,
                    user: whoId == null ? null : users[whoId!],
                    emptyLabel: l10n.balancesAnyone,
                    backgroundColor: AppColors.primarySoft.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.16 : 0.4,
                    ),
                    onTap: onPickWho,
                    onClear: whoId == null ? null : onClearWho,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 36, 8, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.balancesOwes,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: onVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _PersonSlot(
                    label: l10n.balancesWhom,
                    user: whomId == null ? null : users[whomId!],
                    emptyLabel: l10n.balancesSelectPerson,
                    backgroundColor: AppColors.secondarySoft.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.16 : 0.4,
                    ),
                    onTap: onPickWhom,
                    onClear: whomId == null ? null : onClearWhom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(l10n.balancesClear),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onShowResults,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(l10n.balancesShowResults),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonSlot extends StatelessWidget {
  const _PersonSlot({
    required this.label,
    required this.user,
    required this.emptyLabel,
    required this.backgroundColor,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final User? user;
  final String emptyLabel;
  final Color backgroundColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;
    final name = user == null
        ? emptyLabel
        : user!.isCurrentUser
        ? l10n.commonYouSuffix(user!.name)
        : user!.name;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          children: [
            // Full-width so label/avatar/name stay centered; × overlays only.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: onVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (user == null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 24,
                          color: onVariant,
                        ),
                      )
                    else
                      UserAvatar(
                        name: user!.name,
                        colorIndex: user!.colorIndex,
                        size: 48,
                      ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: user == null ? onVariant : null,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onClear != null)
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  tooltip: l10n.balancesClearSelection,
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, size: 18, color: onVariant),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
