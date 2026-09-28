import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';

const _uuid = Uuid();

Future<String> createSettlement(
  AppDatabase db, {
  required String groupId,
  required String fromUserId,
  required String toUserId,
  required int amountCents,
  String? note,
  DateTime? date,
  DateTime? createdAt,
}) async {
  final id = _uuid.v4();
  final settlementDate = date ?? createdAt ?? DateTime.now();
  await db
      .into(db.settlements)
      .insert(
        SettlementsCompanion.insert(
          id: id,
          groupId: groupId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          amountCents: amountCents,
          note: Value(note),
          date: Value(settlementDate),
          createdAt: createdAt != null
              ? Value(createdAt)
              : const Value.absent(),
        ),
      );
  return id;
}

Future<void> updateSettlement(
  AppDatabase db, {
  required String settlementId,
  required String fromUserId,
  required String toUserId,
  required int amountCents,
  String? note,
  DateTime? date,
}) async {
  await (db.update(
    db.settlements,
  )..where((s) => s.id.equals(settlementId))).write(
    SettlementsCompanion(
      fromUserId: Value(fromUserId),
      toUserId: Value(toUserId),
      amountCents: Value(amountCents),
      note: Value(note),
      date: date != null ? Value(date) : const Value.absent(),
    ),
  );
}

Future<void> deleteSettlement(AppDatabase db, String settlementId) async {
  await (db.delete(
    db.settlements,
  )..where((s) => s.id.equals(settlementId))).go();
}
