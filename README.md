# SceneSplit

<p style="text-align: center;">
  <img src="assets/images/logo.png" alt="SceneSplit logo" width="160" />
</p>

**Split shared expenses by scene, track who owes what, and settle up — fully offline.**

SceneSplit is a Flutter expense-splitting app for trips, roommates, dinners, and events. No account, no cloud — everything stays on your device.

**[Try the live demo](https://dr-usman.github.io/SceneSplit/)**

## Download

Get SceneSplit from Google Play, or download the latest builds for all
supported platforms from GitHub Releases.

<p>
  <a href="https://play.google.com/store/apps/details?id=com.avenzor.scenesplit">
    <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get SceneSplit on Google Play" height="80" />
  </a>
  <a href="https://github.com/Dr-Usman/SceneSplit/releases/latest">
    <img src="https://raw.githubusercontent.com/rubenpgrady/get-it-on-github/refs/heads/main/get-it-on-github.png" alt="Get SceneSplit on GitHub" height="80" />
  </a>
</p>

## Screenshots

| Home (light) | Home (dark) |
|:---:|:---:|
| <img src="docs/screenshots/home-light.jpg" alt="Home dashboard (light)" width="220" /> | <img src="docs/screenshots/home-dark.jpg" alt="Home dashboard (dark)" width="220" /> |
| **Scene detail** | **Pending summary** |
| <img src="docs/screenshots/group-detail.jpg" alt="Scene detail with balances and donut chart" width="220" /> | <img src="docs/screenshots/pending-summary.jpg" alt="Home pending summary sheet" width="220" /> |

Play Store feature graphic, device captures, and phone mockups: see [`store/play/README.md`](store/play/README.md) (binaries are local / gitignored).

## Features

- **People & scenes** — Global people pool from Profile; create scenes (trips, dinners, shared activities) with emoji icons and members
- **Person detail** — Per-person balances across scenes, per-currency will-give / gets, who-owes-whom, expense shares, and settle
- **Flexible splits** — Equal, exact amounts, or percentage, with live validation; choose who is included per expense
- **Multi-payer bills** — An expense can be paid by one or more people (equal or exact amounts)
- **Balances & settlements** — Live balances; who-owes-whom follows shared expenses (A↔B offsets); editable settlement records
- **Share balances** — Export Who Owes Whom (plus expense share totals) as an image for WhatsApp and other apps
- **Insights** — Scene expense breakdown pie; tap a member to see which expenses make up their share
- **Currency** — App-wide default for home summary and new scenes; each scene has its own currency; locale-aware formatting
- **Language** — English, Spanish, French, German, Portuguese (Brazil), Hindi, Arabic, and Japanese (system or Profile override)
- **Appearance** — System, light, or dark theme (saved and applied before first frame)
- **Backup** — Export and import a local database backup (non-web platforms)
- **Share app** — Localized pitch with store / web links from Profile and About
- **Legal & about** — In-app privacy policy, terms of service, and app version
- **Offline-first** — All data stored locally with Drift (SQLite); no sign-in required

See [`CHANGELOG.md`](CHANGELOG.md) for release history.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.44 / Dart 3.12 |
| State management | Riverpod 3 |
| Database | Drift 2.34 (SQLite) |
| Localization | Flutter gen-l10n |
| Architecture | Feature-first + service / repository |
| Charts | fl_chart |
| Analytics | Mixpanel (`AnalyticsService`) |
| Navigation | Material navigation (`go_router` listed for future use) |

## Prerequisites

- Flutter SDK (3.44.5 stable or compatible)
- Dart SDK `^3.12.2`

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only after schema changes
flutter run
```

Optional demo data (debug / empty DB): Profile → Load demo data, or:

```bash
flutter run --dart-define=SEED_DEMO=true
```

## Project Structure

```
lib/
├── main.dart / app.dart
├── core/
│   ├── constants/     # currencies, scene emojis, assets, links
│   ├── l10n/          # context.l10n helpers, error localization
│   ├── theme/
│   └── utils/         # money formatting, share balance image
├── database/
│   ├── tables.dart
│   ├── app_database.dart
│   └── app_database.g.dart
├── l10n/              # ARB sources + generated AppLocalizations
├── repositories/      # user, group, expense, settlement
├── services/          # split engine, balance, analytics, backup
├── providers/         # Riverpod streams and derived state
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── groups/        # create, edit, scene detail (UI: “scenes”)
│   ├── expenses/
│   ├── settlements/
│   ├── profile/       # people, person detail, language, data & backup
│   ├── legal/
│   └── about/
├── shared/widgets/
└── dev/               # debug demo seeder
```

## Database Schema

All money amounts are stored as **integer cents**. Table names still use `Groups` internally; the UI calls them **scenes**.

| Table | Purpose |
|-------|---------|
| `Users` | Global people pool (`id`, `name`, `colorIndex`, `isCurrentUser`) |
| `AppSettings` | Single row: `currencyCode`, `themeMode`, `localeCode` |
| `Groups` | Scene name, emoji, `currencyCode` |
| `GroupMembers` | Scene ↔ user membership |
| `Expenses` | Scene expenses (`amountCents`, `splitType`, note, date) |
| `ExpensePayers` | Who paid (one or more), with per-payer `amountCents` |
| `ExpenseSplits` | Per-user split amounts |
| `Settlements` | Recorded payments between members |

## Commands

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter run
```

See [`AGENTS.md`](AGENTS.md) for dependency pins, architecture conventions, and codegen notes.

## Future Enhancements

- Backend sync
- Multi-currency with exchange rates
- Receipt scanning
- Export (PDF / CSV)

## Contributing

CI, PR checks, releasing, and GitHub secrets are documented in [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

[MIT](LICENSE)
