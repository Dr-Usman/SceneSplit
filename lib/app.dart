import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'providers/database_provider.dart';

class SceneSplitApp extends ConsumerWidget {
  const SceneSplitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'SceneSplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: currentUser.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Something went wrong: $e')),
        ),
        data: (user) =>
            user == null ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
