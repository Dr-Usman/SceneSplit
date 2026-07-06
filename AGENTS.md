# AGENTS.md - SceneSplit

## Critical: Dependency Versions

**Do NOT upgrade to latest versions.** Flutter SDK pins `meta` to 1.17.0. Latest `drift_dev` (>=2.32.1) and `riverpod_generator` (>=4.0.1) require newer `meta`/`analyzer` versions.

Current compatible versions:
- `flutter_riverpod: ^2.6.1`
- `drift: ^2.22.1`
- `drift_dev: ^2.22.1`
- `build_runner: ^2.5.4`

## Commands

```bash
# Install dependencies
flutter pub get

# Generate code (required after Drift table/schema changes only)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run
flutter run
```

## Code Generation

Generated file:
- `lib/database/app_database.g.dart`

Re-run `build_runner` only after changes to `lib/database/tables.dart` or `@DriftDatabase` annotations. Repository and UI changes do not require codegen.

## Architecture

Feature-first + service/repository:
- `lib/database/` — Drift tables (`tables.dart`), `AppDatabase` (no DAO layer)
- `lib/repositories/` — Direct Drift access (`user_repository`, `group_repository`, etc.)
- `lib/services/` — Business logic (`SplitEngineService`, `BalanceService`)
- `lib/providers/` — Riverpod providers (manual, no codegen)
- `lib/features/` — UI screens by feature
- `lib/shared/widgets/` — Reusable widgets (`user_avatar`, `currency_picker_sheet`)

## Conventions

- All primary keys are UUIDs (not auto-increment)
- Money stored as integer cents (`amountCents`); format with `formatCents(cents, currencyCode)`
- Drift Companions: optional/nullable fields use `Value()` or `Value.absent()`
- `withCheck` constraints are not supported in this Drift version
- No freezed, json_serializable, or riverpod_generator in use

## Users and currency

- **Users** are a global pool (`Users` table). Created at onboarding, via Profile “Add person”, or when adding members to a group.
- **Group members** are a join table (`GroupMembers`). Removing a member from a group does not delete the user row.
- **Delete user** — blocked if `isCurrentUser` or user has any expenses/splits/settlements.
- **Remove member from group** — blocked if user has financial activity in that group.
- **App default currency** (`AppSettings.currencyCode`) — set in onboarding/profile; used for home summary and as default when creating groups.
- **Group currency** (`Groups.currencyCode`) — set at group creation, editable in edit group; all amounts in group detail use this code.
