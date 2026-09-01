import 'package:flutter/material.dart';

import '../../core/constants/group_emojis.dart';
import '../../core/theme/app_theme.dart';
import 'emoji_picker_sheet.dart';

export 'emoji_picker_sheet.dart' show showEmojiPickerSheet;

bool isValidSingleEmoji(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  return trimmed.characters.length == 1;
}

Future<String?> showCustomEmojiDialog(BuildContext context, {String? initial}) {
  return showEmojiPickerSheet(context, selected: initial);
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
    final emoji = await showEmojiPickerSheet(
      context,
      selected: _isCustomSelected ? selectedEmoji : null,
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
