import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../database/app_database.dart';
import 'user_avatar.dart';

/// Shared member row: avatar + name + selection control.
/// Used for Paid by (single/multiple) and Split equal participants.
class MemberSelectTile extends StatelessWidget {
  const MemberSelectTile({
    super.key,
    required this.user,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
  });

  final User user;
  final bool selected;
  final VoidCallback onTap;

  /// When true, shows a checkbox; when false, a checkmark for single-select.
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final selectedLabel = isDark ? AppColors.primary : AppColors.primaryDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primarySoft.withValues(alpha: isDark ? 0.22 : 0.5)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primary : borderColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                UserAvatar(
                  name: user.name,
                  colorIndex: user.colorIndex,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: selected
                          ? selectedLabel
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (multiSelect)
                  _SelectCheckbox(selected: selected)
                else if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 22,
                  )
                else
                  Icon(Icons.circle_outlined, color: borderColor, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectCheckbox extends StatelessWidget {
  const _SelectCheckbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}
