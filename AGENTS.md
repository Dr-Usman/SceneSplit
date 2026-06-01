# AGENTS.md - SceneSplit

## Critical: Dependency Versions

**Do NOT upgrade to latest versions.** Flutter SDK pins `meta` to 1.17.0. Latest `drift_dev` (>=2.32.1) and `riverpod_generator` (>=4.0.1) require newer `meta`/`analyzer` versions.

Current compatible versions:
- `flutter_riverpod: ^2.6.1`
- `riverpod_annotation: ^2.6.1`
- `riverpod_generator: ^2.6.2`
- `drift: ^2.22.1`
- `drift_dev: ^2.22.1`
- `build_runner: ^2.5.4`

## Commands

```bash
# Install dependencies
flutter pub get

# Generate code (required after table/provider changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Analyze
flutter analyze

# Run
flutter run
```

## Code Generation

11 generated `.g.dart` files:
- `lib/database/app_database.g.dart`
- `lib/database/daos/{users,groups,expenses,settlements}_dao.g.dart`
- `lib/providers/{user,group,expense,settlement,dashboard,add_expense}_provider.g.dart`

After any Drift table, DAO, or `@riverpod` annotation change, re-run build_runner.

## Architecture

Feature-first + service/repository:
- `lib/database/` - Drift tables, DAOs, AppDatabase
- `lib/models/` - Data models (plain Dart classes, not Drift entities)
- `lib/repositories/` - Abstracts DAO access
- `lib/services/` - Business logic (SplitEngineService, BalanceService, SettlementService)
- `lib/providers/` - Riverpod providers
- `lib/features/` - UI screens by feature
- `lib/shared/widgets/` - Reusable widgets

## Conventions

- All primary keys are UUIDs (not auto-increment)
- Models include `isSynced` and `updatedAt` fields for future backend sync
- Drift Companions: `DateTime` fields must be wrapped in `Value()`
- DAO insert methods return `Future<int>` (not `Future<String>`)
- `withCheck` constraints are not supported in this Drift version
- No freezed or json_serializable in use
