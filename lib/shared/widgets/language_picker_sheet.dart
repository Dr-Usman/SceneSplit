import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/database_provider.dart';

/// Locales offered in the language picker (plus System via storage `'system'`).
const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),
  Locale('pt', 'BR'),
  Locale('hi'),
  Locale('ar'),
  Locale('ja'),
];

String languageLabel(AppLocalizations l10n, String storageCode) {
  return switch (storageCode) {
    'system' => l10n.profileLanguageSystem,
    'en' => l10n.languageEnglish,
    'es' => l10n.languageSpanish,
    'fr' => l10n.languageFrench,
    'de' => l10n.languageGerman,
    'pt_BR' => l10n.languagePortuguese,
    'hi' => l10n.languageHindi,
    'ar' => l10n.languageArabic,
    'ja' => l10n.languageJapanese,
    _ => storageCode,
  };
}

/// Locale → flag / globe emoji (no image assets).
/// English uses 🇺🇸 as the common app-picker convention.
String languageFlag(String storageCode) {
  return switch (storageCode) {
    'system' => '🌐',
    'en' => '🇺🇸',
    'es' => '🇪🇸',
    'fr' => '🇫🇷',
    'de' => '🇩🇪',
    'pt_BR' => '🇧🇷',
    'hi' => '🇮🇳',
    'ar' => '🇸🇦',
    'ja' => '🇯🇵',
    _ => '🌐',
  };
}

Future<String?> showLanguagePickerSheet(
  BuildContext context, {
  required String selected,
  String? title,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) => _LanguagePickerSheet(
          title: title,
          selected: selected,
          scrollController: scrollController,
        ),
      ),
    ),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({
    required this.title,
    required this.selected,
    required this.scrollController,
  });

  final String? title;
  final String selected;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final options = <String>[
      'system',
      ...supportedAppLocales.map(localeToStorage),
    ];

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title ?? l10n.sharedChooseLanguage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final code = options[index];
                return _LanguageTile(
                  storageCode: code,
                  label: languageLabel(l10n, code),
                  selected: code == selected,
                  onTap: () => Navigator.pop(context, code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.storageCode,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String storageCode;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primarySoft.withValues(alpha: isDark ? 0.22 : 1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? AppColors.primary : borderColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: isDark ? 0.5 : 1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    languageFlag(storageCode),
                    style: const TextStyle(fontSize: 22, height: 1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primaryDark
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.primary : borderColor,
                      width: selected ? 0 : 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguagePickerField extends StatelessWidget {
  const LanguagePickerField({
    super.key,
    required this.localeCode,
    required this.onChanged,
    this.sheetTitle,
  });

  final String localeCode;
  final ValueChanged<String> onChanged;
  final String? sheetTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showLanguagePickerSheet(
          context,
          selected: localeCode,
          title: sheetTitle ?? l10n.sharedChooseLanguage,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Row(
          children: [
            Text(
              languageFlag(localeCode),
              style: const TextStyle(fontSize: 20, height: 1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                languageLabel(l10n, localeCode),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
