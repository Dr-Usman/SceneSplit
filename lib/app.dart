import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'core/constants/app_assets.dart';
import 'core/constants/app_links.dart';
import 'core/l10n/l10n_extensions.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_link_launcher.dart';
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
        error: (e, _) => _BootstrapErrorScreen(
          error: e,
          onRetry: () {
            ref.invalidate(databaseProvider);
            ref.invalidate(currentUserProvider);
          },
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Image(
                image: AssetImage(AppAssets.logoFor(context)),
                width: 88,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 90,
              child: LinearProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorScreen extends StatefulWidget {
  const _BootstrapErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  State<_BootstrapErrorScreen> createState() => _BootstrapErrorScreenState();
}

class _BootstrapErrorScreenState extends State<_BootstrapErrorScreen> {
  bool _showDetails = false;

  void _copyError(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.error.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.errorScreenCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactSupport() {
    launchEmail(
      subject: 'SceneSplit Error Report',
      body:
          'Hi SceneSplit Team,\n\nI encountered the following startup error:\n\n${widget.error}\n',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand logo with subtle elevation
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.08,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppAssets.logoFor(context),
                    width: 68,
                    height: 68,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Error title
                Text(
                  l10n.errorScreenTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  l10n.errorScreenSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle error details button
                TextButton.icon(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  icon: Icon(
                    _showDetails
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _showDetails ? 'Hide details' : 'View error details',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),

                if (_showDetails) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black45 : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        '${widget.error}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _copyError(context),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(l10n.errorScreenCopyDetails),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Primary Action: Try again
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      l10n.errorScreenRetry,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Action: Contact Support & Feedback
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _contactSupport,
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: Text(
                      l10n.errorScreenContact,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
