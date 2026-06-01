import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'settlements_dao.g.dart';

@DriftAccessor(tables: [Settlements, Users])
class SettlementsDao extends DatabaseAccessor<AppDatabase>
    with _$SettlementsDaoMixin {
  SettlementsDao(super.attachedDatabase);

  Stream<List<Settlement>> watchAllSettlements() => select(settlements).watch();

  Future<List<Settlement>> getAllSettlements() => select(settlements).get();

  Stream<List<Settlement>> watchSettlementsByGroup(String groupId) =>
      (select(settlements)
            ..where((s) => s.groupId.equals(groupId))
            ..orderBy([(s) => OrderingTerm.desc(s.date)]))
          .watch();

  Future<List<Settlement>> getSettlementsByGroup(String groupId) =>
      (select(settlements)
            ..where((s) => s.groupId.equals(groupId))
            ..orderBy([(s) => OrderingTerm.desc(s.date)]))
          .get();

  Future<Settlement?> getSettlementById(String id) =>
      (select(settlements)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSettlement(SettlementsCompanion entry) =>
      into(settlements).insert(entry, mode: InsertMode.insertOrReplace);

  Future<bool> updateSettlement(SettlementsCompanion entry) =>
      update(settlements).replace(entry);

  Future<int> deleteSettlement(String id) =>
      (delete(settlements)..where((s) => s.id.equals(id))).go();
}
