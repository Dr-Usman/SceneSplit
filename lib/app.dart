import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/constants/app_links.dart';
import 'core/l10n/l10n_extensions.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/database_provider.dart';
import 'providers/demo_seed_provider.dart';

class SceneSplitApp extends ConsumerWidget {
  const SceneSplitApp({super.key, this.initialThemeMode, this.initialLocale});

  /// Synced from DB in [main] before first paint; used until stream emits.
  final ThemeMode? initialThemeMode;

  /// Synced from DB in [main]; `null` means follow the device locale.
  final Locale? initialLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(demoSeedBootstrapProvider);
    final currentUser = ref.watch(currentUserProvider);
    final themeAsync = ref.watch(themeModeProvider);
    final themeMode = themeAsync.value ?? initialThemeMode ?? ThemeMode.system;
    final localeAsync = ref.watch(localeCodeProvider);
    final locale = localeAsync.hasValue
        ? localeFromStorage(localeAsync.value)
        : initialLocale;

    if (locale != null) {
      Intl.defaultLocale = locale.toString();
    }

    return MaterialApp(
      title: AppLinks.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: currentUser.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(
          body: Center(
            child: Builder(
              builder: (context) =>
                  Text(context.l10n.commonSomethingWentWrong('$e')),
            ),
          ),
        ),
        data: (user) =>
            user == null ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
