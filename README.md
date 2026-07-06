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
