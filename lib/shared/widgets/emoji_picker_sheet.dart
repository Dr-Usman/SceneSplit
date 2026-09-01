import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/group_emojis.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import 'group_emoji_picker.dart';

Future<String?> showEmojiPickerSheet(
  BuildContext context, {
  String? selected,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.78,
        child: SafeArea(
          top: false,
          child: _EmojiPickerSheet(selected: selected),
        ),
      ),
    ),
  );
}

class _EmojiPickerSheet extends StatefulWidget {
  const _EmojiPickerSheet({this.selected});

  final String? selected;

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  final _textController = TextEditingController();
  int _selectedCategoryIndex = 0; // 0 = All

  List<String> get _currentEmojis {
    if (_selectedCategoryIndex == 0) {
      return [for (final cat in emojiCategories) ...cat.emojis];
    }
    return emojiCategories[_selectedCategoryIndex - 1].emojis;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onDirectSubmit() {
    final value = _textController.text.trim();
    if (isValidSingleEmoji(value)) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final elevatedBg = isDark
        ? AppColors.surfaceDark
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
          child: Row(
            children: [
              Text(
                l10n.sharedCustomEmoji,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // Direct custom emoji input / paste field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _textController,
            builder: (context, val, _) {
              final valid = isValidSingleEmoji(val.text);
              final hasText = val.text.isNotEmpty;

              return Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _textController,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(8)],
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Type or paste any emoji…',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            height: 1.0,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 48,
                          ),
                          prefixIcon: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 48,
                          ),
                          suffixIcon: hasText
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () => _textController.clear(),
                                )
                              : null,
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: elevatedBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _onDirectSubmit(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    height: 48,
                    child: FilledButton(
                      onPressed: valid ? _onDirectSubmit : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(72, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Category Pills
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: emojiCategories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              final label = index == 0
                  ? '✨ All'
                  : '${emojiCategories[index - 1].icon} ${emojiCategories[index - 1].name}';

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : theme.colorScheme.onSurface,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: elevatedBg,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                onSelected: (_) {
                  setState(() => _selectedCategoryIndex = index);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Emojis Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _currentEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _currentEmojis[index];
              final isSelected = widget.selected == emoji;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).pop(emoji),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft.withValues(
                            alpha: isDark ? 0.35 : 0.6,
                          )
                        : elevatedBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
