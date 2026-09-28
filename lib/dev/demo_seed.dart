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

/// Populates a screenshot-friendly demo dataset (PKR) with rich transaction diversity.
///
/// Safe to call when a current user already exists; skips if any groups exist
/// unless [force] is true.
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
  final taylorId = await createUser(db, 'Taylor');

  final now = DateTime.now();
  DateTime daysAgo(int d, {int hour = 12, int minute = 0}) {
    final target = now.subtract(Duration(days: d));
    return DateTime(target.year, target.month, target.day, hour, minute);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. TOKYO TRIP (Alex, Sam, Jordan, Casey) — 16 Expenses, 5 Settlements
  // ═══════════════════════════════════════════════════════════════════════════
  final tripId = await createGroup(
    db,
    name: 'Tokyo Trip',
    emoji: '✈️',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, jordanId, caseyId],
    newMemberNames: const [],
  );
  final tripMembers = [alexId, samId, jordanId, caseyId];

  // 1. Flights — equal split 4 ways, high amount
  await createExpense(
    db,
    groupId: tripId,
    title: 'Roundtrip Flights to Tokyo',
    amountCents: 18000000, // Rs 180,000
    payersCents: {alexId: 18000000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(18000000, tripMembers),
    note: 'Economy return tickets via Qatar Airways',
    date: daysAgo(28, hour: 10, minute: 30),
  );

  // 2. Shibuya Sky Hotel — equal 4 ways
  await createExpense(
    db,
    groupId: tripId,
    title: 'Shibuya Sky Hotel (4 Nights)',
    amountCents: 9600000, // Rs 96,000
    payersCents: {samId: 9600000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(9600000, tripMembers),
    note: '2 deluxe twin rooms booked online',
    date: daysAgo(21, hour: 14, minute: 15),
  );

  // 3. Shinkansen Bullet Train — equal 4 ways
  await createExpense(
    db,
    groupId: tripId,
    title: 'Shinkansen Bullet Train Passes',
    amountCents: 4800000, // Rs 48,000
    payersCents: {jordanId: 4800000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(4800000, tripMembers),
    note: 'Tokyo to Kyoto roundtrip JR passes',
    date: daysAgo(18, hour: 9, minute: 0),
  );

  // 4. Tokyo Disneyland Passes — subset split (Alex, Sam, Casey)
  await createExpense(
    db,
    groupId: tripId,
    title: 'Tokyo Disneyland Passes',
    amountCents: 3600000, // Rs 36,000
    payersCents: {caseyId: 3600000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(3600000, [
      alexId,
      samId,
      caseyId,
    ]),
    note: 'Jordan opted for Akihabara shopping instead',
    date: daysAgo(15, hour: 8, minute: 45),
  );

  // 5. Sushi Omakase in Ginza — exact unequal split
  await createExpense(
    db,
    groupId: tripId,
    title: 'Sushi Omakase in Ginza',
    amountCents: 1965000, // Rs 19,650
    payersCents: {alexId: 1965000},
    splitType: 'exact',
    splitsCents: {
      alexId: 520000, // Rs 5,200 (sake + chef set)
      samId: 480000, // Rs 4,800 (standard set)
      jordanId: 415000, // Rs 4,150 (vegetarian rolls)
      caseyId: 550000, // Rs 5,500 (premium tuna set)
    },
    note: 'Counter seating dinner with drinks',
    date: daysAgo(12, hour: 20, minute: 0),
  );

  // 6. Izakaya & Craft Beer — equal 4 ways
  await createExpense(
    db,
    groupId: tripId,
    title: 'Izakaya Yakitori & Craft Beer',
    amountCents: 875000, // Rs 8,750
    payersCents: {samId: 875000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(875000, tripMembers),
    note: 'Late night skewers in Shinjuku Golden Gai',
    date: daysAgo(10, hour: 22, minute: 30),
  );

  // 7. Airbnb Lake Kawaguchi — multi-payer! (Alex Rs 45,000 + Jordan Rs 30,000)
  await createExpense(
    db,
    groupId: tripId,
    title: 'Airbnb Lake Kawaguchi Villa',
    amountCents: 7500000, // Rs 75,000
    payersCents: {
      alexId: 4500000, // Alex paid 45,000
      jordanId: 3000000, // Jordan paid 30,000
    },
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(7500000, tripMembers),
    note: 'Mount Fuji view traditional tatami house',
    date: daysAgo(8, hour: 15, minute: 0),
  );

  // 8. Mt. Fuji Sightseeing Tour & Ropeway — equal 4 ways
  await createExpense(
    db,
    groupId: tripId,
    title: 'Mt. Fuji Panoramic Ropeway',
    amountCents: 1420000, // Rs 14,200
    payersCents: {caseyId: 1420000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(1420000, tripMembers),
    note: 'Cable car tickets & lake cruise boat',
    date: daysAgo(7, hour: 11, minute: 30),
  );

  // 9. 7-Eleven Convenience Roadtrip Snacks — small amount
  await createExpense(
    db,
    groupId: tripId,
    title: '7-Eleven Snacks & Drinks',
    amountCents: 185000, // Rs 1,850
    payersCents: {samId: 185000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(185000, tripMembers),
    note: 'Onigiri, iced tea & chips for highway drive',
    date: daysAgo(5, hour: 16, minute: 45),
  );

  // 10. Team Tonkotsu Ramen — equal 4 ways
  await createExpense(
    db,
    groupId: tripId,
    title: 'Ichiran Tonkotsu Ramen',
    amountCents: 492000, // Rs 4,920
    payersCents: {alexId: 492000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(492000, tripMembers),
    note: 'Extra noodles and boiled eggs',
    date: daysAgo(4, hour: 19, minute: 15),
  );

  // 11. Matcha Sweets & Souvenirs — subset split (Alex, Sam, Jordan)
  await createExpense(
    db,
    groupId: tripId,
    title: 'Matcha Sweets & Souvenirs',
    amountCents: 640000, // Rs 6,400
    payersCents: {jordanId: 640000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(640000, [
      alexId,
      samId,
      jordanId,
    ]),
    note: 'Uji green tea boxes and mochi gifts',
    date: daysAgo(3, hour: 14, minute: 0),
  );

  // 12. Airport Express & Luggage Delivery
  await createExpense(
    db,
    groupId: tripId,
    title: 'Luggage Forwarding Service',
    amountCents: 560000, // Rs 5,600
    payersCents: {caseyId: 560000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(560000, tripMembers),
    note: 'Yamato Black Cat hotel-to-airport transport',
    date: daysAgo(2, hour: 10, minute: 0),
  );

  // 13. Morning Boba & Bakeries — 2 members (Alex, Casey)
  await createExpense(
    db,
    groupId: tripId,
    title: 'Morning Boba & French Pastries',
    amountCents: 145000, // Rs 1,450
    payersCents: {alexId: 145000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(145000, [alexId, caseyId]),
    note: 'Croissants and brown sugar milk tea',
    date: daysAgo(1, hour: 9, minute: 15),
  );

  // 14. Final Farewell Wagyu Dinner — today
  await createExpense(
    db,
    groupId: tripId,
    title: 'Final Farewell Wagyu Yakiniku',
    amountCents: 2280000, // Rs 22,800
    payersCents: {samId: 2280000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(2280000, tripMembers),
    note: 'A5 Wagyu beef celebration platter',
    date: daysAgo(0, hour: 13, minute: 0),
  );

  // 15. Taxi to Haneda Airport — today
  await createExpense(
    db,
    groupId: tripId,
    title: 'Jumbo Taxi to Haneda Airport',
    amountCents: 375000, // Rs 3,750
    payersCents: {alexId: 375000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(375000, tripMembers),
    note: 'Minivan taxi for 4 with luggage',
    date: daysAgo(0, hour: 15, minute: 30),
  );

  // 16. Duty Free Tokyo Bananas — today
  await createExpense(
    db,
    groupId: tripId,
    title: 'Duty Free Tokyo Banana Boxes',
    amountCents: 230000, // Rs 2,300
    payersCents: {jordanId: 230000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(230000, tripMembers),
    note: 'Shared snack gifts for family',
    date: daysAgo(0, hour: 16, minute: 45),
  );

  // Tokyo Trip Settlements (5 settlements with dates and notes)
  await createSettlement(
    db,
    groupId: tripId,
    fromUserId: samId,
    toUserId: alexId,
    amountCents: 2500000, // Rs 25,000
    note: 'Advance refund for flight booking',
    date: daysAgo(20, hour: 17, minute: 0),
    createdAt: daysAgo(20, hour: 17, minute: 0),
  );
  await createSettlement(
    db,
    groupId: tripId,
    fromUserId: caseyId,
    toUserId: samId,
    amountCents: 1500000, // Rs 15,000
    note: 'Hotel room share payback',
    date: daysAgo(14, hour: 12, minute: 0),
    createdAt: daysAgo(14, hour: 12, minute: 0),
  );
  await createSettlement(
    db,
    groupId: tripId,
    fromUserId: jordanId,
    toUserId: alexId,
    amountCents: 1000000, // Rs 10,000
    note: 'Omakase and Shinkansen partial payback',
    date: daysAgo(9, hour: 19, minute: 30),
    createdAt: daysAgo(9, hour: 19, minute: 30),
  );
  await createSettlement(
    db,
    groupId: tripId,
    fromUserId: caseyId,
    toUserId: alexId,
    amountCents: 800000, // Rs 8,000
    note: 'Mid-trip settlement via bank transfer',
    date: daysAgo(4, hour: 18, minute: 0),
    createdAt: daysAgo(4, hour: 18, minute: 0),
  );
  await createSettlement(
    db,
    groupId: tripId,
    fromUserId: samId,
    toUserId: caseyId,
    amountCents: 450000, // Rs 4,500
    note: 'Cash exchange payback at airport',
    date: daysAgo(0, hour: 16, minute: 0),
    createdAt: daysAgo(0, hour: 16, minute: 0),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. APARTMENT 4B (Alex, Sam, Jordan) — 11 Expenses, 3 Settlements
  // ═══════════════════════════════════════════════════════════════════════════
  final apartmentId = await createGroup(
    db,
    name: 'Apartment 4B',
    emoji: '🏠',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, jordanId],
    newMemberNames: const [],
  );
  final apartmentMembers = [alexId, samId, jordanId];

  // 1. Rent — 25 days ago
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Monthly Apartment Rent',
    amountCents: 4500000, // Rs 45,000
    payersCents: {alexId: 4500000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(4500000, apartmentMembers),
    note: 'Paid to landlord via online transfer',
    date: daysAgo(25, hour: 9, minute: 0),
  );

  // 2. Electricity & Gas
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Electricity & Sui Gas Bill',
    amountCents: 685000, // Rs 6,850
    payersCents: {samId: 685000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(685000, apartmentMembers),
    note: 'Peak summer electricity units',
    date: daysAgo(18, hour: 11, minute: 20),
  );

  // 3. Fiber Internet — split between Alex & Sam (Jordan uses company SIM)
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'High-Speed Fiber Internet',
    amountCents: 350000, // Rs 3,500
    payersCents: {alexId: 350000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(350000, [alexId, samId]),
    note: '500 Mbps connection (Jordan on company SIM)',
    date: daysAgo(14, hour: 16, minute: 0),
  );

  // 4. Supermarket Grocery Haul
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Weekly Supermarket Groceries',
    amountCents: 924000, // Rs 9,240
    payersCents: {alexId: 924000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(924000, apartmentMembers),
    note: 'Cooking oil, milk, rice, fruits & veggies',
    date: daysAgo(11, hour: 18, minute: 30),
  );

  // 5. Water Dispenser Bottles
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Mineral Water Jugs (4x 19L)',
    amountCents: 240000, // Rs 2,400
    payersCents: {jordanId: 240000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(240000, apartmentMembers),
    note: 'Aquafina refill delivery',
    date: daysAgo(9, hour: 13, minute: 0),
  );

  // 6. Cleaning Supplies & Detergents
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Cleaning Supplies & Detergent',
    amountCents: 165000, // Rs 1,650
    payersCents: {samId: 165000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(165000, apartmentMembers),
    note: 'Mop head, dishwasher tablets & trash bags',
    date: daysAgo(7, hour: 17, minute: 15),
  );

  // 7. Bookshelf & Living Room Lamp
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Living Room Bookshelf & Floor Lamp',
    amountCents: 1250000, // Rs 12,500
    payersCents: {alexId: 1250000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(1250000, apartmentMembers),
    note: 'Shared apartment common area furniture',
    date: daysAgo(6, hour: 15, minute: 45),
  );

  // 8. Plumber Repair
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Plumber Washbasin Drain Repair',
    amountCents: 320000, // Rs 3,200
    payersCents: {jordanId: 320000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(320000, apartmentMembers),
    note: 'Emergency fix and pipe replacement parts',
    date: daysAgo(4, hour: 12, minute: 10),
  );

  // 9. Kitchen Spices & Olive Oil
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Kitchen Spices & Extra Virgin Oil',
    amountCents: 215000, // Rs 2,150
    payersCents: {samId: 215000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(215000, apartmentMembers),
    note: 'Shared pantry staples',
    date: daysAgo(2, hour: 18, minute: 0),
  );

  // 10. Weekend Fresh Market — today
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Weekend Farmers Market Fruit Haul',
    amountCents: 540000, // Rs 5,400
    payersCents: {alexId: 540000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(540000, apartmentMembers),
    note: 'Fresh mangoes, peaches & organic eggs',
    date: daysAgo(0, hour: 10, minute: 30),
  );

  // 11. Security & Building Maintenance — today
  await createExpense(
    db,
    groupId: apartmentId,
    title: 'Building Security & Elevator Fee',
    amountCents: 180000, // Rs 1,800
    payersCents: {samId: 180000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(180000, apartmentMembers),
    note: 'Monthly building society dues',
    date: daysAgo(0, hour: 12, minute: 0),
  );

  // Apartment Settlements
  await createSettlement(
    db,
    groupId: apartmentId,
    fromUserId: samId,
    toUserId: alexId,
    amountCents: 1500000, // Rs 15,000
    note: 'Monthly rent contribution',
    date: daysAgo(22, hour: 14, minute: 0),
    createdAt: daysAgo(22, hour: 14, minute: 0),
  );
  await createSettlement(
    db,
    groupId: apartmentId,
    fromUserId: jordanId,
    toUserId: alexId,
    amountCents: 1500000, // Rs 15,000
    note: 'Monthly rent contribution',
    date: daysAgo(22, hour: 15, minute: 0),
    createdAt: daysAgo(22, hour: 15, minute: 0),
  );
  await createSettlement(
    db,
    groupId: apartmentId,
    fromUserId: alexId,
    toUserId: jordanId,
    amountCents: 250000, // Rs 2,500
    note: 'Plumber & water filter cost adjustment',
    date: daysAgo(3, hour: 19, minute: 0),
    createdAt: daysAgo(3, hour: 19, minute: 0),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. WEEKEND HANGOUT (Alex, Sam, Casey, Taylor) — 5 Expenses, 2 Settlements
  // ═══════════════════════════════════════════════════════════════════════════
  final hangoutId = await createGroup(
    db,
    name: 'Weekend Hangout',
    emoji: '🎬',
    currencyCode: 'PKR',
    existingUserIds: [alexId, samId, caseyId, taylorId],
    newMemberNames: const [],
  );
  final hangoutMembers = [alexId, samId, caseyId, taylorId];

  // 1. IMAX Tickets — 6 days ago
  await createExpense(
    db,
    groupId: hangoutId,
    title: 'IMAX 3D Dune Part Two Tickets',
    amountCents: 480000, // Rs 4,800
    payersCents: {alexId: 480000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(480000, hangoutMembers),
    note: 'Middle row prime seats',
    date: daysAgo(6, hour: 18, minute: 0),
  );

  // 2. Cinema Popcorn & Nachos
  await createExpense(
    db,
    groupId: hangoutId,
    title: 'Cinema Popcorn, Drinks & Nachos',
    amountCents: 275000, // Rs 2,750
    payersCents: {samId: 275000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(275000, hangoutMembers),
    note: 'Caramel popcorn and cheddar nachos combo',
    date: daysAgo(6, hour: 18, minute: 30),
  );

  // 3. Post-Movie Korean BBQ Dinner
  await createExpense(
    db,
    groupId: hangoutId,
    title: 'Korean BBQ Dinner & Beef Bulgogi',
    amountCents: 1360000, // Rs 13,600
    payersCents: {caseyId: 1360000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(1360000, hangoutMembers),
    note: 'Table grill combo with kimchi pancakes and drinks',
    date: daysAgo(5, hour: 21, minute: 30),
  );

  // 4. Arcade Games & VR Passes — exact split
  await createExpense(
    db,
    groupId: hangoutId,
    title: 'Arcade Gaming Cards & VR Passes',
    amountCents: 320000, // Rs 3,200
    payersCents: {taylorId: 320000},
    splitType: 'exact',
    splitsCents: {
      alexId: 80000, // Rs 800
      samId: 100000, // Rs 1,000 (extra laser tag round)
      caseyId: 60000, // Rs 600
      taylorId: 80000, // Rs 800
    },
    note: 'VR roller coaster and air hockey credits',
    date: daysAgo(3, hour: 20, minute: 0),
  );

  // 5. Late Night Boba & Churros
  await createExpense(
    db,
    groupId: hangoutId,
    title: 'Late Night Boba Milk Tea & Churros',
    amountCents: 245000, // Rs 2,450
    payersCents: {alexId: 245000},
    splitType: 'equal',
    splitsCents: SplitEngineService.equalSplit(245000, hangoutMembers),
    note: 'Brown sugar pearls and cinnamon chocolate churros',
    date: daysAgo(1, hour: 23, minute: 15),
  );

  // Hangout Settlements
  await createSettlement(
    db,
    groupId: hangoutId,
    fromUserId: alexId,
    toUserId: caseyId,
    amountCents: 340000, // Rs 3,400
    note: 'K-BBQ dinner payback',
    date: daysAgo(4, hour: 12, minute: 0),
    createdAt: daysAgo(4, hour: 12, minute: 0),
  );
  await createSettlement(
    db,
    groupId: hangoutId,
    fromUserId: taylorId,
    toUserId: caseyId,
    amountCents: 340000, // Rs 3,400
    note: 'K-BBQ dinner payback',
    date: daysAgo(2, hour: 16, minute: 30),
    createdAt: daysAgo(2, hour: 16, minute: 30),
  );

  return DemoSeedResult.seeded;
}

enum DemoSeedResult { seeded, alreadySeeded, blocked }
