import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/core/constants/group_emojis.dart';
import 'package:scene_split/core/theme/app_theme.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/shared/widgets/group_emoji_picker.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Emoji validation and categories', () {
    test('isValidSingleEmoji correctly validates single grapheme clusters', () {
      expect(isValidSingleEmoji('🍕'), isTrue);
      expect(isValidSingleEmoji('✈️'), isTrue);
      expect(isValidSingleEmoji('🏋️'), isTrue);
      expect(isValidSingleEmoji('  🍕  '), isTrue);

      expect(isValidSingleEmoji(''), isFalse);
      expect(isValidSingleEmoji('   '), isFalse);
      expect(isValidSingleEmoji('🍕🍕'), isFalse);
      expect(isValidSingleEmoji('abc'), isFalse);
      expect(isValidSingleEmoji('🍕a'), isFalse);
    });

    test('groupEmojis and emojiCategories are populated properly', () {
      expect(groupEmojis.isNotEmpty, isTrue);
      expect(emojiCategories.isNotEmpty, isTrue);

      for (final cat in emojiCategories) {
        expect(cat.name.isNotEmpty, isTrue);
        expect(cat.icon.isNotEmpty, isTrue);
        expect(cat.emojis.isNotEmpty, isTrue);
        for (final emoji in cat.emojis) {
          expect(isValidSingleEmoji(emoji), isTrue);
        }
      }
    });

    testWidgets('showEmojiPickerSheet renders and allows picking emoji', (
      tester,
    ) async {
      String? pickedEmoji;

      await tester.pumpWidget(
        _wrapWithApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                pickedEmoji = await showEmojiPickerSheet(
                  context,
                  selected: '🍕',
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Check bottom sheet components are rendered without exceptions
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('✨ All'), findsOneWidget);

      // Tap an emoji in the grid (e.g. 🍕)
      final emojiFinder = find.text('🍕');
      expect(emojiFinder, findsOneWidget);
      await tester.tap(emojiFinder);
      await tester.pumpAndSettle();

      // Ensure picker sheet dismissed and returned picked emoji
      expect(pickedEmoji, equals('🍕'));
    });
  });
}
