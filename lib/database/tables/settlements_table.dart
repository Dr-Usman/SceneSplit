import 'package:drift/drift.dart';
import 'users_table.dart';
import 'groups_table.dart';
import 'expenses_table.dart';

class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get fromUser => text().references(Users, #id)();
  TextColumn get toUser => text().references(Users, #id)();
  RealColumn get amount => real()();
  TextColumn get groupId => text().nullable().references(Groups, #id)();
  TextColumn get expenseId => text().nullable().references(Expenses, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
