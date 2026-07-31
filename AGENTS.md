# AGENTS.md - SceneSplit

## Dependency Versions

**SDK:** Dart `^3.12.2` (Flutter 3.44.5 stable)

### Direct dependencies

| Package | Constraint | Notes |
|---------|------------|-------|
| flutter_riverpod | ^3.3.2 | Manual providers in `lib/providers/` |
| riverpod_annotation | ^4.0.3 | Listed for future codegen; not used in `lib/` yet |
| drift | ^2.34.1 | SQLite via drift_flutter |
| drift_flutter | ^0.3.0 | Uses sqlite3 3.x |
| path_provider | ^2.1.6 | |
| uuid | ^4.5.3 | |
| go_router | ^17.3.0 | Listed but navigation still uses `MaterialApp` |
| google_fonts | ^8.1.0 | |
| flutter_svg | ^2.3.0 | |
| fl_chart | ^1.2.0 | |
| intl | ^0.20.2 | Pinned by `flutter_localizations` |
| flutter_localizations | sdk | Official gen-l10n |
| cupertino_icons | ^1.0.9 | |
| collection | ^1.19.1 | |
| package_info_plus | ^10.2.0 | |
| url_launcher | ^6.3.2 | |
| in_app_review | ^2.0.12 | |

### Dev dependencies

| Package | Constraint | Notes |
|---------|------------|-------|
| flutter_lints | ^6.0.0 | |
| drift_dev | ^2.34.0 | **Pin at 2.34.0** — see conflict below |
| build_runner | ^2.15.1 | |
| riverpod_generator | ^4.0.4 | Listed for future codegen; not used in `lib/` yet |

### Upgrade constraints

**Do not bump `drift_dev` to `^2.34.2+1` while `riverpod_generator ^4.0.4` is present.**

- `riverpod_generator 4.0.4` requires `analyzer ^12.0.0`
- `drift_dev >=2.34.1+1` requires `analyzer ^13.0.0`

Pub resolves `drift_dev` at `2.34.0` today. Revisit when `riverpod_generator` supports `analyzer ^13`, or remove `riverpod_generator` if codegen is not needed.

When upgrading other packages: run `flutter pub outdated`, bump constraints in `pubspec.yaml`, then `flutter pub get` and `dart run build_runner build`.

## Commands

```bash
# Install dependencies
flutter pub get

# Generate code (required after Drift table/schema changes only)
dart run build_runner build

# Format
dart format lib test

# Analyze
flutter analyze

# Test
flutter test

# Run
flutter run
```

## Pull requests

Before creating or updating a PR:

1. Run `dart format lib test` and `flutter analyze` (fix any issues; leave no format drift).
2. Run relevant tests (`flutter test` at minimum when logic changed).
3. Update [`CHANGELOG.md`](CHANGELOG.md) under `## [Unreleased]` when the change is user-facing or otherwise notable (features, fixes, behavior changes). Skip pure internal refactors with no user/ops impact. Use Keep a Changelog sections: Added / Changed / Fixed / Removed.
4. Do not open the PR until the above are clean.

## Code Generation

Generated files:
- `lib/database/app_database.g.dart` — Drift
- `lib/l10n/app_localizations*.dart` — Flutter gen-l10n from `lib/l10n/*.arb`

Re-run `dart run build_runner build` only after changes to `lib/database/tables.dart` or `@DriftDatabase` annotations.
ARB changes regenerate via `flutter gen-l10n` (also runs automatically on `flutter pub get` / build when `flutter: generate: true`).

## Localization

- Stack: Flutter **gen-l10n** + ARB in `lib/l10n/` (`l10n.yaml`). Access via `context.l10n` (`lib/core/l10n/l10n_extensions.dart`).
- Supported locales: `en`, `es`, `fr`, `de`, `pt`/`pt_BR`, `hi`, `ar`, `ja`.
- User preference: `AppSettings.localeCode` (`system` or BCP-47); Profile → Language. `null` MaterialApp locale follows the device.
- Never hardcode user-facing English in UI — add keys to `app_en.arb` first, then translate sibling ARBs (same key set).
- Domain exceptions stay typed (`UserNameTakenException`, etc.); map to copy with `localizeError(context, e)`.
- Legal markdown in `assets/legal/` remains English; screen chrome (titles/errors) is localized.
- Money: `formatCents(cents, currencyCode, {locale})` / `parseAmountToCents(input, {locale})`.

## Architecture

Feature-first + service/repository:
- `lib/database/` — Drift tables (`tables.dart`), `AppDatabase` (no DAO layer)
- `lib/repositories/` — Direct Drift access (`user_repository`, `group_repository`, etc.)
- `lib/services/` — Business logic (`SplitEngineService`, `BalanceService`)
- `lib/providers/` — Riverpod 3 manual providers (`StreamProvider`, `Provider`, `Provider.family`)
- `lib/features/` — UI screens by feature
- `lib/shared/widgets/` — Reusable widgets (`user_avatar`, `currency_picker_sheet`)
- `lib/l10n/` — ARB sources + generated `AppLocalizations`

## Conventions

- All primary keys are UUIDs (not auto-increment)
- Money stored as integer cents (`amountCents`); format with `formatCents(cents, currencyCode, locale: …)`
- Drift Companions: optional/nullable fields use `Value()` or `Value.absent()`
- `withCheck` constraints are not supported in this Drift version
- No freezed, json_serializable, or `@riverpod` codegen in `lib/` today

## Users and currency

- **Users** are a global pool (`Users` table). Created at onboarding, via Profile “Add person”, or when adding members to a group.
- **Group members** are a join table (`GroupMembers`). Removing a member from a group does not delete the user row.
- **Delete user** — blocked if `isCurrentUser` or user has any expenses/splits/settlements.
- **Remove member from group** — blocked if user has financial activity in that group.
- **App default currency** (`AppSettings.currencyCode`) — set in onboarding/profile; used for home summary and as default when creating groups.
- **Group currency** (`Groups.currencyCode`) — set at group creation, editable in edit group; all amounts in group detail use this code.
- **App language** (`AppSettings.localeCode`) — `system` or BCP-47; set in Profile.
