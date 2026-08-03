import 'package:intl/intl.dart';

import '../constants/currencies.dart';
import '../../l10n/app_localizations.dart';

/// Formats integer cents using locale-aware grouping and symbol placement.
String formatCents(int cents, String currencyCode, {String? locale}) {
  final currency = currencyByCode(currencyCode);
  final symbol = currency.symbol.trim();
  final value = cents.abs() / 100;
  final format = NumberFormat.currency(
    locale: locale,
    name: currencyCode,
    symbol: symbol,
    decimalDigits: value.truncateToDouble() == value ? 0 : 2,
  );
  return _ensureLetterSymbolSpacing(format.format(value), symbol);
}

/// Letter-based symbols (Rs, CHF, د.إ) need a gap from the amount; glyphs ($ €)
/// stay tight. Only inserts a space when symbol and digits are adjacent.
String _ensureLetterSymbolSpacing(String formatted, String symbol) {
  if (symbol.isEmpty || !_isLetterBasedSymbol(symbol)) return formatted;

  final escaped = RegExp.escape(symbol);
  return formatted
      .replaceFirstMapped(
        RegExp('^$escaped(?=\\d)'),
        (_) => '$symbol ',
      )
      .replaceFirstMapped(
        RegExp('(?<=\\d)$escaped\$'),
        (_) => ' $symbol',
      );
}

bool _isLetterBasedSymbol(String symbol) {
  // Latin (Rs, CHF) or Arabic-script currency labels — not $ € £ ¥ ₹ ₺.
  return RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(symbol);
}

/// Parses a localized amount string into integer cents.
int? parseAmountToCents(String input, {String? locale}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Fast path for plain ASCII numbers with optional grouping.
  final ascii = trimmed.replaceAll(RegExp(r'\s'), '');
  final asciiNormalized = _normalizeAsciiAmount(ascii);
  if (asciiNormalized != null) {
    final value = double.tryParse(asciiNormalized);
    if (value != null && value >= 0) return (value * 100).round();
  }

  try {
    final format = NumberFormat.decimalPattern(locale);
    final value = format.parse(trimmed);
    if (value < 0) return null;
    return (value.toDouble() * 100).round();
  } on FormatException {
    return null;
  }
}

String? _normalizeAsciiAmount(String input) {
  // Keep digits, one decimal separator, and optional grouping commas/dots.
  final cleaned = input.replaceAll(RegExp(r'[^0-9.,]'), '');
  if (cleaned.isEmpty) return null;

  final lastComma = cleaned.lastIndexOf(',');
  final lastDot = cleaned.lastIndexOf('.');
  if (lastComma >= 0 && lastDot >= 0) {
    // The later separator is the decimal; the earlier ones are grouping.
    if (lastComma > lastDot) {
      return cleaned.replaceAll('.', '').replaceAll(',', '.');
    }
    return cleaned.replaceAll(',', '');
  }
  if (lastComma >= 0) {
    final parts = cleaned.split(',');
    if (parts.length == 2 && parts[1].length <= 2) {
      return '${parts[0]}.${parts[1]}';
    }
    return cleaned.replaceAll(',', '');
  }
  return cleaned;
}

/// Formats payer names for list/detail copy.
String formatPayersLabel(List<String> names, AppLocalizations l10n) {
  if (names.isEmpty) return '?';
  if (names.length == 1) return names.first;
  if (names.length == 2) return l10n.moneyTwoPayers(names[0], names[1]);
  return l10n.moneyManyPayers(names.first, names.length - 1);
}
