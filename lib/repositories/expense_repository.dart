import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _uuid = Uuid();

Future<String> createExpense(
  AppDatabase db, {
  required String groupId,
  required String title,
  required int amountCents,
  required String paidById,
  required String splitType,
  required Map<String, int> splitsCents,
  String? note,
  DateTime? date,
}) async {
  final expenseId = _uuid.v4();
  final expenseDate = date ?? DateTime.now();

  await db.transaction(() async {
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
          id: expenseId,
          groupId: groupId,
          title: title,
          amountCents: amountCents,
          paidById: paidById,
          splitType: Value(splitType),
          note: Value(note),
          date: Value(expenseDate),
        ));

    for (final entry in splitsCents.entries) {
      await db.into(db.expenseSplits).insert(ExpenseSplitsCompanion.insert(
            id: _uuid.v4(),
            expenseId: expenseId,
            userId: entry.key,
            amountCents: entry.value,
          ));
    }
  });

  return expenseId;
}

Future<void> deleteExpense(AppDatabase db, String expenseId) async {
  await db.transaction(() async {
    await (db.delete(db.expenseSplits)
          ..where((s) => s.expenseId.equals(expenseId)))
        .go();
    await (db.delete(db.expenses)..where((e) => e.id.equals(expenseId))).go();
  });
}

Future<void> updateExpense(
  AppDatabase db, {
  required String expenseId,
  required String title,
  required int amountCents,
  required String paidById,
  required String splitType,
  required Map<String, int> splitsCents,
  String? note,
  DateTime? date,
}) async {
  await db.transaction(() async {
    await (db.update(db.expenses)..where((e) => e.id.equals(expenseId))).write(
      ExpensesCompanion(
        title: Value(title),
        amountCents: Value(amountCents),
        paidById: Value(paidById),
        splitType: Value(splitType),
        note: Value(note),
        date: date != null ? Value(date) : const Value.absent(),
      ),
    );
    await (db.delete(db.expenseSplits)
          ..where((s) => s.expenseId.equals(expenseId)))
        .go();
    for (final entry in splitsCents.entries) {
      await db.into(db.expenseSplits).insert(ExpenseSplitsCompanion.insert(
            id: _uuid.v4(),
            expenseId: expenseId,
            userId: entry.key,
            amountCents: entry.value,
          ));
    }
  });
}
