import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/database_provider.dart';

class SceneSplitApp extends ConsumerWidget {
  const SceneSplitApp({super.key, this.initialThemeMode});

  /// Synced from DB in [main] before first paint; used until stream emits.
  final ThemeMode? initialThemeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeAsync = ref.watch(themeModeProvider);
    final themeMode = themeAsync.value ?? initialThemeMode ?? ThemeMode.system;

    return MaterialApp(
      title: 'SceneSplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: currentUser.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) =>
            Scaffold(body: Center(child: Text('Something went wrong: $e'))),
        data: (user) =>
            user == null ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
