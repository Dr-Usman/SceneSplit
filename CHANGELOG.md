# Changelog

All notable changes to SceneSplit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Bottom navigation via MainTabsScreen: Scenes, Balances, Profile.
- Balances tab: Whom POV hero with per-currency owed / owe totals across scenes and people, plus counterparty breakdown on tap.
- Balances tab: cross-scene who-owes-whom list with Whom defaulting to You, optional Who filter, Clear for all open debts, and pair drill-down with per-currency / per-scene totals and settle.
- Balances hero: when Who and Whom are both set and both directions are open, show Net inside the hero card footer (“{debtor} owes {creditor}” + colored amount).
- Startup bootstrap screen shows the SceneSplit logo (on a small brand-dark pad) above the spinner so the wordmark stays readable in light and dark mode.

### Fixed

- Pair balance scene cards: wrap “View shares” ListTile in Material so ink/splash isn’t hidden under AppCard (removes Flutter assertion).

### Changed

- Balances hero: show for Who and/or Whom; Who-only or Whom-only = that person’s full get/owe POV; both = pair-only totals; neither = hide hero. Totals are pair-scoped when Who is set, full Whom POV when Who is empty. Surface card with teal (owed) / red (owe) amounts and multi-currency on one line (`Rs · $`).
- Balances Who → Whom filter: compact chip (surface when empty, light teal when selected; 22px avatars, single-line names, Anyone empty state); sheet has title/hint, larger Who/Whom avatar slots with name under avatar and per-slot clear (×), soft teal/purple tints, Clear + Show results; filter opens only via the chip. Current user shows as “{name} (you)”.
- Balances list: one card per person-pair (avatar + name → owes → avatar + name) with multi-currency open-debt amounts, You’re owed / You owe badges (teal / red), dashed scene divider, and scene labels; currency codes shown when multiple currencies are open.
- Balances person picker: drag handle, title + Clear selection row, search, and separator (aligned with currency picker).
- Balances copy: subtitle and filter hint explain filtering open debts by who owes whom.
- Home: move New scene from FAB to AppBar + so the scene list isn’t covered; Scenes tab uses a home icon.
- Scene detail: show recent settlements and expenses with a footer See all link to full list screens.
- Expense/settlement list screens use “{scene} · Expenses/Settlements” titles.
- Scene detail: settlement rows use card layout aligned with expenses (icon, date/note, amount).
- Settled balance hero uses the normal surface card (white / dark surface) instead of a green wash.
- Person detail: header and scene net labels use “total debt” / “total credit” instead of “will give” / “gets”.

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
