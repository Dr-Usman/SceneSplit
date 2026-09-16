import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Formats a [DateTime] into a friendly activity timestamp:
/// - `< 1 min` ago: "Just now"
/// - Today: "Today, 2:30 PM" (localized time)
/// - Yesterday: "Yesterday, 4:15 PM"
/// - Within past 6 days: "Mon, 2:30 PM" (day name + time)
/// - Same year: "Mon, Sep 14" (day name + month + day)
/// - Older year: "Mon, Sep 14, 2025" (day name + month + day + year)
String formatRelativeActivityTime(
  DateTime dateTime, {
  DateTime? now,
  required String locale,
  required AppLocalizations l10n,
}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(dateTime);

  if (diff.isNegative || diff.inMinutes < 1) {
    return l10n.timeJustNow;
  }

  String cleanTime(DateTime dt) {
    return DateFormat.jm(
      locale,
    ).format(dt).replaceAll(RegExp(r'[\u202F\u00A0]'), ' ');
  }

  final startOfToday = DateTime(current.year, current.month, current.day);
  if (dateTime.isAfter(startOfToday) ||
      dateTime.isAtSameMomentAs(startOfToday)) {
    return l10n.timeTodayAt(cleanTime(dateTime));
  }

  final startOfYesterday = DateTime(
    current.year,
    current.month,
    current.day - 1,
  );
  if (dateTime.isAfter(startOfYesterday) ||
      dateTime.isAtSameMomentAs(startOfYesterday)) {
    return l10n.timeYesterdayAt(cleanTime(dateTime));
  }

  // Within the past 6 calendar days: show Day, Time (e.g. "Mon, 2:30 PM")
  final sixDaysAgo = startOfToday.subtract(const Duration(days: 6));
  if (dateTime.isAfter(sixDaysAgo) || dateTime.isAtSameMomentAs(sixDaysAgo)) {
    final dayStr = DateFormat.E(locale).format(dateTime);
    return '$dayStr, ${cleanTime(dateTime)}';
  }

  // Older in current year: show Day + Month Day (e.g. "Mon, Sep 14")
  if (dateTime.year == current.year) {
    return DateFormat.MMMEd(
      locale,
    ).format(dateTime).replaceAll(RegExp(r'[\u202F\u00A0]'), ' ');
  }

  // Older year: show Day + Date + Year (e.g. "Mon, Sep 14, 2025")
  return DateFormat.yMMMEd(
    locale,
  ).format(dateTime).replaceAll(RegExp(r'[\u202F\u00A0]'), ' ');
}
