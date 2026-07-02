/// Cent-accurate expense splitting.
abstract class SplitEngineService {
  /// Equal split with remainder distributed one cent at a time.
  static Map<String, int> equalSplit(int totalCents, List<String> userIds) {
    if (userIds.isEmpty) return {};
    final n = userIds.length;
    final base = totalCents ~/ n;
    var remainder = totalCents - base * n;
    final result = <String, int>{};
    for (final id in userIds) {
      final extra = remainder > 0 ? 1 : 0;
      if (remainder > 0) remainder--;
      result[id] = base + extra;
    }
    return result;
  }

  /// Exact amounts — caller must ensure sum equals total.
  static Map<String, int> exactSplit(Map<String, int> amountsCents) =>
      Map.from(amountsCents);

  /// Percentage split with cent rounding; remainder to largest shares first.
  static Map<String, int> percentageSplit(
    int totalCents,
    Map<String, double> percentages,
  ) {
    if (percentages.isEmpty) return {};
    final ids = percentages.keys.toList();
    final raw = <String, double>{};
    var allocated = 0;
    for (final id in ids) {
      final cents = (totalCents * percentages[id]! / 100).floor();
      raw[id] = cents.toDouble();
      allocated += cents;
    }
    var remainder = totalCents - allocated;
    final sorted = ids.toList()
      ..sort((a, b) => percentages[b]!.compareTo(percentages[a]!));
    var i = 0;
    while (remainder > 0) {
      raw[sorted[i % sorted.length]] =
          raw[sorted[i % sorted.length]]! + 1;
      remainder--;
      i++;
    }
    return {for (final e in raw.entries) e.key: e.value.toInt()};
  }

  static bool exactSplitsValid(int totalCents, Map<String, int> amounts) =>
      amounts.values.fold(0, (a, b) => a + b) == totalCents;

  static bool percentageSplitsValid(Map<String, double> percentages) {
    final sum = percentages.values.fold(0.0, (a, b) => a + b);
    return (sum - 100).abs() < 0.01;
  }
}
