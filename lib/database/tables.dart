import 'package:drift/drift.dart';

/// All money amounts are stored as integer cents to avoid
/// floating-point errors.

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isCurrentUser =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row app settings (row id is always 1).
class AppSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get currencyCode => text().withDefault(const Constant('PKR'))();

  /// Stored as `'system' | 'light' | 'dark'`.
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get emoji => text().withDefault(const Constant('🧾'))();
  TextColumn get currencyCode => text().withDefault(const Constant('PKR'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class GroupMembers extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get amountCents => integer()();
  TextColumn get paidById => text().references(Users, #id)();
  TextColumn get splitType => text().withDefault(const Constant('equal'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseSplits extends Table {
  TextColumn get id => text()();
  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get amountCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get fromUserId => text().references(Users, #id)();
  TextColumn get toUserId => text().references(Users, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
