# SceneSplit

A production-grade Flutter expense splitting app inspired by Splitwise. Split expenses with friends, track balances, and settle up easily.

## Features

- **People management**: Add, rename, and delete people from Profile; manage group members when creating or editing a group
- **Groups**: Create groups with emoji icons, per-group currency, and members
- **Expense tracking**: Add expenses with flexible splitting (equal, exact, percentage)
- **Selective participants**: Choose specific group members for each expense
- **Balance calculation**: Real-time balance tracking between users
- **Settlement suggestions**: Optimized settlement recommendations using a greedy algorithm
- **Currency**: App-wide default for home summary and new groups; each group has its own currency (visible and editable in group detail / edit group)
- **Offline-first**: Everything stored locally with Drift (SQLite)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.41+ |
| State Management | Riverpod 2.6 |
| Database | Drift 2.22 (SQLite) |
| Architecture | Feature-first + Service/Repository |
| UUID | uuid package |

## Prerequisites

- Flutter SDK >= 3.41.0
- Dart SDK >= 3.11.0

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only after schema changes
flutter run
```

## Project Structure

```
lib/
├── main.dart / app.dart
├── core/
│   ├── constants/     # currencies, group emojis
│   ├── theme/
│   └── utils/         # money formatting
├── database/
│   ├── tables.dart    # Users, AppSettings, Groups, GroupMembers, Expenses, etc.
│   ├── app_database.dart
│   └── app_database.g.dart
├── repositories/      # user, group, expense, settlement
├── services/          # split engine, balance
├── providers/         # Riverpod streams and derived state
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── groups/        # create, edit, detail
│   ├── expenses/
│   ├── settlements/
│   └── profile/       # name, default currency, people CRUD
└── shared/widgets/    # user_avatar, currency_picker_sheet
```

## Database Schema

All money amounts are stored as **integer cents**.

| Table | Purpose |
|-------|---------|
| `Users` | Global people pool (`id`, `name`, `colorIndex`, `isCurrentUser`) |
| `AppSettings` | Single row: app default `currencyCode` |
| `Groups` | Group name, emoji, `currencyCode` |
| `GroupMembers` | Group ↔ user membership |
| `Expenses` | Group expenses (`amountCents`, `paidById`, `splitType`) |
| `ExpenseSplits` | Per-user split amounts |
| `Settlements` | Recorded payments between members |

## Commands

```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Future Enhancements

- Backend sync
- Multi-currency with exchange rates
- Receipt scanning
- Export (PDF/CSV)

## License

MIT

## CI/CD

GitHub Actions workflows live in [`.github/workflows/`](.github/workflows/).

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | PR and push to `main` | Format check, analyze, Drift codegen check, tests |
| `release-android.yml` | Tag `v*` | Signed split APKs attached to GitHub Release |
| `release-ios.yml` | Tag `v*` | Signed IPA attached to GitHub Release |
| `release-macos.yml` | Tag `v*` | macOS `.app` zip |
| `release-web.yml` | Tag `v*` | Web bundle zip |
| `release-linux.yml` | Tag `v*` | Linux x64 tar.gz |
| `release-windows.yml` | Tag `v*` | Windows x64 zip |

### Releasing

#### Pre-release checklist

Run the same checks as CI before bumping the version or creating the release commit:

```bash
# 1. Format all Dart files
dart format .

# 2. Static analysis (CI uses --fatal-infos)
flutter analyze --fatal-infos

# 3. Regenerate Drift code and confirm nothing changed
dart run build_runner build --delete-conflicting-outputs
git diff --exit-code lib/database/app_database.g.dart

# 4. Run tests
flutter test
```

Fix any failures before continuing. A quick one-liner that mirrors CI (except codegen diff):

```bash
dart format . && flutter analyze --fatal-infos && flutter test
```

#### Release steps

1. Complete the [pre-release checklist](#pre-release-checklist) above.
2. Bump `version` in `pubspec.yaml` (e.g. `1.0.1+2` — increment the build number after `+`).
3. Update [`CHANGELOG.md`](CHANGELOG.md) (move items from `[Unreleased]` into the new version section).
4. Commit, tag, and push:

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release v1.0.1"
git tag v1.0.1
git push origin main
git push origin v1.0.1
```

The tag must match the semver portion of `pubspec.yaml` (`v1.0.1` → `1.0.1+2`). Workflows upload platform artifacts to the GitHub Release. Build the Play Store AAB locally when needed:

```bash
flutter build appbundle --release
```

### Required GitHub Secrets

**Android** (split APK releases):

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded upload keystore (`.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | Key alias |

**iOS** (IPA releases):

| Secret | Description |
|--------|-------------|
| `IOS_CERTIFICATE_BASE64` | Distribution `.p12` (base64) |
| `IOS_CERTIFICATE_PASSWORD` | P12 password |
| `IOS_PROVISIONING_PROFILE_BASE64` | App Store provisioning profile (base64) |
| `KEYCHAIN_PASSWORD` | Temporary keychain password for CI |

Local Android signing: create `android/key.properties` and place `upload-keystore.jks` in `android/` (both gitignored).

### Branch protection

On GitHub, go to **Settings → Branches → Add branch protection rule** for `main`:

1. Enable **Require a pull request before merging** (recommended).
2. Enable **Require status checks to pass before merging**.
3. Search for and select the **CI** / `analyze-and-test` check from `ci.yml`.
4. Enable **Require branches to be up to date before merging** (recommended).

This blocks merges until `flutter analyze`, formatting, codegen, and tests pass.
