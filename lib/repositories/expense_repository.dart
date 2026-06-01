import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/enums/split_type.dart';
import '../database/app_database.dart';
import '../database/daos/expenses_dao.dart';
import '../models/expense_model.dart';
import '../models/expense_split_model.dart';

class ExpenseRepository {
  final ExpensesDao _expensesDao;
  static const _uuid = Uuid();

  ExpenseRepository(this._expensesDao);

  Stream<List<ExpenseModel>> watchAllExpenses() {
    return _expensesDao.watchAllExpenses().map(
      (rows) => rows.map((row) => ExpenseModel.fromRow(row)).toList(),
    );
  }

  Stream<List<ExpenseModel>> watchExpensesByGroup(String groupId) {
    return _expensesDao
        .watchExpensesByGroup(groupId)
        .map((rows) => rows.map((row) => ExpenseModel.fromRow(row)).toList());
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final rows = await _expensesDao.getAllExpenses();
    return rows.map((row) => ExpenseModel.fromRow(row)).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final row = await _expensesDao.getExpenseById(id);
    if (row == null) return null;
    final splits = await _expensesDao.getExpenseSplits(id);
    return ExpenseModel.fromRow(
      row,
      splits: splits.map((s) => ExpenseSplitModel.fromRow(s)).toList(),
    );
  }

  Future<ExpenseModel> createExpense({
    required String description,
    required double amount,
    required String paidBy,
    String? groupId,
    required SplitType splitType,
    required List<ExpenseSplitModel> splits,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final expense = ExpensesCompanion.insert(
      id: id,
      description: description,
      amount: amount,
      paidBy: paidBy,
      groupId: Value(groupId),
      splitType: Value(splitType.name),
      date: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _expensesDao.insertExpense(expense);

    // Insert splits
    for (final split in splits) {
      final splitCompanion = ExpenseSplitsCompanion.insert(
        id: _uuid.v4(),
        expenseId: id,
        userId: split.userId,
        amount: split.amount,
        percentage: Value(split.percentage),
        createdAt: Value(now),
      );
      await _expensesDao.insertSplit(splitCompanion);
    }

    final createdExpense = await _expensesDao.getExpenseById(id);
    final createdSplits = await _expensesDao.getExpenseSplits(id);
    return ExpenseModel.fromRow(
      createdExpense!,
      splits: createdSplits.map((s) => ExpenseSplitModel.fromRow(s)).toList(),
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final companion = ExpensesCompanion(
      id: Value(expense.id),
      description: Value(expense.description),
      amount: Value(expense.amount),
      currency: Value(expense.currency),
      paidBy: Value(expense.paidBy),
      groupId: Value(expense.groupId),
      splitType: Value(expense.splitType.name),
      date: Value(expense.date),
      isSynced: Value(expense.isSynced),
      createdAt: Value(expense.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _expensesDao.updateExpense(companion);
  }

  Future<void> deleteExpense(String id) async {
    await _expensesDao.deleteExpense(id);
  }

  Future<List<ExpenseSplitModel>> getExpenseSplits(String expenseId) async {
    final rows = await _expensesDao.getExpenseSplits(expenseId);
    return rows.map((row) => ExpenseSplitModel.fromRow(row)).toList();
  }

  Future<List<ExpenseSplitModel>> getAllSplits() async {
    final rows = await _expensesDao.getAllSplits();
    return rows.map((row) => ExpenseSplitModel.fromRow(row)).toList();
  }

  Stream<List<ExpenseSplitModel>> watchAllSplits() {
    return _expensesDao.watchAllSplits().map(
      (rows) => rows.map((row) => ExpenseSplitModel.fromRow(row)).toList(),
    );
  }
}
