import 'package:drift/drift.dart';
import 'users_table.dart';
import 'groups_table.dart';

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get paidBy => text().references(Users, #id)();
  TextColumn get groupId => text().nullable().references(Groups, #id)();
  TextColumn get splitType => text().withDefault(const Constant('equal'))();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
