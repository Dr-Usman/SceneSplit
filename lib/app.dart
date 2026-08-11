import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/constants/app_assets.dart';
import 'core/constants/app_links.dart';
import 'core/l10n/l10n_extensions.dart';
import 'core/theme/app_theme.dart';
import 'features/main_tabs/main_tabs_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/analytics_provider.dart';
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
    ref.watch(analyticsBootstrapProvider);
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
        loading: () => const _BootstrapLoadingScreen(),
        error: (e, _) => Scaffold(
          body: Center(
            child: Builder(
              builder: (context) =>
                  Text(context.l10n.commonSomethingWentWrong('$e')),
            ),
          ),
        ),
        data: (user) =>
            user == null ? const OnboardingScreen() : const MainTabsScreen(),
      ),
    );
  }
}

/// Full-screen gate while [currentUserProvider] resolves.
///
/// Scaffold follows the app theme; only the logo sits on a small brand-dark
/// pad so the white wordmark stays readable in light and dark mode.
class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.logoBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Image(
                  image: AssetImage(AppAssets.logo),
                  width: 88,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
