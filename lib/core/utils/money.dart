import '../constants/currencies.dart';

/// Formats integer cents as "Rs 1,250" or "Rs 12.50".
String formatCents(int cents, String currencyCode) {
  final symbol = currencyByCode(currencyCode).symbol;
  final value = cents.abs() / 100;
  final text = value.truncateToDouble() == value
      ? _thousands(value.toInt().toString())
      : value.toStringAsFixed(2);
  return '$symbol $text';
}

/// Parses "1250", "1250.50", or "1,250.50" into integer cents.
int? parseAmountToCents(String input) {
  final cleaned = input.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

/// Formats payer names for list/detail copy, e.g. "Alice", "Alice & Bob", "Alice +2".
String formatPayersLabel(List<String> names) {
  if (names.isEmpty) return '?';
  if (names.length == 1) return names.first;
  if (names.length == 2) return '${names[0]} & ${names[1]}';
  return '${names[0]} +${names.length - 1}';
}

String _thousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
