import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/balance_service.dart';
import 'data_providers.dart';
import 'database_provider.dart';

class GroupMemberInfo {
  final User user;
  const GroupMemberInfo(this.user);
}

class ExpenseWithSplits {
  final Expense expense;
  final List<ExpenseSplit> splits;
  const ExpenseWithSplits({required this.expense, required this.splits});
}

class GroupDetailData {
  final Group group;
  final List<GroupMemberInfo> members;
  final List<PairwiseDebt> debts;
  final int myNetCents;
  final List<ExpenseWithSplits> expenses;
  final List<Settlement> settlements;

  /// Total expense share per member (userId -> cents). Only entries > 0.
  final Map<String, int> memberShareCents;

  const GroupDetailData({
    required this.group,
    required this.members,
    required this.debts,
    required this.myNetCents,
    required this.expenses,
    required this.settlements,
    required this.memberShareCents,
  });
}

final groupDetailProvider =
    Provider.family<AsyncValue<GroupDetailData>, String>((ref, groupId) {
  final groups = ref.watch(groupsStreamProvider);
  final members = ref.watch(groupMembersStreamProvider);
  final users = ref.watch(usersStreamProvider);
  final expenses = ref.watch(expensesStreamProvider);
  final splits = ref.watch(splitsStreamProvider);
  final settlements = ref.watch(settlementsStreamProvider);
  final currentUser = ref.watch(currentUserProvider);

  final sources = [groups, members, users, expenses, splits, settlements];
  final loading = sources.any((s) => s.isLoading) || currentUser.isLoading;
  final error = sources
      .map((s) => s.error)
      .firstWhere((e) => e != null, orElse: () => currentUser.error);

  if (error != null) return AsyncValue.error(error, StackTrace.current);
  if (loading) return const AsyncValue.loading();

  final group = groups.value!.cast<Group?>().firstWhere(
        (g) => g?.id == groupId,
        orElse: () => null,
      );
  if (group == null) {
    return AsyncValue.error('Group not found', StackTrace.current);
  }

  final userMap = {for (final u in users.value!) u.id: u};
  final memberIds = members.value!
      .where((m) => m.groupId == groupId)
      .map((m) => m.userId)
      .toList();
  final memberInfos = [
    for (final id in memberIds)
      if (userMap[id] != null) GroupMemberInfo(userMap[id]!),
  ];

  final groupExpenses =
      expenses.value!.where((e) => e.groupId == groupId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  final splitsByExpense = <String, List<ExpenseSplit>>{};
  for (final s in splits.value!) {
    splitsByExpense.putIfAbsent(s.expenseId, () => []).add(s);
  }

  final groupSplits = [
    for (final e in groupExpenses) ...?splitsByExpense[e.id],
  ];
  final groupSettlements =
      settlements.value!.where((s) => s.groupId == groupId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final net = BalanceService.netBalances(
    expenses: groupExpenses,
    splits: groupSplits,
    settlements: groupSettlements,
  );

  final me = currentUser.value;
  final myNet = me == null ? 0 : (net[me.id] ?? 0);
  final debts = BalanceService.simplifyDebts(net);

  final expenseList = [
    for (final e in groupExpenses)
      ExpenseWithSplits(
        expense: e,
        splits: splitsByExpense[e.id] ?? [],
      ),
  ];

  final shareByUserId = <String, int>{};
  for (final e in groupExpenses) {
    for (final split in splitsByExpense[e.id] ?? []) {
      shareByUserId[split.userId] =
          (shareByUserId[split.userId] ?? 0) + split.amountCents as int;
    }
  }
  shareByUserId.removeWhere((_, cents) => cents <= 0);

  return AsyncValue.data(GroupDetailData(
    group: group,
    members: memberInfos,
    debts: debts,
    myNetCents: myNet,
    expenses: expenseList,
    settlements: groupSettlements,
    memberShareCents: shareByUserId,
  ));
});
