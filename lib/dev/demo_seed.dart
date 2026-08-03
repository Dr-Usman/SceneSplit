import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../repositories/expense_repository.dart';
import '../repositories/group_repository.dart';
import '../repositories/settlement_repository.dart';
import '../repositories/user_repository.dart';
import '../services/split_engine_service.dart';

/// Compile-time flag: `flutter run --dart-define=SEED_DEMO=true`
const seedDemoFromEnvironment = bool.fromEnvironment(
  'SEED_DEMO',
  defaultValue: false,
);

/// Whether demo seeding is allowed (debug builds, or explicit define).
bool get isDemoSeedAllowed => kDebugMode || seedDemoFromEnvironment;

/// Populates a screenshot-friendly demo dataset (PKR).
///
/// Safe to call when a current user already exists; skips if any groups exist
/// unless [force] is true (force still refuses when groups exist — wipe the
/// DB / reinstall first for a clean seed).
Future<DemoSeedResult> seedDemoData(
  AppDatabase db, {
  bool force = false,
}) async {
  if (!isDemoSeedAllowed) {
    return DemoSeedResult.blocked;
  }

  final existingGroups = await db.select(db.groups).get();
  if (existingGroups.isNotEmpty && !force) {
    return DemoSeedResult.alreadySeeded;
  }
  if (existingGroups.isNotEmpty && force) {
    // Avoid duplicating demo data on top of real groups.
    return DemoSeedResult.alreadySeeded;
  }

  var alexId =
      (await (db.select(db.users)
                ..where((u) => u.isCurrentUser.equals(true))
                ..limit(1))
              .getSingleOrNull())
          ?.id;

  if (alexId == null) {
    alexId = await completeOnboarding(db, name: 'Alex', currencyCode: 'PKR');
  } else {
    await updateCurrency(db, 'PKR');
  }

  final samId = await createUser(db, 'Sam');
  final jordanId = await createUser(db, 'Jordan');
  final caseyId = await createUser(db, 'Casey');

  final now = DateTime.now();
  DateTime daysAgo(int d) => now.subtract(Duration(days: d));

  // ── Apartment (Alex, Sam, Jordan) ─────────────────────────────────────
  final apartmentId = await createGroup(
    db,
    name: 'Apartment',
    emoji: '🏠',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, jordanId],
    newMemberNames: const [],
  );
  final apartmentMembers = [alexId, samId, jordanId];

  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Rent',
    amountCents: 4500000, // Rs 45,000
    payersCents: {alexId: 4500000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(4500000, apartmentMembers),
    date: daysAgo(20),
  );
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Groceries',
    amountCents: 875000, // Rs 8,750
    payersCents: {alexId: 875000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(875000, apartmentMembers),
    date: daysAgo(12),
  );
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Utilities',
    amountCents: 420000, // Rs 4,200
    payersCents: {samId: 420000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(420000, apartmentMembers),
    date: daysAgo(8),
  );
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Internet',
    amountCents: 350000, // Rs 3,500
    payersCents: {alexId: 350000},
    splitType: 'exact',
    splitsCents: {
      alexId: 175000,
      samId: 175000,
      // Jordan not on internet this month
    },
    date: daysAgo(5),
  );

  // Partial settlement so settlements list isn't empty.
  await createSettlement(
    db,
    groupId: apartmentId,
    fromUserId: samId,
    toUserId: alexId,
    amountCents: 500000, // Rs 5,000
    note: 'Partial rent share',
  );

  // ── Tokyo Trip (all four) ─────────────────────────────────────────────
  final tripId = await createGroup(
    db,
    name: 'Tokyo Trip',
    emoji: '✈️',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, jordanId, caseyId],
    newMemberNames: const [],
  );
  final tripMembers = [alexId, samId, jordanId, caseyId];

  await createExpense(
    db,
    groupId: tripId,
    title: 'Flights',
    amountCents: 18000000, // Rs 180,000
    payersCents: {alexId: 18000000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(18000000, tripMembers),
    date: daysAgo(18),
  );
  await createExpense(
    db,
    groupId: tripId,
    title: 'Hotel',
    amountCents: 9600000, // Rs 96,000
    payersCents: {samId: 9600000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(9600000, tripMembers),
    date: daysAgo(14),
  );
  await createExpense(
    db,
    groupId: tripId,
    title: 'Dinner in Shibuya',
    amountCents: 1250000, // Rs 12,500
    payersCents: {jordanId: 1250000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(1250000, tripMembers),
    date: daysAgo(10),
  );
  await createExpense(
    db,
    groupId: tripId,
    title: 'Uber & trains',
    amountCents: 480000, // Rs 4,800
    payersCents: {caseyId: 480000},
    splitType: 'exact',
    splitsCents: {
      alexId: 120000,
      samId: 120000,
      jordanId: 120000,
      caseyId: 120000,
    },
    date: daysAgo(9),
  );

  // ── Movie Night (Alex, Sam, Casey) ────────────────────────────────────
  final movieId = await createGroup(
    db,
    name: 'Movie Night',
    emoji: '🎬',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, caseyId],
    newMemberNames: const [],
  );
  final movieMembers = [alexId, samId, caseyId];

  await createExpense(
    db,
    groupId: movieId,
    title: 'Tickets',
    amountCents: 360000, // Rs 3,600
    payersCents: {alexId: 360000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(360000, movieMembers),
    date: daysAgo(3),
  );
  await createExpense(
    db,
    groupId: movieId,
    title: 'Snacks',
    amountCents: 180000, // Rs 1,800
    payersCents: {samId: 180000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(180000, movieMembers),
    date: daysAgo(3),
  );
  await createExpense(
    db,
    groupId: movieId,
    title: 'Dinner after',
    amountCents: 900000, // Rs 9,000 — Casey paid so Alex owes overall here
    payersCents: {caseyId: 900000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(900000, movieMembers),
    date: daysAgo(2),
  );

  return DemoSeedResult.seeded;
}

enum DemoSeedResult { seeded, alreadySeeded, blocked }
