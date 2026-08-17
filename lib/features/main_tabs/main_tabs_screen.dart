import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/main_tabs_provider.dart';
import '../balances/balances_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

/// Root screen after onboarding: hosts the bottom navigation bar and its tabs
/// (Scenes / Balances / Profile).
class MainTabsScreen extends ConsumerWidget {
  const MainTabsScreen({super.key});

  static String _tabName(int index) => switch (index) {
    kMainTabBalances => 'balances',
    kMainTabProfile => 'profile',
    _ => 'scenes',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final index = ref.watch(mainTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [HomeScreen(), BalancesScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index) return;
          ref.read(mainTabIndexProvider.notifier).setIndex(i);
          ref.read(analyticsServiceProvider).trackTabSelected(tab: _tabName(i));
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navScenes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: l10n.navBalances,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
