import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/providers/database_provider.dart';
import 'package:scene_split/repositories/group_repository.dart';
import 'package:scene_split/repositories/settlement_repository.dart';
import 'package:scene_split/repositories/user_repository.dart';

void main() {
  late AppDatabase db;
  late String groupId;
  late String userAId;
  late String userBId;
  late String userCId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    userAId = await completeOnboarding(db, name: 'Alice', currencyCode: 'USD');
    userBId = await createUser(db, 'Bob');
    userCId = await createUser(db, 'Charlie');

    groupId = await createGroup(
      db,
      name: 'Trip',
      emoji: '✈️',
      currencyCode: 'USD',
      existingUserIds: [userAId, userBId, userCId],
      newMemberNames: const [],
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SettlementRepository', () {
    test('creates settlement with explicit date and retrieves it', () async {
      final customDate = DateTime(2026, 5, 15, 14, 30);

      final settlementId = await createSettlement(
        db,
        groupId: groupId,
        fromUserId: userBId,
        toUserId: userAId,
        amountCents: 5000,
        note: 'Half hotel share',
        date: customDate,
      );

      final settlements = await db.select(db.settlements).get();
      expect(settlements.length, 1);

      final item = settlements.first;
      expect(item.id, settlementId);
      expect(item.groupId, groupId);
      expect(item.fromUserId, userBId);
      expect(item.toUserId, userAId);
      expect(item.amountCents, 5000);
      expect(item.note, 'Half hotel share');
      expect(item.date, customDate);
    });

    test('defaults settlement date to now when omitted', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));

      final id = await createSettlement(
        db,
        groupId: groupId,
        fromUserId: userCId,
        toUserId: userBId,
        amountCents: 2500,
      );

      final after = DateTime.now().add(const Duration(seconds: 1));
      final item = await (db.select(
        db.settlements,
      )..where((s) => s.id.equals(id))).getSingle();

      expect(item.date.isAfter(before), isTrue);
      expect(item.date.isBefore(after), isTrue);
    });

    test('updates settlement date, amount, note, and recipient', () async {
      final initialDate = DateTime(2026, 4, 1);
      final settlementId = await createSettlement(
        db,
        groupId: groupId,
        fromUserId: userBId,
        toUserId: userAId,
        amountCents: 3000,
        note: 'Old note',
        date: initialDate,
      );

      final updatedDate = DateTime(2026, 4, 10, 18, 0);
      await updateSettlement(
        db,
        settlementId: settlementId,
        fromUserId: userBId,
        toUserId: userCId,
        amountCents: 4500,
        note: 'Corrected to Charlie and updated date',
        date: updatedDate,
      );

      final updated = await (db.select(
        db.settlements,
      )..where((s) => s.id.equals(settlementId))).getSingle();
      expect(updated.toUserId, userCId);
      expect(updated.amountCents, 4500);
      expect(updated.note, 'Corrected to Charlie and updated date');
      expect(updated.date, updatedDate);
    });

    test('deleting a settlement removes it permanently', () async {
      final id = await createSettlement(
        db,
        groupId: groupId,
        fromUserId: userBId,
        toUserId: userAId,
        amountCents: 1200,
      );

      expect((await db.select(db.settlements).get()).length, 1);

      await deleteSettlement(db, id);

      expect((await db.select(db.settlements).get()).isEmpty, isTrue);
    });
  });
}
