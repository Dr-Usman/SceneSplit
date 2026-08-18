import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/group_detail_provider.dart';
import 'money.dart';

/// Max expense rows rendered on the share PNG (overflow is a trailing line).
const int kExpenseShareImageMaxRows = 30;

enum ExpenseShareRangePreset { all, month, last7, custom }

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
    ExpenseShareRangePreset.month => thisMonthRange(now),
    ExpenseShareRangePreset.last7 => last7DaysRange(now),
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
  if (start == end) return format.format(start);
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
}) {
  final total = _formatPlainAmount(row.totalCents, locale);
  if (row.partsCents.length <= 1) {
    return l10n.groupsShareExpensesMemberSingle(row.name, total);
  }

  final parts = [
    for (final cents in row.partsCents) _formatPlainAmount(cents, locale),
  ].join(' + ');
  return l10n.groupsShareExpensesMemberTotalLine(row.name, parts, total);
}

String _formatPlainAmount(int cents, String locale) {
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
}) {
  final payers = item.payers;
  if (payers.isEmpty) return '?';
  if (payers.length == 1) return _userName(userNames, payers.first.userId);

  final withAmounts = [
    for (final p in payers)
      l10n.groupsShareExpensesNameAmount(
        _userName(userNames, p.userId),
        formatCents(p.amountCents, currencyCode, locale: locale),
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
}) {
  final parts = [
    for (final split in item.splits)
      if (split.amountCents > 0)
        l10n.groupsShareExpensesNameAmount(
          _userName(userNames, split.userId),
          formatCents(split.amountCents, currencyCode, locale: locale),
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
        formatExpenseShareMemberTotalLine(row, l10n: l10n, locale: locale),
      );
    }
  }

  buffer
    ..writeln()
    ..write(
      l10n.groupsShareExpensesTotalLine(
        formatCents(totalCents, currencyCode, locale: locale),
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
