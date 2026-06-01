import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/settlement_model.dart';
import 'database_provider.dart';

part 'settlement_provider.g.dart';

@riverpod
class SettlementList extends _$SettlementList {
  @override
  Stream<List<SettlementModel>> build() {
    return ref.watch(settlementRepositoryProvider).watchAllSettlements();
  }

  Future<void> addSettlement({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? groupId,
    String? expenseId,
    String? note,
  }) async {
    await ref
        .read(settlementRepositoryProvider)
        .createSettlement(
          fromUserId: fromUserId,
          toUserId: toUserId,
          amount: amount,
          groupId: groupId,
          expenseId: expenseId,
          note: note,
        );
  }

  Future<void> deleteSettlement(String id) async {
    await ref.read(settlementRepositoryProvider).deleteSettlement(id);
  }
}

@riverpod
class GroupSettlements extends _$GroupSettlements {
  @override
  Stream<List<SettlementModel>> build(String groupId) {
    return ref
        .watch(settlementRepositoryProvider)
        .watchSettlementsByGroup(groupId);
  }
}
