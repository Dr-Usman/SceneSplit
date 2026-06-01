import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/settlements_dao.dart';
import '../models/settlement_model.dart';

class SettlementRepository {
  final SettlementsDao _settlementsDao;
  static const _uuid = Uuid();

  SettlementRepository(this._settlementsDao);

  Stream<List<SettlementModel>> watchAllSettlements() {
    return _settlementsDao.watchAllSettlements().map(
      (rows) => rows.map((row) => SettlementModel.fromRow(row)).toList(),
    );
  }

  Stream<List<SettlementModel>> watchSettlementsByGroup(String groupId) {
    return _settlementsDao
        .watchSettlementsByGroup(groupId)
        .map(
          (rows) => rows.map((row) => SettlementModel.fromRow(row)).toList(),
        );
  }

  Future<List<SettlementModel>> getAllSettlements() async {
    final rows = await _settlementsDao.getAllSettlements();
    return rows.map((row) => SettlementModel.fromRow(row)).toList();
  }

  Future<SettlementModel> createSettlement({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? groupId,
    String? expenseId,
    String? note,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final settlement = SettlementsCompanion.insert(
      id: id,
      fromUser: fromUserId,
      toUser: toUserId,
      amount: amount,
      groupId: Value(groupId),
      expenseId: Value(expenseId),
      note: Value(note),
      date: Value(now),
      createdAt: Value(now),
    );

    await _settlementsDao.insertSettlement(settlement);
    final createdSettlement = await _settlementsDao.getSettlementById(id);
    return SettlementModel.fromRow(createdSettlement!);
  }

  Future<void> deleteSettlement(String id) async {
    await _settlementsDao.deleteSettlement(id);
  }
}
