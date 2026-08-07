import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/localize_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/user_repository.dart';
import '../../../shared/widgets/user_avatar.dart';

const _kSwipeActionsWidth = 144.0;

class PersonRow extends StatefulWidget {
  const PersonRow({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.subtitle,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  State<PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends State<PersonRow> {
  double _offset = 0;
  bool _dragging = false;

  bool get _canSwipe => !widget.user.isCurrentUser;

  void _close() {
    if (_offset == 0) return;
    setState(() {
      _dragging = false;
      _offset = 0;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_canSwipe) return;
    setState(() {
      _dragging = true;
      _offset = (_offset + details.delta.dx).clamp(-_kSwipeActionsWidth, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_canSwipe) return;
    final velocity = details.primaryVelocity ?? 0;
    final open = _offset < -_kSwipeActionsWidth / 2 || velocity < -400;
    setState(() {
      _dragging = false;
      _offset = open ? -_kSwipeActionsWidth : 0;
    });
  }

  void _handleTap() {
    if (_offset < 0) {
      _close();
      return;
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = widget.user.isCurrentUser
        ? l10n.commonYouSuffix(widget.user.name)
        : widget.user.name;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          UserAvatar(
            name: widget.user.name,
            colorIndex: widget.user.colorIndex,
            size: 44,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.onTap != null)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );

    if (!_canSwipe) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: content,
      );
    }

    final surface = theme.colorScheme.surface;

    return ClipRect(
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SwipeActionButton(
                  icon: Icons.edit_outlined,
                  tooltip: l10n.peopleEditName,
                  background: AppColors.primary.withValues(alpha: 0.12),
                  foreground: AppColors.primaryDark,
                  onPressed: () {
                    _close();
                    widget.onEdit();
                  },
                ),
                _SwipeActionButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l10n.commonDelete,
                  background: AppColors.negative.withValues(alpha: 0.12),
                  foreground: AppColors.negative,
                  onPressed: () {
                    _close();
                    widget.onDelete();
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedContainer(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_offset, 0, 0),
              color: surface,
              child: Material(
                color: surface,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _handleTap,
                  child: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.icon,
    required this.tooltip,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: _kSwipeActionsWidth / 2,
            child: Center(child: Icon(icon, color: foreground, size: 22)),
          ),
        ),
      ),
    );
  }
}

Future<String?> showPersonNameDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? initialValue,
}) {
  final l10n = context.l10n;
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (_) => Navigator.pop(ctx, controller.text.trim()),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> editPerson(
  BuildContext context,
  WidgetRef ref,
  User person,
) async {
  final l10n = context.l10n;
  final name = await showPersonNameDialog(
    context,
    title: l10n.peopleEditName,
    hint: person.name,
    initialValue: person.name,
  );
  if (name == null || name.isEmpty || name == person.name || !context.mounted) {
    return;
  }
  try {
    await updateUserName(ref.read(databaseProvider), person.id, name);
  } on UserNameTakenException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
    }
  }
}

/// Shows confirm dialog and deletes. Returns `true` if the user was deleted.
Future<bool> deletePerson(
  BuildContext context,
  WidgetRef ref,
  User person,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.l10n.peopleDeleteTitle),
      content: Text(ctx.l10n.peopleDeleteBody(person.name)),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctx.l10n.commonCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ctx.l10n.commonDelete),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  try {
    await deleteUser(ref.read(databaseProvider), person.id);
    return true;
  } on UserDeleteBlockedException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizeError(context, e))));
    }
    return false;
  }
}
