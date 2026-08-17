import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../services/balance_service.dart';
import 'data_providers.dart';
import 'database_provider.dart';
import 'group_detail_provider.dart';

/// One open simplified debt in a specific scene.
class OpenSceneDebt {
  final String groupId;
  final String groupName;
  final String groupEmoji;
  final String currencyCode;
  final OpenDebt debt;

  const OpenSceneDebt({
    required this.groupId,
    required this.groupName,
    required this.groupEmoji,
    required this.currencyCode,
    required this.debt,
  });
}

/// Per-currency total for a directed pair (A owes B).
class PairCurrencyTotal {
  final String currencyCode;
  final int amountCents;

  const PairCurrencyTotal({
    required this.currencyCode,
    required this.amountCents,
  });
}

/// Per-currency owed / owe totals for one person's open POV across scenes.
class PersonPovCurrencyTotals {
  final String currencyCode;

  /// Others owe [person] this much in [currencyCode].
  final int owedToThemCents;

  /// [person] owes others this much in [currencyCode].
  final int theyOweCents;

  const PersonPovCurrencyTotals({
    required this.currencyCode,
    required this.owedToThemCents,
    required this.theyOweCents,
  });
}

/// Roll up open edges involving [personId] into per-currency owed / owe totals.
///
/// Never merges different currencies. Currencies where both sides are 0 are
/// omitted. Results are sorted by currency code.
List<PersonPovCurrencyTotals> summarizePersonPovTotals(
  List<OpenSceneDebt> debts,
  String personId,
) {
  final owedToThem = <String, int>{};
  final theyOwe = <String, int>{};

  for (final d in debts) {
    final currency = d.currencyCode;
    if (d.debt.toUserId == personId) {
      owedToThem[currency] = (owedToThem[currency] ?? 0) + d.debt.amountCents;
    }
    if (d.debt.fromUserId == personId) {
      theyOwe[currency] = (theyOwe[currency] ?? 0) + d.debt.amountCents;
    }
  }

  final codes = {...owedToThem.keys, ...theyOwe.keys}.toList()..sort();
  return [
    for (final code in codes)
      if ((owedToThem[code] ?? 0) > 0 || (theyOwe[code] ?? 0) > 0)
        PersonPovCurrencyTotals(
          currencyCode: code,
          owedToThemCents: owedToThem[code] ?? 0,
          theyOweCents: theyOwe[code] ?? 0,
        ),
  ];
}

/// Per-currency net for a pair POV (only when both gross sides are open).
class PersonPovCurrencyNet {
  final String currencyCode;

  /// Positive = [person] owes the other this much net.
  /// Negative = the other owes [person] this much net (|value|).
  final int netCentsFromPerson;

  const PersonPovCurrencyNet({
    required this.currencyCode,
    required this.netCentsFromPerson,
  });

  bool get personOwesOther => netCentsFromPerson > 0;
  int get amountCents => netCentsFromPerson.abs();
}

/// Nets where both [owedToThem] and [theyOwe] are positive in the same currency.
List<PersonPovCurrencyNet> netPersonPovTotals(
  List<PersonPovCurrencyTotals> totals,
) {
  return [
    for (final t in totals)
      if (t.owedToThemCents > 0 && t.theyOweCents > 0)
        if (t.theyOweCents != t.owedToThemCents)
          PersonPovCurrencyNet(
            currencyCode: t.currencyCode,
            netCentsFromPerson: t.theyOweCents - t.owedToThemCents,
          ),
  ];
}

/// Aggregate open edges for [personId] by counterparty for breakdown sheets.
///
/// [owedByCounterparty]: who owes the person (key = other user id).
/// [oweToCounterparty]: whom the person owes (key = other user id).
/// Each map value is currency → cents. Never merges currencies.
({
  Map<String, Map<String, int>> owedByCounterparty,
  Map<String, Map<String, int>> oweToCounterparty,
})
aggregatePersonPovByCounterparty(List<OpenSceneDebt> debts, String personId) {
  final owed = <String, Map<String, int>>{};
  final owe = <String, Map<String, int>>{};

  for (final d in debts) {
    if (d.debt.toUserId == personId) {
      final byCurrency = owed.putIfAbsent(d.debt.fromUserId, () => {});
      byCurrency[d.currencyCode] =
          (byCurrency[d.currencyCode] ?? 0) + d.debt.amountCents;
    }
    if (d.debt.fromUserId == personId) {
      final byCurrency = owe.putIfAbsent(d.debt.toUserId, () => {});
      byCurrency[d.currencyCode] =
          (byCurrency[d.currencyCode] ?? 0) + d.debt.amountCents;
    }
  }

  return (owedByCounterparty: owed, oweToCounterparty: owe);
}

/// Debts for the Balances hero, scoped by Who / Whom filter selection.
///
/// - Neither set → empty (hide hero).
/// - Who only → all edges involving Who (full person POV).
/// - Whom only → all edges involving Whom (full person POV).
/// - Both → edges between Who and Whom (either direction).
List<OpenSceneDebt> scopeDebtsForBalancesHero(
  List<OpenSceneDebt> debts, {
  String? whoId,
  String? whomId,
}) {
  if (whoId == null && whomId == null) return const [];

  if (whoId != null && whomId != null) {
    return [
      for (final d in debts)
        if ((d.debt.fromUserId == whoId && d.debt.toUserId == whomId) ||
            (d.debt.fromUserId == whomId && d.debt.toUserId == whoId))
          d,
    ];
  }

  final personId = whomId ?? whoId!;
  return [
    for (final d in debts)
      if (d.debt.fromUserId == personId || d.debt.toUserId == personId) d,
  ];
}

/// One scene's open debt for a directed pair, plus the debtor's expense-share rollup.
class PairSceneBreakdown {
  final String groupId;
  final String groupName;
  final String groupEmoji;
  final String currencyCode;
  final String fromUserId;
  final String toUserId;
  final int debtCents;
  final List<GroupMemberInfo> members;
  final List<MemberExpenseShare> expenseShares;
  final int totalShareCents;
  final int totalExpenseCents;

  const PairSceneBreakdown({
    required this.groupId,
    required this.groupName,
    required this.groupEmoji,
    required this.currencyCode,
    required this.fromUserId,
    required this.toUserId,
    required this.debtCents,
    required this.members,
    required this.expenseShares,
    required this.totalShareCents,
    required this.totalExpenseCents,
  });
}

/// Filter open cross-scene debts by optional debtor [fromId] and/or creditor [toId].
List<OpenSceneDebt> filterOpenDebts(
  List<OpenSceneDebt> debts, {
  String? fromId,
  String? toId,
}) {
  return [
    for (final d in debts)
      if ((fromId == null || d.debt.fromUserId == fromId) &&
          (toId == null || d.debt.toUserId == toId))
        d,
  ];
}

/// Open edges between two people in either direction (relationship view).
List<OpenSceneDebt> filterOpenDebtsBetweenPair(
  List<OpenSceneDebt> debts, {
  required String userIdA,
  required String userIdB,
}) {
  return [
    for (final d in debts)
      if ((d.debt.fromUserId == userIdA && d.debt.toUserId == userIdB) ||
          (d.debt.fromUserId == userIdB && d.debt.toUserId == userIdA))
        d,
  ];
}

/// Sum directed A→B open edges per currency (never merges currencies).
List<PairCurrencyTotal> aggregatePairByCurrency(
  List<OpenSceneDebt> debts, {
  required String fromId,
  required String toId,
}) {
  final sums = <String, int>{};
  for (final d in debts) {
    if (d.debt.fromUserId != fromId || d.debt.toUserId != toId) continue;
    sums[d.currencyCode] = (sums[d.currencyCode] ?? 0) + d.debt.amountCents;
  }
  final codes = sums.keys.toList()..sort();
  return [
    for (final code in codes)
      if ((sums[code] ?? 0) > 0)
        PairCurrencyTotal(currencyCode: code, amountCents: sums[code]!),
  ];
}

/// One directed pair (A owes B) with open amounts rolled up per currency.
class PairOpenBalanceSummary {
  final String fromUserId;
  final String toUserId;
  final List<PairCurrencyTotal> currencyTotals;
  final int sceneCount;

  /// Unique scene labels (`emoji name`), sorted by name.
  final List<String> sceneLabels;

  const PairOpenBalanceSummary({
    required this.fromUserId,
    required this.toUserId,
    required this.currencyTotals,
    required this.sceneCount,
    required this.sceneLabels,
  });
}

/// Group open scene debts into directed pairs; currencies stay as separate rows.
List<PairOpenBalanceSummary> groupDebtsByPair(List<OpenSceneDebt> debts) {
  final byPair = <String, List<OpenSceneDebt>>{};
  for (final d in debts) {
    final key = '${d.debt.fromUserId}|${d.debt.toUserId}';
    byPair.putIfAbsent(key, () => []).add(d);
  }

  final result = <PairOpenBalanceSummary>[];
  for (final entry in byPair.entries) {
    final items = entry.value;
    final fromId = items.first.debt.fromUserId;
    final toId = items.first.debt.toUserId;

    final scenesById = <String, String>{};
    for (final d in items) {
      scenesById.putIfAbsent(d.groupId, () => '${d.groupEmoji} ${d.groupName}');
    }
    final sceneLabels = scenesById.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    result.add(
      PairOpenBalanceSummary(
        fromUserId: fromId,
        toUserId: toId,
        currencyTotals: aggregatePairByCurrency(
          items,
          fromId: fromId,
          toId: toId,
        ),
        sceneCount: scenesById.length,
        sceneLabels: sceneLabels,
      ),
    );
  }

  result.sort((a, b) {
    final byFrom = a.fromUserId.compareTo(b.fromUserId);
    if (byFrom != 0) return byFrom;
    return a.toUserId.compareTo(b.toUserId);
  });
  return result;
}

/// Group open debts by currency; within each currency, largest amount first.
Map<String, List<OpenSceneDebt>> groupDebtsByCurrency(
  List<OpenSceneDebt> debts,
) {
  final map = <String, List<OpenSceneDebt>>{};
  for (final d in debts) {
    map.putIfAbsent(d.currencyCode, () => []).add(d);
  }
  for (final list in map.values) {
    list.sort((a, b) {
      final byAmount = b.debt.amountCents.compareTo(a.debt.amountCents);
      if (byAmount != 0) return byAmount;
      return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
    });
  }
  return map;
}

int sumShareCents(List<MemberExpenseShare> shares) {
  var total = 0;
  for (final s in shares) {
    total += s.shareCents;
  }
  return total;
}

int sumExpenseCents(List<MemberExpenseShare> shares) {
  var total = 0;
  for (final s in shares) {
    total += s.expense.amountCents;
  }
  return total;
}

class BalancesOverviewData {
  final List<OpenSceneDebt> openDebts;
  final Map<String, User> users;
  final User? currentUser;

  const BalancesOverviewData({
    required this.openDebts,
    required this.users,
    required this.currentUser,
  });
}

/// Cross-scene open simplified debts for the Balances tab.
final balancesOverviewProvider = Provider<AsyncValue<BalancesOverviewData>>((
  ref,
) {
  final groups = ref.watch(groupsStreamProvider);
  final members = ref.watch(groupMembersStreamProvider);
  final users = ref.watch(usersStreamProvider);
  final expenses = ref.watch(expensesStreamProvider);
  final payers = ref.watch(payersStreamProvider);
  final splits = ref.watch(splitsStreamProvider);
  final settlements = ref.watch(settlementsStreamProvider);
  final currentUser = ref.watch(currentUserProvider);

  final sources = [
    groups,
    members,
    users,
    expenses,
    payers,
    splits,
    settlements,
  ];
  final loading = sources.any((s) => s.isLoading) || currentUser.isLoading;
  final error = sources
      .map((s) => s.error)
      .firstWhere((e) => e != null, orElse: () => currentUser.error);

  if (error != null) return AsyncValue.error(error, StackTrace.current);
  if (loading) return const AsyncValue.loading();

  final allGroups = groups.value!;
  final allExpenses = expenses.value!;
  final allPayers = payers.value!;
  final allSplits = splits.value!;
  final allSettlements = settlements.value!;
  final userMap = {for (final u in users.value!) u.id: u};

  final payersByExpense = <String, List<ExpensePayer>>{};
  for (final p in allPayers) {
    payersByExpense.putIfAbsent(p.expenseId, () => []).add(p);
  }
  final splitsByExpense = <String, List<ExpenseSplit>>{};
  for (final s in allSplits) {
    splitsByExpense.putIfAbsent(s.expenseId, () => []).add(s);
  }

  final openDebts = <OpenSceneDebt>[];
  for (final group in allGroups) {
    final groupExpenses = allExpenses
        .where((e) => e.groupId == group.id)
        .toList();
    final groupSettlements = allSettlements
        .where((s) => s.groupId == group.id)
        .toList();

    final groupPayers = [
      for (final e in groupExpenses) ...?payersByExpense[e.id],
    ];
    final groupSplits = [
      for (final e in groupExpenses) ...?splitsByExpense[e.id],
    ];
    final debts = BalanceService.simplifyDebts(
      BalanceService.netBalances(
        payers: groupPayers,
        splits: groupSplits,
        settlements: groupSettlements,
      ),
    );

    for (final debt in debts) {
      if (debt.amountCents <= 0) continue;
      openDebts.add(
        OpenSceneDebt(
          groupId: group.id,
          groupName: group.name,
          groupEmoji: group.emoji,
          currencyCode: group.currencyCode,
          debt: debt,
        ),
      );
    }
  }

  openDebts.sort((a, b) {
    final byCurrency = a.currencyCode.compareTo(b.currencyCode);
    if (byCurrency != 0) return byCurrency;
    return b.debt.amountCents.compareTo(a.debt.amountCents);
  });

  return AsyncValue.data(
    BalancesOverviewData(
      openDebts: openDebts,
      users: userMap,
      currentUser: currentUser.value,
    ),
  );
});

/// Scene breakdown + share totals for either direction between a pair.
final pairBalanceDetailProvider =
    Provider.family<
      AsyncValue<List<PairSceneBreakdown>>,
      ({String fromId, String toId})
    >((ref, pair) {
      final overview = ref.watch(balancesOverviewProvider);
      final groups = ref.watch(groupsStreamProvider);
      final members = ref.watch(groupMembersStreamProvider);
      final users = ref.watch(usersStreamProvider);
      final expenses = ref.watch(expensesStreamProvider);
      final payers = ref.watch(payersStreamProvider);
      final splits = ref.watch(splitsStreamProvider);

      if (overview.hasError) {
        return AsyncValue.error(overview.error!, StackTrace.current);
      }
      final sources = [groups, members, users, expenses, payers, splits];
      final loading = overview.isLoading || sources.any((s) => s.isLoading);
      final error = sources
          .map((s) => s.error)
          .firstWhere((e) => e != null, orElse: () => null);
      if (error != null) return AsyncValue.error(error, StackTrace.current);
      if (loading || !overview.hasValue) return const AsyncValue.loading();

      final pairDebts = filterOpenDebtsBetweenPair(
        overview.value!.openDebts,
        userIdA: pair.fromId,
        userIdB: pair.toId,
      );
      if (pairDebts.isEmpty) return const AsyncValue.data([]);

      final userMap = {for (final u in users.value!) u.id: u};
      final allMembers = members.value!;
      final allExpenses = expenses.value!;
      final allPayers = payers.value!;
      final allSplits = splits.value!;

      final payersByExpense = <String, List<ExpensePayer>>{};
      for (final p in allPayers) {
        payersByExpense.putIfAbsent(p.expenseId, () => []).add(p);
      }
      final splitsByExpense = <String, List<ExpenseSplit>>{};
      for (final s in allSplits) {
        splitsByExpense.putIfAbsent(s.expenseId, () => []).add(s);
      }

      // One entry per scene + direction (same scene rarely has both).
      final bySceneDirection = <String, OpenSceneDebt>{};
      for (final d in pairDebts) {
        final key = '${d.groupId}|${d.debt.fromUserId}|${d.debt.toUserId}';
        bySceneDirection[key] = d;
      }

      final result = <PairSceneBreakdown>[];
      for (final open in bySceneDirection.values) {
        final groupId = open.groupId;
        final debtorId = open.debt.fromUserId;
        final memberIds = allMembers
            .where((m) => m.groupId == groupId)
            .map((m) => m.userId);
        final memberInfos = [
          for (final id in memberIds)
            if (userMap[id] != null) GroupMemberInfo(userMap[id]!),
        ];

        final groupExpenses =
            allExpenses.where((e) => e.groupId == groupId).toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        final expenseList = [
          for (final e in groupExpenses)
            ExpenseWithSplits(
              expense: e,
              payers: payersByExpense[e.id] ?? [],
              splits: splitsByExpense[e.id] ?? [],
            ),
        ];
        final breakdown = buildMemberShareBreakdown(expenseList);
        // Debtor's shares for this directed scene edge.
        final shares = breakdown.expenseShares[debtorId] ?? const [];
        final totalShare = breakdown.shareCents[debtorId] ?? 0;

        result.add(
          PairSceneBreakdown(
            groupId: open.groupId,
            groupName: open.groupName,
            groupEmoji: open.groupEmoji,
            currencyCode: open.currencyCode,
            fromUserId: open.debt.fromUserId,
            toUserId: open.debt.toUserId,
            debtCents: open.debt.amountCents,
            members: memberInfos,
            expenseShares: shares,
            totalShareCents: totalShare,
            totalExpenseCents: sumExpenseCents(shares),
          ),
        );
      }

      result.sort((a, b) {
        final byCurrency = a.currencyCode.compareTo(b.currencyCode);
        if (byCurrency != 0) return byCurrency;
        final byAmount = b.debtCents.compareTo(a.debtCents);
        if (byAmount != 0) return byAmount;
        return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
      });

      return AsyncValue.data(result);
    });
