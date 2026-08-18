# Changelog

All notable changes to SceneSplit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Scene net card is a white single-row card; amount stays green or red; labels are “You get” / “You give”.

## [1.8.0] - 2026-08-17

### Added

- Mixpanel events for settlements, bottom-nav tabs, Balances pair/filter usage, person detail opens, app share, review prompts, and backup export/import.

### Changed

- Who-owes-whom (scene detail, Balances, person detail, share card) lists the fewest transfers that settle each scene, instead of bill-linked pairwise debts.

## [1.7.0] - 2026-08-11

### Added

- Bottom navigation: Scenes, Balances, and Profile tabs.
- Balances tab: cross-scene who-owes-whom with Whom defaulting to You, optional Who filter, Clear, and pair drill-down with per-currency / per-scene totals and settle.
- Balances hero: Whom/Who POV with per-currency owed / owe totals, counterparty breakdown on tap, and Net footer when both people are selected and both directions are open.
- Startup bootstrap screen shows the SceneSplit logo above the spinner (readable in light and dark mode).

### Fixed

- Pair balance “View shares” row: Material wrapper so ink/splash works under AppCard (removes Flutter assertion).
- AppCard always wraps content in Material so ListTile/ExpansionTile ink isn’t hidden under the card fill (fixes person detail scene cards).

### Changed

- Pair balance screen is a relationship view: both open directions between the people, scenes for either direction, and a Net footer only when both sides are open in the same currency.
- Balances filter: compact Who → Whom chip and sheet (Anyone empty state, “{name} (you)” for you, Clear + Show results).
- Balances list: one card per person-pair with You’re owed / You owe badges, dashed scene divider, and multi-currency totals.
- Home: New scene moved from FAB to AppBar +; Scenes tab uses a home icon.
- Scene detail: recent settlements and expenses with See all; settlement rows use the same card layout as expenses; settled hero uses a normal surface card.
- Expense/settlement list titles use “{scene} · Expenses/Settlements”.
- Person detail: “total debt” / “total credit” instead of “will give” / “gets”.

## [1.6.0] - 2026-08-07

### Added

- Scene detail: share Who Owes Whom as an image (with expense share totals) via the system share sheet for WhatsApp and similar apps.
- People → person detail: balances across scenes with per-scene currency, who-owes-whom, expense shares, and settle.
- Person detail header: per-currency will-give / gets totals (no cross-currency merge).

### Changed

- Privacy Policy and Terms: disclose optional balance image share, correct Mixpanel name/scene fields, and use “scenes” wording.
- Member share breakdown sheet: person header with avatar, top-only total summary, expense count/percent meta, and share-of-expense rows.
- People list: swipe left for edit/delete with a swipe hint; person detail app bar uses an overflow menu for edit/delete; clearer person header.
- Scene detail: swipe-to-delete hint under settlements and expenses.
- Who-owes-whom suggestions follow shared expenses (pay the people on your bills), with only A↔B offsets — not fewest-transfer matching across the group.
- Renamed user-facing “groups” to “scenes” (home, create/edit, empty states) so containers read as trips, dinners, and shared activities.

## [1.5.0] - 2026-08-05

### Added

- Tap a member in group expense breakdown to see which expenses make up their share.

### Changed

- Group expense breakdown pie: tapping a slice highlights that member (and legend row) with name and percent in the center.

## [1.4.0] - 2026-08-03

### Added

- Debug-only demo data seeder (`lib/dev/demo_seed.dart`) with Profile “Load demo data” and optional `--dart-define=SEED_DEMO=true` for empty databases.
- Play Store marketing assets under `store/play/` (feature graphic, light/dark screenshots, AI phone mockups).
- Mixpanel product analytics with typed `AnalyticsService` events (`app_opened`, `sign_up_completed`, `group_created`, `expense_created`, `language_changed`) and local-user identify (id + name); `locale_code` on People / super properties.

### Changed

- Privacy Policy updated to disclose Mixpanel product analytics.
- Letter-based currency symbols (e.g. Rs, CHF) format with a space before the amount; glyph symbols ($ €) stay tight.

### Fixed

- Home “You will get / You will give” summary halves stay equal height when one amount is much longer.

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
