import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:scene_split/database/app_database.dart';
import 'package:scene_split/features/settlements/record_settlement_sheet.dart';
import 'package:scene_split/l10n/app_localizations.dart';
import 'package:scene_split/providers/group_detail_provider.dart';

Widget createTestApp({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => child,
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final user1 = User(
    id: 'u1',
    name: 'Alice',
    colorIndex: 0,
    createdAt: DateTime.now(),
    isCurrentUser: true,
  );
  final user2 = User(
    id: 'u2',
    name: 'Bob',
    colorIndex: 1,
    createdAt: DateTime.now(),
    isCurrentUser: false,
  );

  final members = [GroupMemberInfo(user1), GroupMemberInfo(user2)];

  testWidgets(
    'RecordSettlementSheet shows date field with current date and calendar icon',
    (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: showRecordSettlementSheetBuilder(
            groupId: 'g1',
            currencyCode: 'USD',
            members: members,
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify title and labels
      expect(find.text('Record settlement'), findsOneWidget);
      expect(find.text('FROM (PAYS)'), findsOneWidget);
      expect(find.text('TO (RECEIVES)'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);

      // Date formatted with weekday e.g. "Fri, Sep 25, 2026"
      final expectedDateStr = DateFormat.yMMMEd('en').format(DateTime.now());
      expect(find.text(expectedDateStr), findsOneWidget);
    },
  );

  testWidgets(
    'RecordSettlementSheet prefills existing settlement date and values when editing',
    (tester) async {
      final existingDate = DateTime(2026, 7, 20);
      final existing = Settlement(
        id: 's1',
        groupId: 'g1',
        fromUserId: 'u2',
        toUserId: 'u1',
        amountCents: 4250,
        note: 'Dinner payback',
        date: existingDate,
        createdAt: existingDate,
      );

      await tester.pumpWidget(
        createTestApp(
          child: showRecordSettlementSheetBuilder(
            groupId: 'g1',
            currencyCode: 'USD',
            members: members,
            existing: existing,
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Edit settlement'), findsOneWidget);
      expect(find.text('42.50'), findsOneWidget);
      expect(find.text('Dinner payback'), findsOneWidget);

      final expectedDateStr = DateFormat.yMMMEd('en').format(existingDate);
      expect(find.text(expectedDateStr), findsOneWidget);
    },
  );
}

// Helper builder to access private sheet
Widget showRecordSettlementSheetBuilder({
  required String groupId,
  required String currencyCode,
  required List<GroupMemberInfo> members,
  Settlement? existing,
}) {
  return Builder(
    builder: (context) {
      // Return a test container that will trigger the modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showRecordSettlementSheet(
          context,
          groupId: groupId,
          currencyCode: currencyCode,
          members: members,
          existing: existing,
        );
      });
      return const SizedBox.shrink();
    },
  );
}
