import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/group_emojis.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';

bool isValidSingleEmoji(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  return trimmed.characters.length == 1;
}

Future<String?> showCustomEmojiDialog(BuildContext context, {String? initial}) {
  final l10n = context.l10n;
  final controller = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.sharedCustomEmoji),
      content: TextField(
        controller: controller,
        autofocus: true,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32),
        decoration: const InputDecoration(hintText: '😀', counterText: ''),
        inputFormatters: [LengthLimitingTextInputFormatter(8)],
        onSubmitted: (_) {
          final value = controller.text.trim();
          if (isValidSingleEmoji(value)) Navigator.pop(ctx, value);
        },
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
                onPressed: () {
                  final value = controller.text.trim();
                  if (isValidSingleEmoji(value)) {
                    Navigator.pop(ctx, value);
                  }
                },
                child: Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class GroupEmojiPicker extends StatelessWidget {
  const GroupEmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onChanged,
  });

  final String selectedEmoji;
  final ValueChanged<String> onChanged;

  bool get _isCustomSelected => !groupEmojis.contains(selectedEmoji);

  Future<void> _pickCustom(BuildContext context) async {
    final emoji = await showCustomEmojiDialog(
      context,
      initial: _isCustomSelected ? selectedEmoji : null,
    );
    if (emoji != null) onChanged(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final emoji in groupEmojis)
          _EmojiChip(
            emoji: emoji,
            selected: emoji == selectedEmoji,
            onTap: () => onChanged(emoji),
          ),
        _CustomEmojiChip(
          emoji: _isCustomSelected ? selectedEmoji : null,
          selected: _isCustomSelected,
          onTap: () => _pickCustom(context),
        ),
      ],
    );
  }
}

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySoft
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _CustomEmojiChip extends StatelessWidget {
  const _CustomEmojiChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySoft
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: emoji != null
            ? Text(emoji!, style: const TextStyle(fontSize: 22))
            : const Text(
                '···',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}
