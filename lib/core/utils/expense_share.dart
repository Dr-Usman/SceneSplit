import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/group_detail_provider.dart';
import '../../services/balance_service.dart';
import '../constants/app_links.dart';
import 'money.dart';

/// Max expense rows rendered on the share PNG (overflow is a trailing line).
const int kExpenseShareImageMaxRows = 30;

enum ExpenseShareRangePreset {
  all,
  today,
  singleDay,
  thisWeek,
  last7,
  month,
  custom,
}

enum ExpenseShareFormat { image, text }

/// One compact row on the expense share image.
class ExpenseShareImageRow {
  const ExpenseShareImageRow({
    required this.title,
    required this.amount,
    required this.subtitle,
  });

  final String title;
  final String amount;
  final String subtitle;
}

/// One member's shares across the filtered expenses (expense order).
class ExpenseShareMemberTotal {
  const ExpenseShareMemberTotal({
    required this.name,
    required this.partsCents,
    required this.totalCents,
  });

  final String name;
  final List<int> partsCents;
  final int totalCents;
}

/// Calendar date with time stripped (local).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Inclusive calendar-day range: [start, end] after stripping times.
bool isDateInInclusiveRange(DateTime date, DateTime start, DateTime end) {
  final day = dateOnly(date);
  return !day.isBefore(dateOnly(start)) && !day.isAfter(dateOnly(end));
}

DateTimeRange todayRange(DateTime now) {
  final today = dateOnly(now);
  return DateTimeRange(start: today, end: today);
}

DateTimeRange thisWeekRange(DateTime now) {
  final today = dateOnly(now);
  // Monday is 1, Sunday is 7. Monday of the current week:
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return DateTimeRange(start: monday, end: today);
}

DateTimeRange thisMonthRange(DateTime now) {
  final today = dateOnly(now);
  return DateTimeRange(start: DateTime(today.year, today.month, 1), end: today);
}

DateTimeRange last7DaysRange(DateTime now) {
  final today = dateOnly(now);
  return DateTimeRange(
    start: today.subtract(const Duration(days: 6)),
    end: today,
  );
}

/// Resolves a preset to an inclusive date range. `null` means all dates.
DateTimeRange? resolveExpenseShareRange(
  ExpenseShareRangePreset preset, {
  required DateTime now,
  DateTimeRange? custom,
}) {
  return switch (preset) {
    ExpenseShareRangePreset.all => null,
    ExpenseShareRangePreset.today => todayRange(now),
    ExpenseShareRangePreset.singleDay => custom,
    ExpenseShareRangePreset.thisWeek => thisWeekRange(now),
    ExpenseShareRangePreset.last7 => last7DaysRange(now),
    ExpenseShareRangePreset.month => thisMonthRange(now),
    ExpenseShareRangePreset.custom => custom,
  };
}

List<ExpenseWithSplits> filterExpensesByDateRange(
  List<ExpenseWithSplits> expenses,
  DateTimeRange? range,
) {
  if (range == null) return List<ExpenseWithSplits>.from(expenses);
  return [
    for (final item in expenses)
      if (isDateInInclusiveRange(item.expense.date, range.start, range.end))
        item,
  ];
}

String formatExpenseShareRangeLabel(
  DateTimeRange? range, {
  required AppLocalizations l10n,
  required String locale,
}) {
  if (range == null) return l10n.groupsShareExpensesRangeAll;
  final start = dateOnly(range.start);
  final end = dateOnly(range.end);
  final format = DateFormat.yMMMd(locale);
  if (start == end) return DateFormat.yMMMEd(locale).format(start);
  return l10n.groupsShareExpensesRangeSpan(
    format.format(start),
    format.format(end),
  );
}

String formatExpenseShareHeaderMeta({
  required AppLocalizations l10n,
  required String rangeLabel,
  required int expenseCount,
}) {
  return l10n.groupsShareExpensesHeaderMeta(
    rangeLabel,
    l10n.groupsMemberShareExpenseCount(expenseCount),
  );
}

int includedPeopleCount(ExpenseWithSplits item) {
  return item.splits.where((s) => s.amountCents > 0).length;
}

String _userName(Map<String, String> names, String userId) =>
    names[userId] ?? '?';

/// Per-member share parts in expense order, sorted by total high → low.
List<ExpenseShareMemberTotal> buildExpenseShareMemberTotals(
  List<ExpenseWithSplits> expenses, {
  required Map<String, String> userNames,
}) {
  final partsByUser = <String, List<int>>{};
  for (final item in expenses) {
    for (final split in item.splits) {
      if (split.amountCents <= 0) continue;
      partsByUser.putIfAbsent(split.userId, () => []).add(split.amountCents);
    }
  }

  final rows =
      [
        for (final entry in partsByUser.entries)
          ExpenseShareMemberTotal(
            name: _userName(userNames, entry.key),
            partsCents: entry.value,
            totalCents: entry.value.fold<int>(0, (sum, cents) => sum + cents),
          ),
      ]..sort((a, b) {
        final byTotal = b.totalCents.compareTo(a.totalCents);
        if (byTotal != 0) return byTotal;
        return a.name.compareTo(b.name);
      });
  return rows;
}

String formatExpenseShareMemberTotalLine(
  ExpenseShareMemberTotal row, {
  required AppLocalizations l10n,
  required String locale,
  bool showDecimals = true,
}) {
  final total = _formatPlainAmount(
    row.totalCents,
    locale,
    showDecimals: showDecimals,
  );
  if (row.partsCents.length <= 1) {
    return l10n.groupsShareExpensesMemberSingle(row.name, total);
  }

  final parts = [
    for (final cents in row.partsCents)
      _formatPlainAmount(cents, locale, showDecimals: showDecimals),
  ].join(' + ');
  return l10n.groupsShareExpensesMemberTotalLine(row.name, parts, total);
}

String _formatPlainAmount(
  int cents,
  String locale, {
  bool showDecimals = true,
}) {
  if (!showDecimals) {
    final value = (cents.abs() / 100).round();
    final format = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 0;
    return format.format(value);
  }

  final value = cents.abs() / 100;
  final digits = value.truncateToDouble() == value ? 0 : 2;
  final format = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = digits
    ..maximumFractionDigits = digits;
  return format.format(value);
}

/// Compact image rows (max [maxRows]) plus overflow count and range total.
({List<ExpenseShareImageRow> rows, int overflowCount, int totalCents})
buildExpenseShareImageContent(
  List<ExpenseWithSplits> expenses, {
  required Map<String, String> userNames,
  required AppLocalizations l10n,
  required String currencyCode,
  required String locale,
  bool showDecimals = true,
  int maxRows = kExpenseShareImageMaxRows,
}) {
  final totalCents = expenses.fold<int>(
    0,
    (sum, item) => sum + item.expense.amountCents,
  );
  final overflowCount = expenses.length > maxRows
      ? expenses.length - maxRows
      : 0;
  final visible = overflowCount > 0 ? expenses.take(maxRows) : expenses;
  final dateFormat = DateFormat.MMMd(locale);

  final rows = [
    for (final item in visible)
      ExpenseShareImageRow(
        title: item.expense.title,
        amount: formatCents(
          item.expense.amountCents,
          currencyCode,
          locale: locale,
          showDecimals: showDecimals,
        ),
        subtitle: l10n.groupsShareExpensesPayerPaidDatePeople(
          formatPayersLabel([
            for (final p in item.payers) _userName(userNames, p.userId),
          ], l10n),
          dateFormat.format(item.expense.date),
          l10n.groupsShareExpensesPeopleCount(includedPeopleCount(item)),
        ),
      ),
  ];

  return (rows: rows, overflowCount: overflowCount, totalCents: totalCents);
}

String _payerLabelForText(
  ExpenseWithSplits item, {
  required Map<String, String> userNames,
  required AppLocalizations l10n,
  required String currencyCode,
  required String locale,
  bool showDecimals = true,
}) {
  final payers = item.payers;
  if (payers.isEmpty) return '?';
  if (payers.length == 1) return _userName(userNames, payers.first.userId);

  final withAmounts = [
    for (final p in payers)
      l10n.groupsShareExpensesNameAmount(
        _userName(userNames, p.userId),
        formatCents(
          p.amountCents,
          currencyCode,
          locale: locale,
          showDecimals: showDecimals,
        ),
      ),
  ];
  if (withAmounts.length == 2) {
    return l10n.moneyTwoPayers(withAmounts[0], withAmounts[1]);
  }
  return l10n.moneyManyPayers(withAmounts.first, withAmounts.length - 1);
}

String _memberSharesLine(
  ExpenseWithSplits item, {
  required Map<String, String> userNames,
  required AppLocalizations l10n,
  required String currencyCode,
  required String locale,
  bool showDecimals = true,
}) {
  final parts = [
    for (final split in item.splits)
      if (split.amountCents > 0)
        l10n.groupsShareExpensesNameAmount(
          _userName(userNames, split.userId),
          formatCents(
            split.amountCents,
            currencyCode,
            locale: locale,
            showDecimals: showDecimals,
          ),
        ),
  ];
  return parts.join(' · ');
}

/// Full text body for the range (no row cap).
String buildExpenseShareText(
  List<ExpenseWithSplits> expenses, {
  required String groupName,
  required String rangeLabel,
  required Map<String, String> userNames,
  required AppLocalizations l10n,
  required String currencyCode,
  required String locale,
  bool showDecimals = true,
}) {
  final dateFormat = DateFormat.MMMd(locale);
  final totalCents = expenses.fold<int>(
    0,
    (sum, item) => sum + item.expense.amountCents,
  );
  final buffer = StringBuffer()
    ..writeln(groupName)
    ..writeln(
      formatExpenseShareHeaderMeta(
        l10n: l10n,
        rangeLabel: rangeLabel,
        expenseCount: expenses.length,
      ),
    );

  for (final item in expenses) {
    final amount = formatCents(
      item.expense.amountCents,
      currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    );
    buffer
      ..writeln()
      ..writeln(item.expense.title)
      ..writeln(
        l10n.groupsShareExpensesPaidDateAmount(
          _payerLabelForText(
            item,
            userNames: userNames,
            l10n: l10n,
            currencyCode: currencyCode,
            locale: locale,
            showDecimals: showDecimals,
          ),
          dateFormat.format(item.expense.date),
          amount,
        ),
      );
    final members = _memberSharesLine(
      item,
      userNames: userNames,
      l10n: l10n,
      currencyCode: currencyCode,
      locale: locale,
      showDecimals: showDecimals,
    );
    if (members.isNotEmpty) {
      buffer.writeln(members);
    }
  }

  final memberTotals = buildExpenseShareMemberTotals(
    expenses,
    userNames: userNames,
  );
  if (memberTotals.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(l10n.groupsShareExpensesByPerson);
    for (final row in memberTotals) {
      buffer.writeln(
        formatExpenseShareMemberTotalLine(
          row,
          l10n: l10n,
          locale: locale,
          showDecimals: showDecimals,
        ),
      );
    }
  }

  buffer
    ..writeln()
    ..write(
      l10n.groupsShareExpensesTotalLine(
        formatCents(
          totalCents,
          currencyCode,
          locale: locale,
          showDecimals: showDecimals,
        ),
      ),
    );
  return buffer.toString();
}

String expenseShareCaption({
  required AppLocalizations l10n,
  required String groupName,
  required String rangeLabel,
  required bool isAllDates,
}) {
  if (isAllDates) return l10n.groupsShareExpensesCaption(groupName);
  return l10n.groupsShareExpensesCaptionWithRange(groupName, rangeLabel);
}

/// Filter settlements by date range (date).
List<Settlement> filterSettlementsByDateRange(
  List<Settlement> settlements,
  DateTimeRange? range,
) {
  if (range == null) return List<Settlement>.from(settlements);
  return [
    for (final s in settlements)
      if (isDateInInclusiveRange(s.date, range.start, range.end)) s,
  ];
}

class GroupPeriodMemberSummary {
  final String userId;
  final String name;
  final int paidCents;
  final int shareCents;
  final int netCents;

  const GroupPeriodMemberSummary({
    required this.userId,
    required this.name,
    required this.paidCents,
    required this.shareCents,
    required this.netCents,
  });
}

class GroupPeriodReportData {
  final int totalSpendCents;
  final int expenseCount;
  final int averageExpenseCents;
  final List<GroupPeriodMemberSummary> memberSummaries;
  final List<OpenDebt> periodDebts;
  final List<ExpenseWithSplits> filteredExpenses;
  final List<Settlement> filteredSettlements;
  final int myNetCents;
  final int myShareCents;
  final int myPaidCents;

  const GroupPeriodReportData({
    required this.totalSpendCents,
    required this.expenseCount,
    required this.averageExpenseCents,
    required this.memberSummaries,
    required this.periodDebts,
    required this.filteredExpenses,
    this.filteredSettlements = const [],
    required this.myNetCents,
    required this.myShareCents,
    required this.myPaidCents,
  });
}

GroupPeriodReportData buildGroupPeriodReport({
  required List<ExpenseWithSplits> allExpenses,
  required List<Settlement> allSettlements,
  required List<GroupMemberInfo> members,
  required Map<String, User> users,
  required DateTimeRange? range,
  required String? currentUserId,
}) {
  final filteredExpenses = filterExpensesByDateRange(allExpenses, range);
  final filteredSettlements = filterSettlementsByDateRange(
    allSettlements,
    range,
  );

  var totalSpendCents = 0;
  final paidByUser = <String, int>{};
  final shareByUser = <String, int>{};

  for (final item in filteredExpenses) {
    totalSpendCents += item.expense.amountCents;
    for (final p in item.payers) {
      paidByUser[p.userId] = (paidByUser[p.userId] ?? 0) + p.amountCents;
    }
    for (final s in item.splits) {
      if (s.amountCents > 0) {
        shareByUser[s.userId] = (shareByUser[s.userId] ?? 0) + s.amountCents;
      }
    }
  }

  final filteredPayers = [for (final item in filteredExpenses) ...item.payers];
  final filteredSplits = [for (final item in filteredExpenses) ...item.splits];

  final periodNet = BalanceService.netBalances(
    payers: filteredPayers,
    splits: filteredSplits,
    settlements: filteredSettlements,
  );
  final periodDebts = BalanceService.simplifyDebts(periodNet);

  final memberSummaries = <GroupPeriodMemberSummary>[];
  for (final member in members) {
    final uid = member.user.id;
    final name = users[uid]?.name ?? member.user.name;
    final paid = paidByUser[uid] ?? 0;
    final share = shareByUser[uid] ?? 0;
    final net = periodNet[uid] ?? 0;
    memberSummaries.add(
      GroupPeriodMemberSummary(
        userId: uid,
        name: name,
        paidCents: paid,
        shareCents: share,
        netCents: net,
      ),
    );
  }

  memberSummaries.sort((a, b) {
    final byShare = b.shareCents.compareTo(a.shareCents);
    if (byShare != 0) return byShare;
    return a.name.compareTo(b.name);
  });

  final avgCents = filteredExpenses.isEmpty
      ? 0
      : (totalSpendCents / filteredExpenses.length).round();

  final myNet = currentUserId == null ? 0 : (periodNet[currentUserId] ?? 0);
  final myShare = currentUserId == null ? 0 : (shareByUser[currentUserId] ?? 0);
  final myPaid = currentUserId == null ? 0 : (paidByUser[currentUserId] ?? 0);

  return GroupPeriodReportData(
    totalSpendCents: totalSpendCents,
    expenseCount: filteredExpenses.length,
    averageExpenseCents: avgCents,
    memberSummaries: memberSummaries,
    periodDebts: periodDebts,
    filteredExpenses: filteredExpenses,
    filteredSettlements: filteredSettlements,
    myNetCents: myNet,
    myShareCents: myShare,
    myPaidCents: myPaid,
  );
}

/// Comprehensive text report containing Totals, Who owes whom,
/// Member breakdown, Itemized expenses, and Settlement records.
String buildGroupReportShareText({
  required String groupEmoji,
  required String groupName,
  required String rangeLabel,
  required int totalSpendCents,
  required int totalSettledCents,
  required int openDebtCents,
  required List<OpenDebt> debts,
  required List<GroupPeriodMemberSummary> memberSummaries,
  required List<ExpenseWithSplits> expenses,
  required List<Settlement> settlements,
  required Map<String, String> userNames,
  required AppLocalizations l10n,
  required String currencyCode,
  required String locale,
  bool showDecimals = true,
  String? selectedMemberId,
  String? selectedMemberName,
  bool isCurrentUser = false,
  int? memberNetCents,
  int? memberPaidCents,
  int? memberReceivedCents,
}) {
  final buffer = StringBuffer();
  final isSingleMember = selectedMemberId != null;
  final shortDateFormat = DateFormat('EEE, MMM d', locale);

  // 1. Header
  final titleSuffix = isSingleMember && selectedMemberName != null
      ? ' ($selectedMemberName)'
      : '';
  buffer
    ..writeln('$groupEmoji $groupName$titleSuffix')
    ..writeln(
      '🗓️ $rangeLabel · ${expenses.length} ${expenses.length == 1 ? "expense" : "expenses"} · ${settlements.length} ${settlements.length == 1 ? "settlement" : "settlements"}',
    )
    ..writeln();

  // 2. Totals / Net Balance
  if (!isSingleMember) {
    buffer
      ..writeln('💰 TOTALS')
      ..writeln(
        '• ${l10n.groupsReportTotalSpending}: ${formatCents(totalSpendCents, currencyCode, locale: locale, showDecimals: showDecimals)}',
      )
      ..writeln(
        '• ${l10n.groupsReportSettled}: ${formatCents(totalSettledCents, currencyCode, locale: locale, showDecimals: showDecimals)} (${l10n.groupsReportSettlementsCount(settlements.length)})',
      );
    if (openDebtCents == 0) {
      buffer.writeln(
        '• ${l10n.groupsReportOpenDebt}: ${formatCents(0, currencyCode, locale: locale, showDecimals: false)} (${l10n.groupsReportSettled})',
      );
    } else {
      buffer.writeln(
        '• ${l10n.groupsReportOpenDebt}: ${formatCents(openDebtCents, currencyCode, locale: locale, showDecimals: showDecimals)} (${l10n.groupsReportPending})',
      );
    }
  } else {
    final net = memberNetCents ?? 0;
    final netPrefix = net > 0 ? '+' : (net < 0 ? '-' : '');
    final netFormatted = net == 0
        ? formatCents(0, currencyCode, locale: locale, showDecimals: false)
        : '$netPrefix${formatCents(net, currencyCode, locale: locale, showDecimals: showDecimals)}';
    final name = selectedMemberName ?? '';
    final statusText = net > 0
        ? (isCurrentUser
              ? l10n.groupsReportYouOwed
              : l10n.groupsReportOwedTo(name))
        : net < 0
        ? (isCurrentUser
              ? l10n.groupsReportYouOwe
              : l10n.groupsReportOwes(name))
        : l10n.groupsReportSettled;

    buffer
      ..writeln('💰 ${l10n.groupsReportNetBalance.toUpperCase()}')
      ..writeln('• $name: $netFormatted ($statusText)')
      ..writeln(
        '• ${l10n.groupsReportPaid}: ${formatCents(memberPaidCents ?? 0, currencyCode, locale: locale, showDecimals: showDecimals)}',
      )
      ..writeln(
        '• ${l10n.groupsReportReceived}: ${formatCents(memberReceivedCents ?? 0, currencyCode, locale: locale, showDecimals: showDecimals)}',
      );
  }
  buffer.writeln();

  // 3. Who Owes Whom
  buffer.writeln('🤝 ${l10n.groupsReportWhoOwesWhom.toUpperCase()}');
  if (debts.isEmpty) {
    buffer.writeln(
      '• ${l10n.groupsReportSettled} (${formatCents(0, currencyCode, locale: locale, showDecimals: false)})',
    );
  } else {
    for (final debt in debts) {
      final from = _userName(userNames, debt.fromUserId);
      final to = _userName(userNames, debt.toUserId);
      final amount = formatCents(
        debt.amountCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      buffer.writeln('• $from owes $to: $amount');
    }
  }
  buffer.writeln();

  // 4. Member Breakdown
  if (memberSummaries.isNotEmpty) {
    buffer.writeln('👥 ${l10n.groupsReportMemberSummary.toUpperCase()}');
    for (final s in memberSummaries) {
      final netPrefix = s.netCents > 0 ? '+' : (s.netCents < 0 ? '-' : '');
      final netFormatted = s.netCents == 0
          ? formatCents(0, currencyCode, locale: locale, showDecimals: false)
          : '$netPrefix${formatCents(s.netCents, currencyCode, locale: locale, showDecimals: showDecimals)}';
      final paid = formatCents(
        s.paidCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      final share = formatCents(
        s.shareCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      buffer.writeln(
        '• ${s.name}: ${l10n.groupsReportPaid} $paid | ${l10n.groupsReportShare} $share | ${l10n.groupsReportNet}: $netFormatted',
      );
    }
    buffer.writeln();
  }

  // 5. Itemized Expenses
  if (expenses.isNotEmpty) {
    buffer.writeln(
      '🧾 ${l10n.groupsReportItemizedExpenses(expenses.length).toUpperCase()}',
    );
    for (final item in expenses) {
      final amount = formatCents(
        item.expense.amountCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      final payer = _payerLabelForText(
        item,
        userNames: userNames,
        l10n: l10n,
        currencyCode: currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      final date = shortDateFormat.format(item.expense.date);
      buffer.writeln('• ${item.expense.title}: $amount ($date) · $payer');
      if (item.expense.note != null && item.expense.note!.trim().isNotEmpty) {
        buffer.writeln('  Note: ${item.expense.note!.trim()}');
      }
    }
    buffer.writeln();
  }

  // 6. Settlements (if any in range)
  if (settlements.isNotEmpty) {
    buffer.writeln(
      '💸 ${l10n.groupsSettlementsTitle.toUpperCase()} (${settlements.length})',
    );
    for (final s in settlements) {
      final from = _userName(userNames, s.fromUserId);
      final to = _userName(userNames, s.toUserId);
      final amount = formatCents(
        s.amountCents,
        currencyCode,
        locale: locale,
        showDecimals: showDecimals,
      );
      final date = shortDateFormat.format(s.date);
      buffer.writeln('• $from paid $to: $amount ($date)');
      if (s.note != null && s.note!.trim().isNotEmpty) {
        buffer.writeln('  Note: ${s.note!.trim()}');
      }
    }
    buffer.writeln();
  }

  // 7. Footer
  buffer.write('— Shared via ${AppLinks.appName}');

  return buffer.toString();
}
