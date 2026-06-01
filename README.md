# SceneSplit

A production-grade Flutter expense splitting app inspired by Splitwise. Split expenses with friends, track balances, and settle up easily.

## Features

- **User Management**: Create and manage multiple user profiles
- **Groups**: Create groups (Trip, Home, Friends, Custom) and add members
- **Expense Tracking**: Add expenses with flexible splitting options
- **Split Types**: Equal, Exact, and Percentage splits
- **Selective Participants**: Choose specific group members for each expense
- **Balance Calculation**: Real-time balance tracking between users
- **Settlement Suggestions**: Optimized settlement recommendations using greedy algorithm
- **Offline-First**: Everything stored locally with Drift (SQLite)
- **Future-Ready**: Sync flags and UUID support for backend integration

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.41.7 |
| State Management | Riverpod v2.6 with codegen |
| Database | Drift 2.22 (SQLite) |
| Architecture | Feature-first + Service/Repository |
| Routing | GoRouter (prepared) |
| UUID | uuid package |

## Prerequisites

- Flutter SDK >= 3.41.0
- Dart SDK >= 3.11.0
- Android Studio / VS Code
- Xcode (for iOS development on macOS)

## Getting Started

### 1. Clone the Repository

```bash
cd /Users/usman/Development/Projects/Others
git clone <repository-url> scene_split
cd scene_split
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Drift + Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or for continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Run the App

```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For macOS
flutter run -d macos

# For Chrome (Web)
flutter run -d chrome
```

## Project Structure

```
scene_split/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── app.dart                           # MaterialApp configuration
│   │
│   ├── core/                              # Core utilities
│   │   ├── enums/                         # App enumerations
│   │   │   ├── split_type.dart            # Equal, Exact, Percentage
│   │   │   ├── group_type.dart            # Trip, Home, Friends, Custom
│   │   │   └── sync_status.dart           # Synced, Pending, Conflict
│   │   │
│   │   ├── constants/                     # App constants
│   │   ├── extensions/                    # Dart extensions
│   │   ├── theme/                         # App theme configuration
│   │   └── utils/                         # Utility functions
│   │
│   ├── database/                          # Database layer
│   │   ├── app_database.dart              # Main database class
│   │   ├── app_database.g.dart           # Generated database code
│   │   ├── tables/                        # Drift table definitions
│   │   │   ├── users_table.dart
│   │   │   ├── groups_table.dart
│   │   │   ├── group_members_table.dart
│   │   │   ├── expenses_table.dart
│   │   │   ├── expense_splits_table.dart
│   │   │   └── settlements_table.dart
│   │   └── daos/                          # Data Access Objects
│   │       ├── users_dao.dart
│   │       ├── groups_dao.dart
│   │       ├── expenses_dao.dart
│   │       └── settlements_dao.dart
│   │
│   ├── models/                            # Data models
│   │   ├── user_model.dart
│   │   ├── group_model.dart
│   │   ├── expense_model.dart
│   │   ├── expense_split_model.dart
│   │   ├── settlement_model.dart
│   │   ├── balance_model.dart
│   │   ├── settlement_suggestion.dart
│   │   └── dashboard_data_model.dart
│   │
│   ├── repositories/                      # Data access abstraction
│   │   ├── user_repository.dart
│   │   ├── group_repository.dart
│   │   ├── expense_repository.dart
│   │   └── settlement_repository.dart
│   │
│   ├── services/                          # Business logic
│   │   ├── split_engine_service.dart      # Split calculations
│   │   ├── balance_service.dart           # Balance calculations
│   │   └── settlement_service.dart        # Settlement suggestions
│   │
│   ├── providers/                         # Riverpod state management
│   │   ├── database_provider.dart         # Database & DAO providers
│   │   ├── user_provider.dart
│   │   ├── group_provider.dart
│   │   ├── expense_provider.dart
│   │   ├── settlement_provider.dart
│   │   ├── dashboard_provider.dart
│   │   └── add_expense_provider.dart      # Form state management
│   │
│   ├── features/                          # UI screens by feature
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── groups/
│   │   │   ├── groups_screen.dart
│   │   │   ├── create_group_screen.dart
│   │   │   └── group_detail_screen.dart
│   │   ├── expenses/
│   │   │   ├── expenses_screen.dart
│   │   │   └── add_expense_screen.dart
│   │   ├── settlements/
│   │   │   └── settlements_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── shared/widgets/                    # Reusable UI components
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── avatar_widget.dart
│       ├── loading_indicator.dart
│       ├── empty_state.dart
│       └── balance_card.dart
│
├── test/                                  # Test files
├── pubspec.yaml                           # Dependencies
├── build.yaml                             # Build runner configuration
└── analysis_options.yaml                  # Lint rules
```

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                           │
│   (Features/Screens) - ConsumerWidget, ConsumerState    │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   State Layer                           │
│          (Riverpod Providers) - Notifiers               │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                 Repository Layer                        │
│         (Data Access Abstraction)                       │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                  Service Layer                          │
│       (Business Logic) - SplitEngine, Balance           │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                 Database Layer                          │
│        (Drift) - Tables, DAOs, Queries                  │
└─────────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **UUID for all IDs**: Ensures global uniqueness for future backend sync
2. **is_synced flag**: Tracks which records need syncing
3. **updated_at timestamp**: Enables conflict resolution
4. **Drift over sqflite**: Type-safe queries, reactive streams, better migrations
5. **Riverpod with codegen**: Cleaner provider definitions, better IDE support
6. **Feature-first architecture**: Organized by feature, not by layer
7. **Service layer**: Encapsulates business logic (split calculation, balance computation)
8. **Repository layer**: Abstracts data access, enables future API integration

## Database Schema

### Tables

#### Users
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| name | TEXT | User name |
| email | TEXT (nullable) | User email |
| avatar_url | TEXT (nullable) | Profile image URL |
| is_synced | BOOLEAN | Sync status |
| created_at | DATETIME | Creation timestamp |
| updated_at | DATETIME | Last update timestamp |

#### Groups
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| name | TEXT | Group name |
| description | TEXT (nullable) | Group description |
| type | TEXT | trip, home, friends, custom |
| avatar_url | TEXT (nullable) | Group image URL |
| is_synced | BOOLEAN | Sync status |
| created_at | DATETIME | Creation timestamp |
| updated_at | DATETIME | Last update timestamp |

#### GroupMembers (Pivot)
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| group_id | TEXT (FK) | References groups.id |
| user_id | TEXT (FK) | References users.id |
| joined_at | DATETIME | Join timestamp |

#### Expenses
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| description | TEXT | Expense description |
| amount | REAL | Total amount |
| currency | TEXT | Currency code (default: USD) |
| paid_by | TEXT (FK) | References users.id |
| group_id | TEXT (FK, nullable) | References groups.id |
| split_type | TEXT | equal, exact, percentage |
| date | DATETIME | Expense date |
| is_synced | BOOLEAN | Sync status |
| created_at | DATETIME | Creation timestamp |
| updated_at | DATETIME | Last update timestamp |

#### ExpenseSplits (Pivot)
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| expense_id | TEXT (FK) | References expenses.id |
| user_id | TEXT (FK) | References users.id |
| amount | REAL | Split amount |
| percentage | REAL (nullable) | For percentage splits |
| is_synced | BOOLEAN | Sync status |
| created_at | DATETIME | Creation timestamp |

#### Settlements
| Column | Type | Description |
|--------|------|-------------|
| id | TEXT (PK) | UUID |
| from_user | TEXT (FK) | Payer user ID |
| to_user | TEXT (FK) | Receiver user ID |
| amount | REAL | Settlement amount |
| group_id | TEXT (FK, nullable) | References groups.id |
| expense_id | TEXT (FK, nullable) | References expenses.id |
| note | TEXT (nullable) | Settlement note |
| date | DATETIME | Settlement date |
| is_synced | BOOLEAN | Sync status |
| created_at | DATETIME | Creation timestamp |

## Split Engine Algorithm

### Equal Split
```dart
share = totalAmount / numberOfParticipants
```

### Exact Split
Each participant pays a specific amount (must sum to total).

### Percentage Split
```dart
participantAmount = totalAmount * (percentage / 100)
```

### Settlement Optimization (Greedy Algorithm)

1. Calculate net balances for each user
2. Separate into debtors (negative balance) and creditors (positive balance)
3. Sort debtors by most negative, creditors by most positive
4. Match largest debtor with largest creditor
5. Settle the minimum of the two amounts
6. Repeat until all debts are settled

## Commands Reference

### Development

```bash
# Install dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run with specific device
flutter run -d <device-id>

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (full restart)
# Press 'R' in terminal
```

### Code Generation

```bash
# Generate code once
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch --delete-conflicting-outputs

# Clean build cache
dart run build_runner clean
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Building

```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Build macOS
flutter build macos

# Build Web
flutter build web
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check formatting (CI)
dart format --output=none --set-exit-if-changed .
```

## Features in Detail

### 1. Dashboard
- Overall balance summary (owed vs owing)
- Suggested settlements
- Recent activity

### 2. Groups
- Create groups with different types (Trip, Home, Friends, Custom)
- Add/remove members
- View group balances

### 3. Expenses
- Add expenses with description, amount, payer
- Select participants via checkboxes
- Choose split type (Equal, Exact, Percentage)
- View expense history

### 4. Settlements
- Record payments between users
- View settlement history
- Optimized settlement suggestions

## Future Enhancements

- [ ] Backend integration with REST API
- [ ] Real-time sync with Firebase/WebSocket
- [ ] Receipt scanning with ML Kit OCR
- [ ] Multi-currency support with exchange rates
- [ ] Push notifications
- [ ] PDF/CSV export
- [ ] Expense categories
- [ ] Recurring expenses
- [ ] User authentication

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [Drift](https://drift.simonbinder.eu/)
- [Splitwise](https://www.splitwise.com/) - Inspiration for the app
