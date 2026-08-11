import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-nav index for [MainTabsScreen]: 0 Scenes, 1 Balances, 2 Profile.
class MainTabIndex extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final mainTabIndexProvider = NotifierProvider<MainTabIndex, int>(
  MainTabIndex.new,
);

const kMainTabScenes = 0;
const kMainTabBalances = 1;
const kMainTabProfile = 2;
