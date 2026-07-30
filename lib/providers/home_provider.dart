import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/balance_service.dart';
import 'data_providers.dart';
import 'database_provider.dart';

class GroupSummary {
  final Group group;
  final int memberCount;

  /// Current user's net balance in this group (cents).
  /// Positive = they are owed, negative = they owe.
  final int myNetCents;

  const GroupSummary({
    required this.group,
    required this.memberCount,
    required this.myNetCents,
  });
}

class HomeData {
  final int totalOwedToMeCents;
  final int totalIOweCents;
  final List<GroupSummary> groups;

  const HomeData({
    required this.totalOwedToMeCents,
    required this.totalIOweCents,
    required this.groups,
  });
}

final homeDataProvider = Provider<AsyncValue<HomeData>>((ref) {
  final groups = ref.watch(groupsStreamProvider);
  final members = ref.watch(groupMembersStreamProvider);
  final expenses = ref.watch(expensesStreamProvider);
  final payers = ref.watch(payersStreamProvider);
  final splits = ref.watch(splitsStreamProvider);
  final settlements = ref.watch(settlementsStreamProvider);
  final currentUser = ref.watch(currentUserProvider);

  final sources = [groups, members, expenses, payers, splits, settlements];
  final loading = sources.any((s) => s.isLoading) || currentUser.isLoading;
  final error = sources
      .map((s) => s.error)
      .firstWhere((e) => e != null, orElse: () => currentUser.error);

  if (error != null) return AsyncValue.error(error, StackTrace.current);
  if (loading) return const AsyncValue.loading();

  final me = currentUser.value;
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

  var totalOwed = 0;
  var totalOwe = 0;
  final summaries = <GroupSummary>[];

  for (final group in groups.value!) {
    final groupExpenses = allExpenses
        .where((e) => e.groupId == group.id)
        .toList();
    final groupPayers = [
      for (final e in groupExpenses) ...?payersByExpense[e.id],
    ];
    final groupSplits = [
      for (final e in groupExpenses) ...?splitsByExpense[e.id],
    ];
    final groupSettlements = allSettlements
        .where((s) => s.groupId == group.id)
        .toList();

    final net = BalanceService.netBalances(
      payers: groupPayers,
      splits: groupSplits,
      settlements: groupSettlements,
    );

    final myNet = me == null ? 0 : (net[me.id] ?? 0);
    if (myNet > 0) totalOwed += myNet;
    if (myNet < 0) totalOwe += -myNet;

    summaries.add(
      GroupSummary(
        group: group,
        memberCount: allMembers.where((m) => m.groupId == group.id).length,
        myNetCents: myNet,
      ),
    );
  }

  return AsyncValue.data(
    HomeData(
      totalOwedToMeCents: totalOwed,
      totalIOweCents: totalOwe,
      groups: summaries,
    ),
  );
});
