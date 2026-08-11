import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/app_database.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Searchable person picker for Who / Whom filters.
///
/// Pops with the selected user id, or `''` when Clear selection is tapped.
class PersonPickerSheet extends StatefulWidget {
  const PersonPickerSheet({
    super.key,
    required this.users,
    required this.excludeUserId,
    required this.selectedUserId,
    required this.scrollController,
  });

  final List<User> users;
  final String? excludeUserId;
  final String? selectedUserId;
  final ScrollController scrollController;

  @override
  State<PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<PersonPickerSheet> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<User> get _visibleUsers {
    final sorted = [...widget.users]
      ..sort((a, b) {
        if (a.isCurrentUser) return -1;
        if (b.isCurrentUser) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final query = _queryController.text.trim().toLowerCase();
    return [
      for (final u in sorted)
        if (u.id != widget.excludeUserId)
          if (query.isEmpty || u.name.toLowerCase().contains(query)) u,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final visible = _visibleUsers;
    final hasSelection = widget.selectedUserId != null;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.balancesPickPerson,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasSelection)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: Text(l10n.balancesClearSelection),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: l10n.peopleSearchHint,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 36,
                ),
                suffixIcon: _queryController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          _queryController.clear();
                          setState(() {});
                        },
                      ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.balancesNoPeopleFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final user = visible[i];
                      final selected = user.id == widget.selectedUserId;
                      final name = user.isCurrentUser
                          ? l10n.commonYouSuffix(user.name)
                          : user.name;
                      return ListTile(
                        leading: UserAvatar(
                          name: user.name,
                          colorIndex: user.colorIndex,
                          size: 40,
                        ),
                        title: Text(name),
                        trailing: selected
                            ? Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, user.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
