import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dev/demo_seed.dart';
import 'database_provider.dart';

/// Auto-seeds when launched with `--dart-define=SEED_DEMO=true` and DB is empty.
final demoSeedBootstrapProvider = FutureProvider<DemoSeedResult?>((ref) async {
  if (!seedDemoFromEnvironment || !isDemoSeedAllowed) return null;
  final db = ref.watch(databaseProvider);
  return seedDemoData(db);
});
