# Changelog

All notable changes to SceneSplit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Debug-only demo data seeder (`lib/dev/demo_seed.dart`) with Profile “Load demo data” and optional `--dart-define=SEED_DEMO=true` for empty databases.
- Mixpanel product analytics with typed `AnalyticsService` events (`app_opened`, `sign_up_completed`, `group_created`, `expense_created`, `language_changed`) and local-user identify (id + name); `locale_code` on People / super properties.

### Changed

- Privacy Policy updated to disclose Mixpanel product analytics.


## [1.3.0] - 2026-07-31

### Added

- App localization (Flutter gen-l10n) for English, Spanish, French, German, Portuguese (Brazil), Hindi, Arabic, and Japanese, with a Profile language override (or follow the device).
- Share app action (Profile and About) via `share_plus` with localized pitch plus Play Store / web links.
- Multi-payer expenses: a bill can be paid by more than one person (equal or exact amounts), with balances credited from each payer.
- Shared member select tiles on Add expense for Paid by and Split.
- Case-insensitive duplicate name prevention when adding or renaming people.
- Responsive desktop layout for onboarding on web.
- App download links and refreshed README screenshots; project LICENSE.
- Manual `workflow_dispatch` triggers on release workflows; iOS release job restored for manual runs.
- Deploy tagged web releases to GitHub Pages.

### Changed

- Expense schema migrates from single `paidById` to an `ExpensePayers` table (schema v3).
- App settings schema v4 adds persisted `localeCode`.
- Money formatting/parsing is locale-aware via `intl`.
- Section headers use title case with a short accent and optional subtitles.
- Standardized GitHub Release asset names and refreshed web favicons / PWA icons.
- Moved CI and release contributor notes into `CONTRIBUTING.md`.

## [1.2.0] - 2026-07-15

### Added

- Appearance setting for system, light, or dark theme (persisted and applied before first frame).
- Expense total on group detail, editable settlements, and category breakdown pie chart.
- Web builds with Drift WASM assets; backup UI gated appropriately on web.

### Changed

- Profile screen split into dedicated section widgets.
- macOS uses Swift Package Manager only (CocoaPods removed).
- GitHub Releases and annotated tags now publish notes from `CHANGELOG.md`.

### Fixed

- Cold-start loader no longer flashes the light theme when dark mode is selected.

## [1.1.0] - 2026-07-10

### Added

- Database backup export and import.
- In-app legal screens for privacy policy and terms of service.
- Live validation for exact and percentage expense splits.
- Profile settings hub with dedicated People, Data & backup, and About screens.

### Changed

- Polished currency picker and settled balance card.
- Reorganized profile into hub-and-spoke navigation with app version footer.

### Fixed

- Long expense notes no longer overlap on the expense detail screen.
- Paid-by tiles on add expense now use theme-aware colors in dark mode.

## [1.0.0] - 2026-07-08

### Added

- Initial release: group expense splitting, balances, settlements, and offline storage.
