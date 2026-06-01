import 'settlement_suggestion.dart';

class DashboardDataModel {
  final Map<String, double> balances;
  final List<SettlementSuggestion> suggestions;
  final double totalOwed;
  final double totalOwing;

  const DashboardDataModel({
    required this.balances,
    required this.suggestions,
    required this.totalOwed,
    required this.totalOwing,
  });

  double get netBalance => totalOwed - totalOwing;

  DashboardDataModel copyWith({
    Map<String, double>? balances,
    List<SettlementSuggestion>? suggestions,
    double? totalOwed,
    double? totalOwing,
  }) {
    return DashboardDataModel(
      balances: balances ?? this.balances,
      suggestions: suggestions ?? this.suggestions,
      totalOwed: totalOwed ?? this.totalOwed,
      totalOwing: totalOwing ?? this.totalOwing,
    );
  }
}
