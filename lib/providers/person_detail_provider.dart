import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/balance_service.dart';
import 'data_providers.dart';
import 'group_detail_provider.dart';

/// Pairwise debts that involve [personId] as debtor or creditor.
List<PairwiseDebt> filterDebtsForPerson(
  List<PairwiseDebt> debts,
  String personId,
) {
  return [
    for (final d in debts)
      if (d.fromUserId == personId || d.toUserId == personId) d,
  ];
}

/// Scene memberships for [personId], newest group name first among ties.
List<Group> groupsForPerson({
  required String personId,
  required List<Group> groups,
  required List<GroupMember> members,
}) {
  final groupIds = {
    for (final m in members)
      if (m.userId == personId) m.groupId,
  };
  final result = [
    for (final g in groups)
      if (groupIds.contains(g.id)) g,
  ];
  result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return result;
}

/// One scene's balances for a person. Amounts are in [group.currencyCode].
class PersonGroupBalance {
  final Group group;
  final List<GroupMemberInfo> members;

  /// Person's net in this scene: positive = owed to them, negative = they owe.
  final int netCents;
  final List<PairwiseDebt> debts;
  final int totalShareCents;
  final List<MemberExpenseShare> expenseShares;

  const PersonGroupBalance({
    required this.group,
    required this.members,
    required this.netCents,
    required this.debts,
    required this.totalShareCents,
    required this.expenseShares,
  });

  bool get hasOpenBalance => netCents != 0 || debts.isNotEmpty;
}

/// Directional open totals for one currency across a person's scenes.
class PersonCurrencyTotals {
  final String currencyCode;
  final int willGiveCents;
  final int getsCents;

  const PersonCurrencyTotals({
    required this.currencyCode,
    required this.willGiveCents,
    required this.getsCents,
  });
}

/// Aggregate pairwise debts for [data.user] into per-currency will-give / gets.
///
/// Never merges different currencies. Currencies where both sides are 0 are
/// omitted. Results are sorted by currency code.
List<PersonCurrencyTotals> summarizePersonCurrencyTotals(
  PersonDetailData data,
) {
  final personId = data.user.id;
  final willGive = <String, int>{};
  final gets = <String, int>{};

  for (final group in data.groups) {
    final currency = group.group.currencyCode;
    for (final debt in group.debts) {
      if (debt.fromUserId == personId) {
        willGive[currency] = (willGive[currency] ?? 0) + debt.amountCents;
      }
      if (debt.toUserId == personId) {
        gets[currency] = (gets[currency] ?? 0) + debt.amountCents;
      }
    }
  }

  final currencies = {...willGive.keys, ...gets.keys}.toList()..sort();
  return [
    for (final code in currencies)
      if ((willGive[code] ?? 0) != 0 || (gets[code] ?? 0) != 0)
        PersonCurrencyTotals(
          currencyCode: code,
          willGiveCents: willGive[code] ?? 0,
          getsCents: gets[code] ?? 0,
        ),
  ];
}

class PersonDetailData {
  final User user;
  final List<PersonGroupBalance> groups;

  const PersonDetailData({required this.user, required this.groups});

  int get sceneCount => groups.length;

  bool get hasAnyOpenBalance => groups.any((g) => g.hasOpenBalance);

  List<PersonCurrencyTotals> get currencyTotals =>
      summarizePersonCurrencyTotals(this);
}

/// Scene counts per user for People list subtitles.
final personSceneCountProvider = Provider<Map<String, int>>((ref) {
  final members = ref.watch(groupMembersStreamProvider);
  if (!members.hasValue) return const {};
  final counts = <String, int>{};
  for (final m in members.value!) {
    counts[m.userId] = (counts[m.userId] ?? 0) + 1;
  }
  return counts;
});

final personDetailProvider =
    Provider.family<AsyncValue<PersonDetailData>, String>((ref, personId) {
      final groups = ref.watch(groupsStreamProvider);
      final members = ref.watch(groupMembersStreamProvider);
      final users = ref.watch(usersStreamProvider);
      final expenses = ref.watch(expensesStreamProvider);
      final payers = ref.watch(payersStreamProvider);
      final splits = ref.watch(splitsStreamProvider);
      final settlements = ref.watch(settlementsStreamProvider);

      final sources = [
        groups,
        members,
        users,
        expenses,
        payers,
        splits,
        settlements,
      ];
      final loading = sources.any((s) => s.isLoading);
      final error = sources
          .map((s) => s.error)
          .firstWhere((e) => e != null, orElse: () => null);

      if (error != null) return AsyncValue.error(error, StackTrace.current);
      if (loading) return const AsyncValue.loading();

      final userMap = {for (final u in users.value!) u.id: u};
      final user = userMap[personId];
      if (user == null) {
        return AsyncValue.error('Person not found', StackTrace.current);
      }

      final allGroups = groups.value!;
      final allMembers = members.value!;
      final allExpenses = expenses.value!;
      final allPayers = payers.value!;
      final allSplits = splits.value!;
      final allSettlements = settlements.value!;

      final payersByExpense = <String, List<ExpensePayer>>{};
      for (final p in allPayers) {
        payersByExpense.putIfAbsent(p.expenseId, () => []).add(p);
      }
      final splitsByExpense = <String, List<ExpenseSplit>>{};
      for (final s in allSplits) {
        splitsByExpense.putIfAbsent(s.expenseId, () => []).add(s);
      }

      final personGroups = groupsForPerson(
        personId: personId,
        groups: allGroups,
        members: allMembers,
      );

      final balances = <PersonGroupBalance>[];
      for (final group in personGroups) {
        final groupId = group.id;
        final memberIds = allMembers
            .where((m) => m.groupId == groupId)
            .map((m) => m.userId)
            .toList();
        final memberInfos = [
          for (final id in memberIds)
            if (userMap[id] != null) GroupMemberInfo(userMap[id]!),
        ];

        final groupExpenses =
            allExpenses.where((e) => e.groupId == groupId).toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        final groupPayers = [
          for (final e in groupExpenses) ...?payersByExpense[e.id],
        ];
        final groupSplits = [
          for (final e in groupExpenses) ...?splitsByExpense[e.id],
        ];
        final groupSettlements = allSettlements
            .where((s) => s.groupId == groupId)
            .toList();

        final net = BalanceService.netBalances(
          payers: groupPayers,
          splits: groupSplits,
          settlements: groupSettlements,
        );

        final debts = filterDebtsForPerson(
          BalanceService.pairwiseDebts(
            payersByExpense: {
              for (final e in groupExpenses)
                e.id: payersByExpense[e.id] ?? const [],
            },
            splitsByExpense: {
              for (final e in groupExpenses)
                e.id: splitsByExpense[e.id] ?? const [],
            },
            settlements: groupSettlements,
          ),
          personId,
        );

        final expenseList = [
          for (final e in groupExpenses)
            ExpenseWithSplits(
              expense: e,
              payers: payersByExpense[e.id] ?? [],
              splits: splitsByExpense[e.id] ?? [],
            ),
        ];
        final breakdown = buildMemberShareBreakdown(expenseList);
        final shares = breakdown.expenseShares[personId] ?? const [];
        final totalShare = breakdown.shareCents[personId] ?? 0;

        balances.add(
          PersonGroupBalance(
            group: group,
            members: memberInfos,
            netCents: net[personId] ?? 0,
            debts: debts,
            totalShareCents: totalShare,
            expenseShares: shares,
          ),
        );
      }

      balances.sort((a, b) {
        final aOpen = a.hasOpenBalance ? 0 : 1;
        final bOpen = b.hasOpenBalance ? 0 : 1;
        if (aOpen != bOpen) return aOpen.compareTo(bOpen);
        return a.group.name.toLowerCase().compareTo(b.group.name.toLowerCase());
      });

      return AsyncValue.data(PersonDetailData(user: user, groups: balances));
    });
