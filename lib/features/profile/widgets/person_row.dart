import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../database/app_database.dart';
import '../../../shared/widgets/user_avatar.dart';

class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          UserAvatar(name: user.name, colorIndex: user.colorIndex, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.isCurrentUser ? l10n.commonYouSuffix(user.name) : user.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          if (!user.isCurrentUser)
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit();
                } else if (action == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.peopleEditName)),
                PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete)),
              ],
            ),
        ],
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
