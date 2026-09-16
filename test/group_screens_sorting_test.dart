import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/groups/create_group_screen.dart';
import 'package:scene_split/features/groups/edit_group_screen.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/data_providers.dart';
import 'package:scene_split/providers/database_provider.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

void main() {
  final now = DateTime.now();

  final me = User(
    id: 'user-me',
    name: 'Zack',
    isCurrentUser: true,
    colorIndex: 0,
    createdAt: now,
  );
  final userZara = User(
    id: 'user-zara',
    name: 'Zara',
    isCurrentUser: false,
    colorIndex: 1,
    createdAt: now,
  );
  final userAlice = User(
    id: 'user-alice',
    name: 'Alice',
    isCurrentUser: false,
    colorIndex: 2,
    createdAt: now,
  );
  final userBob = User(
    id: 'user-bob',
    name: 'Bob',
    isCurrentUser: false,
    colorIndex: 3,
    createdAt: now,
  );

  final allUsers = [userZara, me, userBob, userAlice];

  testWidgets(
    'CreateGroupScreen displays You at top and other users sorted alphabetically A-Z',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(AsyncValue.data(me)),
            usersStreamProvider.overrideWithValue(AsyncValue.data(allUsers)),
            currencyCodeProvider.overrideWithValue(
              const AsyncValue.data('USD'),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: CreateGroupScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final zackFinder = find.text('Zack (you)');
      final aliceFinder = find.text('Alice');
      final bobFinder = find.text('Bob');
      final zaraFinder = find.text('Zara');

      expect(zackFinder, findsOneWidget);
      expect(aliceFinder, findsOneWidget);
      expect(bobFinder, findsOneWidget);
      expect(zaraFinder, findsOneWidget);

      final zackY = tester.getTopLeft(zackFinder).dy;
      final aliceY = tester.getTopLeft(aliceFinder).dy;
      final bobY = tester.getTopLeft(bobFinder).dy;
      final zaraY = tester.getTopLeft(zaraFinder).dy;

      // Selected count indicator
      expect(find.text('1 selected'), findsOneWidget);

      // Vertical order: Zack (You) -> Alice -> Bob -> Zara
      expect(zackY, lessThan(aliceY));
      expect(aliceY, lessThan(bobY));
      expect(bobY, lessThan(zaraY));

      // Tapping Alice updates count to 2 selected
      await tester.tap(aliceFinder);
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);
    },
  );

  testWidgets(
    'EditGroupScreen displays current members (You at top, rest A-Z) and other users A-Z',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final group = Group(
        id: 'g1',
        name: 'Trip',
        emoji: '🏖',
        currencyCode: 'USD',
        showDecimals: false,
        createdAt: now,
      );

      final detailData = GroupDetailData(
        group: group,
        members: [
          GroupMemberInfo(userZara),
          GroupMemberInfo(me),
          GroupMemberInfo(userAlice),
        ],
        expenses: const [],
        settlements: const [],
        debts: const [],
        myNetCents: 0,
        memberShareCents: const {},
        memberExpenseShares: const {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(AsyncValue.data(me)),
            usersStreamProvider.overrideWithValue(AsyncValue.data(allUsers)),
            currencyCodeProvider.overrideWithValue(
              const AsyncValue.data('USD'),
            ),
            groupDetailProvider(
              'g1',
            ).overrideWithValue(AsyncValue.data(detailData)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: EditGroupScreen(groupId: 'g1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final zackFinder = find.text('Zack (you)');
      final aliceFinder = find.text('Alice');
      final zaraFinder = find.text('Zara');
      final bobFinder = find.text('Bob');

      expect(zackFinder, findsOneWidget);
      expect(aliceFinder, findsOneWidget);
      expect(zaraFinder, findsOneWidget);
      expect(bobFinder, findsOneWidget);

      final zackY = tester.getTopLeft(zackFinder).dy;
      final aliceY = tester.getTopLeft(aliceFinder).dy;
      final zaraY = tester.getTopLeft(zaraFinder).dy;
      final bobY = tester.getTopLeft(bobFinder).dy;

      // Selected count indicator
      expect(find.text('3 selected'), findsOneWidget);

      // Current members: Zack (You) -> Alice -> Zara
      expect(zackY, lessThan(aliceY));
      expect(aliceY, lessThan(zaraY));

      // Other users not yet in group: Bob
      expect(zaraY, lessThan(bobY));
    },
  );
}
