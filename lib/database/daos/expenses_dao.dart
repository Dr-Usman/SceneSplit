import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'expenses_dao.g.dart';

@DriftAccessor(tables: [Expenses, ExpenseSplits, Users])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.attachedDatabase);

  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  Stream<List<Expense>> watchExpensesByGroup(String groupId) =>
      (select(expenses)..where((e) => e.groupId.equals(groupId))).watch();

  Future<List<Expense>> getExpensesByGroup(String groupId) =>
      (select(expenses)..where((e) => e.groupId.equals(groupId))).get();

  Future<Expense?> getExpenseById(String id) =>
      (select(expenses)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry, mode: InsertMode.insertOrReplace);

  Future<bool> updateExpense(ExpensesCompanion entry) =>
      update(expenses).replace(entry);

  Future<int> deleteExpense(String id) async {
    // Delete splits first
    await (delete(expenseSplits)..where((s) => s.expenseId.equals(id))).go();
    // Then delete expense
    return (delete(expenses)..where((e) => e.id.equals(id))).go();
  }

  // Expense Splits
  Stream<List<ExpenseSplit>> watchExpenseSplits(String expenseId) =>
      (select(expenseSplits)
            ..where((s) => s.expenseId.equals(expenseId))
            ..orderBy([(s) => OrderingTerm.asc(s.userId)]))
          .watch();

  Future<List<ExpenseSplit>> getExpenseSplits(String expenseId) =>
      (select(expenseSplits)
            ..where((s) => s.expenseId.equals(expenseId))
            ..orderBy([(s) => OrderingTerm.asc(s.userId)]))
          .get();

  Stream<List<ExpenseSplit>> watchAllSplits() => select(expenseSplits).watch();

  Future<List<ExpenseSplit>> getAllSplits() => select(expenseSplits).get();

  Future<void> insertSplit(ExpenseSplitsCompanion entry) =>
      into(expenseSplits).insert(entry, mode: InsertMode.insertOrReplace);

  Future<void> insertSplits(List<ExpenseSplitsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(expenseSplits, entries, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> deleteExpenseSplits(String expenseId) async {
    await (delete(
      expenseSplits,
    )..where((s) => s.expenseId.equals(expenseId))).go();
  }
}
