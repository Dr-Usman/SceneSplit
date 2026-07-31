import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'providers/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read saved theme/locale before first frame so startup matches preference.
  ThemeMode? initialThemeMode;
  Locale? initialLocale;
  try {
    final bootstrapDb = AppDatabase();
    final settings = await (bootstrapDb.select(
      bootstrapDb.appSettings,
    )..limit(1)).getSingleOrNull();
    initialThemeMode = themeModeFromStorage(settings?.themeMode);
    initialLocale = localeFromStorage(settings?.localeCode);
    await bootstrapDb.close();
  } catch (e) {
    log('Error while loading saved settings: $e');
  }

  runApp(
    ProviderScope(
      child: SceneSplitApp(
        initialThemeMode: initialThemeMode,
        initialLocale: initialLocale,
      ),
    ),
  );
}
